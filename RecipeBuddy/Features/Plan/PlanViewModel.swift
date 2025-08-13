import Foundation

@MainActor
final class PlanViewModel: ObservableObject {
    enum ViewState: Equatable { case idle, loading, loaded, empty, error(String) }
    
    @Published var state: ViewState = .idle
    @Published var planned: [Recipe] = []
    @Published var shoppingList: [ShoppingListItem] = []
    
    private let getPlannedRecipesUseCase: GetPlannedRecipesUseCase
    private let generateShoppingListUseCase: GenerateShoppingListUseCase
    
    init(getPlannedRecipesUseCase: GetPlannedRecipesUseCase, generateShoppingListUseCase: GenerateShoppingListUseCase) {
        self.getPlannedRecipesUseCase = getPlannedRecipesUseCase
        self.generateShoppingListUseCase = generateShoppingListUseCase
    }
    
    func load() {
        Task { await refresh() }
    }
    
    func refresh() async {
        state = .loading
        do {
            let items = try await getPlannedRecipesUseCase.execute()
            planned = items
            shoppingList = try await generateShoppingListUseCase.execute()
            state = (planned.isEmpty && shoppingList.isEmpty) ? .empty : .loaded
        } catch {
            state = .error("Failed to load plan")
        }
    }
}


