import SwiftUI

struct PlanView: View {
    private let container: AppContainer
    @StateObject private var viewModel: PlanViewModel
    
    init(container: AppContainer = .shared) {
        self.container = container
        _viewModel = StateObject(wrappedValue: container.makePlanViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    plannedSection
                    shoppingListSection
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("This Week’s Plan")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(
                    recipe: recipe,
                    isInitiallyFavorite: GetIsFavoritesUseCase(repository: container.repository).execute(id: recipe.id),
                    isInitiallyPlanned: GetIsPlannedUseCase(repository: container.repository).execute(id: recipe.id),
                    onToggleFavorite: { rec in
                        _ = ToggleFavoriteUseCase(repository: container.repository).execute(recipe: rec)
                        Task { await viewModel.refresh() }
                    },
                    onTogglePlanned: { rec in
                        _ = TogglePlannedUseCase(repository: container.repository).execute(recipe: rec)
                        Task { await viewModel.refresh() }
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(viewModel.shoppingList.isEmpty)
                }
            }
        }
        .onAppear { viewModel.load() }
    }
    
    @ViewBuilder
    private var plannedSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Planned Recipes").font(Theme.Typography.title2).foregroundStyle(Theme.Colors.textPrimary)
            if viewModel.planned.isEmpty {
                Text("No recipes planned yet.").font(Theme.Typography.body).foregroundStyle(Theme.Colors.textSecondary)
            } else {
                ForEach(viewModel.planned) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeRowView(recipe: recipe, isFavorite: false)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var shoppingListSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Shopping List").font(Theme.Typography.title2).foregroundStyle(Theme.Colors.textPrimary)
            if viewModel.shoppingList.isEmpty {
                Text("Your consolidated list will appear here once you add recipes to the plan.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
            } else {
                ForEach(viewModel.shoppingList, id: \.id) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name).font(Theme.Typography.body).foregroundStyle(Theme.Colors.textPrimary)
                        if item.quantities.isEmpty == false {
                            Text(item.quantities.joined(separator: ", ")).font(Theme.Typography.caption).foregroundStyle(Theme.Colors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                    Divider().background(Theme.Colors.surface)
                }
            }
        }
    }
}



private extension PlanView {
    var shareText: String {
        let header = "Shopping List"
        let lines = viewModel.shoppingList.map { item in
            let quantityText = item.quantities.isEmpty ? "" : " — " + item.quantities.joined(separator: ", ")
            return "• \(item.name)\(quantityText)"
        }
        return ([header] + lines).joined(separator: "\n")
    }
}
