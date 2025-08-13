import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var checkedIngredients: Set<String> = []
    @State private var isFavorite: Bool
    @State private var isPlanned: Bool
    let onToggleFavorite: (Recipe) -> Void
    let onTogglePlanned: (Recipe) -> Void

    init(recipe: Recipe, isInitiallyFavorite: Bool, isInitiallyPlanned: Bool, onToggleFavorite: @escaping (Recipe) -> Void, onTogglePlanned: @escaping (Recipe) -> Void) {
        self.recipe = recipe
        self._isFavorite = State(initialValue: isInitiallyFavorite)
        self._isPlanned = State(initialValue: isInitiallyPlanned)
        self.onToggleFavorite = onToggleFavorite
        self.onTogglePlanned = onTogglePlanned
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                CachedImageView(urlString: recipe.image)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.card))

                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title).font(Theme.Typography.title2).foregroundStyle(Theme.Colors.textPrimary)
                    HStack(spacing: 8) {
                        Image(systemName: "clock").foregroundStyle(Theme.Colors.textTertiary)
                        Text("\(recipe.minutes) minutes").foregroundStyle(Theme.Colors.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients").font(Theme.Typography.title3).foregroundStyle(Theme.Colors.textPrimary)
                    ForEach(recipe.ingredients) { ing in
                        Button {
                            if checkedIngredients.contains(ing.name) { checkedIngredients.remove(ing.name) } else { checkedIngredients.insert(ing.name) }
                        } label: {
                            HStack {
                                Image(systemName: checkedIngredients.contains(ing.name) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(checkedIngredients.contains(ing.name) ? .green : Theme.Colors.textSecondary)
                                Text(ing.name + (ing.quantity.map { " – \($0)" } ?? ""))
                                    .foregroundStyle(Theme.Colors.textPrimary)
                                    .strikethrough(checkedIngredients.contains(ing.name), color: .green)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Method").font(Theme.Typography.title3).foregroundStyle(Theme.Colors.textPrimary)
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).").font(Theme.Typography.body).foregroundStyle(Theme.Colors.textSecondary)
                            Text(step).font(Theme.Typography.body).foregroundStyle(Theme.Colors.textPrimary)
                        }
                    }
                }
            }
            .padding(Theme.Spacing.lg)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onToggleFavorite(recipe)
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(.pink)
                }
            }
        }
		.safeAreaInset(edge: .bottom) {
			VStack(spacing: 0) {
				Button(action: {
					onTogglePlanned(recipe)
					isPlanned.toggle()
				}) {
					Text(isPlanned ? "Remove from Plan" : "Add to This Week’s Plan")
						.font(Theme.Typography.button)
						.foregroundStyle(Theme.Colors.textPrimary)
						.frame(maxWidth: .infinity)
						.padding(.vertical, 14)
				}
				.background(Theme.Gradients.primary)
				.clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.button))
				.shadow(color: Theme.Shadows.button, radius: 8, x: 0, y: 4)
				.padding(.horizontal, Theme.Spacing.lg)
				.padding(.top, Theme.Spacing.sm)
				.padding(.bottom, Theme.Spacing.sm)
			}
			.background(Theme.Colors.background.opacity(0.95))
		}
    }
}


