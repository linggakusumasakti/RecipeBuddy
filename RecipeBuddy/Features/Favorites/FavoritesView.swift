import SwiftUI

struct FavoritesView: View {
    private let container: AppContainer
    @StateObject private var viewModel: FavoritesViewModel
    
    init(container: AppContainer = .shared) {
        self.container = container
        _viewModel = StateObject(wrappedValue: container.makeFavoritesViewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.md) {
                HStack {
                    Picker("Order", selection: $viewModel.order) {
                        Text("Oldest").tag(FavoriteSortOrder.oldestFirst as FavoriteSortOrder)
                        Text("Newest").tag(FavoriteSortOrder.newestFirst as FavoriteSortOrder)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.order) {
                        viewModel.refresh()
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                
                Group {
                if viewModel.recipes.isEmpty {
                    VStack(spacing: Theme.Spacing.md) {
                        Text("No favorites yet").font(Theme.Typography.title3).foregroundStyle(Theme.Colors.textPrimary)
                        Text("Mark recipes with the heart icon to save them here.")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.recipes) { recipe in
                                NavigationLink(value: recipe) {
                                    RecipeRowView(recipe: recipe, isFavorite: true)
                                        .padding(.horizontal, Theme.Spacing.lg)
                                        .padding(.vertical, 8)
                                }
                                Divider().background(Theme.Colors.surface)
                                    .padding(.leading, Theme.Spacing.lg + 84 + Theme.Spacing.md)
                            }
                        }
                    }
                }
                }
            }
            .background(Theme.Colors.background)
            .navigationDestination(for: Recipe.self) { recipe in
                FavoriteRecipeDestination(
                    id: recipe.id,
                    getUseCase: viewModel.getFavoriteRecipeUseCase,
                    getIsPlannedUseCase: GetIsPlannedUseCase(repository: container.repository),
                    togglePlannedUseCase: TogglePlannedUseCase(repository: container.repository)
                ) { rec in
                    viewModel.toggleFavorite(recipe: rec)
                }
            }
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.refresh() }
    }
}

private struct FavoriteRecipeDestination: View {
    let id: String
    let getUseCase: GetFavoriteRecipeUseCase
    let getIsPlannedUseCase: GetIsPlannedUseCase
    let togglePlannedUseCase: TogglePlannedUseCase
    let onToggle: (Recipe) -> Void

    @State private var loaded: Recipe?
    @State private var isLoading: Bool = false

    var body: some View {
        Group {
            if let recipe = loaded {
                RecipeDetailView(
                    recipe: recipe,
                    isInitiallyFavorite: true,
                    isInitiallyPlanned: getIsPlannedUseCase.execute(id: recipe.id),
                    onToggleFavorite: { rec in onToggle(rec) },
                    onTogglePlanned: { rec in _ = togglePlannedUseCase.execute(recipe: rec) }
                )
            } else {
                ProgressView().task {
                    guard !isLoading else { return }
                    isLoading = true
                    loaded = try? await getUseCase.execute(id: id)
                    isLoading = false
                }
            }
        }
        .background(Theme.Colors.background)
    }
}


