import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    enum ViewState: Equatable { case idle, loading, loaded, empty, error(String) }
    
    @Published var state: ViewState = .idle
    @Published var recipes: [Recipe] = []
    @Published var searchText: String = ""
    
    private let fetchUseCase: FetchRecipesUseCase
    private let searchUseCase: SearchRecipesUseCase
    let getFavoritesUseCase: GetIsFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let debouncer = AsyncDebouncer()
    
    init(
    fetchUseCase: FetchRecipesUseCase,
    searchUseCase: SearchRecipesUseCase,
    getFavoritesUseCase: GetIsFavoritesUseCase,
    toggleFavoriteUseCase: ToggleFavoriteUseCase
) {
    self.fetchUseCase = fetchUseCase
    self.searchUseCase = searchUseCase
    self.getFavoritesUseCase = getFavoritesUseCase
    self.toggleFavoriteUseCase = toggleFavoriteUseCase
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
    
    private func loadAll() async {
        state = .loading
        do {
            let list = try await fetchUseCase.execute()
            self.recipes = list
            state = list.isEmpty ? .empty : .loaded
        } catch {
            state = .error("Failed to load recipes")
        }
    }
    
    private func performSearch() async {
        do {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                await loadAll()
                return
            }
            let results = try await searchUseCase.execute(query: searchText)
            self.recipes = results
            state = results.isEmpty ? .empty : .loaded
        } catch {
            state = .error("Search failed")
        }
    }
}


