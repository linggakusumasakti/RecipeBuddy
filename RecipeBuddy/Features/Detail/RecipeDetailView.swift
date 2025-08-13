import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var checkedIngredients: Set<String> = []
    @State private var isFavorite: Bool
    let onToggleFavorite: (Recipe) -> Void

    init(recipe: Recipe, isInitiallyFavorite: Bool, onToggleFavorite: @escaping (Recipe) -> Void) {
        self.recipe = recipe
        self._isFavorite = State(initialValue: isInitiallyFavorite)
        self.onToggleFavorite = onToggleFavorite
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(Theme.Colors.surfaceSecondary)
                }
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
    }
}


