import SwiftUI

struct HomeView: View {
    private let container: AppContainer
    @StateObject private var viewModel: HomeViewModel

    init(container: AppContainer = .shared) {
        self.container = container
        _viewModel = StateObject(wrappedValue: container.makeHomeViewModel())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    header
                    controls
                    content
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(
                    recipe: recipe,
                    isInitiallyFavorite: viewModel.getFavoritesUseCase.execute(id: recipe.id)
                ) { rec in
                    viewModel.toggleFavorite(recipe: rec)
                }
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: viewModel.searchText) { newValue, _ in
            viewModel.onSearchTextChange(newValue)
        }
        .onAppear { viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("What’s cooking?")
                .font(Theme.Typography.title1)
                .foregroundStyle(Theme.Gradients.primary)
            Text("Discover recipes tailored for you.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.lg)
        .background(Theme.Colors.background)
    }

    @ViewBuilder
    private var controls: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.availableTags, id: \.self) { tag in
                        Button(action: { viewModel.toggleTag(tag) }) {
                            Text(tag)
                                .font(Theme.Typography.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(viewModel.selectedTags.contains(tag) ? Theme.Colors.gradientStart.opacity(0.25) : Theme.Colors.surfaceSecondary)
                                .clipShape(Capsule())
                                .foregroundStyle(viewModel.selectedTags.contains(tag) ? Theme.Colors.gradientStart : Theme.Colors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
        .padding(.top, Theme.Spacing.md)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView().progressViewStyle(.circular)
                .tint(.white)
        case .empty:
            EmptyStateView(title: "No recipes", subtitle: "Try a different search.")
        case .error(let message):
            EmptyStateView(title: "Oops", subtitle: message)
        case .loaded:
            LazyVStack(spacing: 0) {
                ForEach(viewModel.recipes) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeRowView(recipe: recipe, isFavorite: false)
                            .contentShape(Rectangle())
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

private struct EmptyStateView: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text(title).font(Theme.Typography.title2).foregroundColor(Theme.Colors.textPrimary)
            Text(subtitle).font(Theme.Typography.body).foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}


