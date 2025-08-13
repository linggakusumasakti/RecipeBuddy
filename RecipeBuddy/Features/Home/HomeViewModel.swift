import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    enum ViewState: Equatable { case idle, loading, loaded, empty, error(String) }
    // Removed time sort from Home; favorites has its own createdAt-based sorting
    
    @Published var state: ViewState = .idle
    @Published var recipes: [Recipe] = []
    @Published var searchText: String = ""
    @Published var availableTags: [String] = []
    @Published var selectedTags: Set<String> = []
    
    private let fetchUseCase: FetchRecipesUseCase
    let getFavoritesUseCase: GetIsFavoritesUseCase
    private let searchUseCase: SearchRecipesUseCase
    private let filterByTagsUseCase: FilterRecipesByTagsUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    let getIsPlannedUseCase: GetIsPlannedUseCase
    private let togglePlannedUseCase: TogglePlannedUseCase
    private let debouncer = AsyncDebouncer()
    private var allRecipes: [Recipe] = []
    
    init(
    fetchUseCase: FetchRecipesUseCase,
    searchUseCase: SearchRecipesUseCase,
    filterByTagsUseCase: FilterRecipesByTagsUseCase,
    getFavoritesUseCase: GetIsFavoritesUseCase,
    toggleFavoriteUseCase: ToggleFavoriteUseCase,
    getIsPlannedUseCase: GetIsPlannedUseCase,
    togglePlannedUseCase: TogglePlannedUseCase
 ) {
    self.fetchUseCase = fetchUseCase
    self.searchUseCase = searchUseCase
    self.filterByTagsUseCase = filterByTagsUseCase
    self.getFavoritesUseCase = getFavoritesUseCase
    self.toggleFavoriteUseCase = toggleFavoriteUseCase
    self.getIsPlannedUseCase = getIsPlannedUseCase
    self.togglePlannedUseCase = togglePlannedUseCase
 }
    
    func load() {
        Task { await loadAll() }
    }
    
    func onSearchTextChange(_ text: String) {
        Task { await debouncer.debounce(milliseconds: 300) { [weak self] in
            await self?.performSearch()
        }}
    }
    
    func toggleFavorite(recipe: Recipe) {
         toggleFavoriteUseCase.execute(recipe: recipe)
    }

    func togglePlanned(recipe: Recipe) {
         _ = togglePlannedUseCase.execute(recipe: recipe)
    }
    
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) { selectedTags.remove(tag) } else { selectedTags.insert(tag) }
        applyFiltersAndSort()
    }
    
    private func loadAll() async {
        state = .loading
        do {
            let list = try await fetchUseCase.execute()
            self.allRecipes = list
            self.availableTags = Array(Set(list.flatMap { $0.tags })).sorted()
            applyFiltersAndSort()
            state = list.isEmpty ? .empty : .loaded
        } catch {
            state = .error("Failed to load recipes")
        }
    }
    
    private func performSearch() async {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            await loadAll()
            return
        }
        do {
            let results = try await searchUseCase.execute(query: trimmedQuery)
            self.allRecipes = results
            applyFiltersAndSort()
            state = recipes.isEmpty ? .empty : .loaded
        } catch {
            state = .error("Search failed")
        }
    }
    
    private func applyFiltersAndSort() {
        let hasSelectedTags = selectedTags.isEmpty == false
        if hasSelectedTags == false {
            self.recipes = allRecipes
            return
        }
        Task { [selectedTags] in
            do {
                let filtered = try await filterByTagsUseCase.execute(tags: selectedTags)
                self.recipes = filtered
            } catch {
                self.recipes = []
            }
        }
    }
}


