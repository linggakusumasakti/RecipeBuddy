import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe
    let isFavorite: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            CachedImageView(urlString: recipe.image)
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.card))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(recipe.title)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(2)
                    Spacer()
                    if isFavorite { Image(systemName: "heart.fill").foregroundStyle(.pink) }
                }
                HStack(spacing: 8) {
                    ForEach(recipe.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(Theme.Typography.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.Colors.surfaceSecondary)
                            .clipShape(Capsule())
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
                HStack(spacing: 6) {
                    Image(systemName: "clock").foregroundStyle(Theme.Colors.textTertiary)
                    Text("\(recipe.minutes) min").foregroundStyle(Theme.Colors.textSecondary).font(Theme.Typography.footnote)
                }
            }
        }
        .padding(.vertical, 8)
        .listRowBackground(Theme.Colors.background)
    }
}


