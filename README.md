## RecipeBuddy

Lightweight iOS app for browsing recipes, viewing details, marking favorites, planning meals, and generating a consolidated shopping list.

### How to run
- Requirements: Xcode 15+ (Swift Concurrency, Swift Testing), iOS 17 simulator or device
- Steps:
  - Open `RecipeBuddy.xcodeproj` in Xcode
  - Select the `RecipeBuddy` scheme
  - Run (Cmd+R)
  - To run tests: Product → Test (Cmd+U)

### Architecture
- MVVM + Repository with Use Cases
  - Views in `RecipeBuddy/Features/**` bind to `ViewModel`s
  - `UseCases` encapsulate application actions and depend on `RecipeRepository`
  - `RecipeRepository` coordinates data sources
  - `AppContainer` wires dependencies and creates view models
- Data sources
  - Remote: `RecipesRemoteDataSource` loads bundled `recipes.json`
  - Local cache: Core Data (`RecipesLocalDataSource`) stores list for offline fallback
  - Favorites: Core Data (`FavoritesLocalDataSource`)
  - Meal plan: Core Data (`PlannedLocalDataSource`)
- Concurrency: async/await; debounced search via `AsyncDebouncer`
- Image caching: in-memory `NSCache` + URLCache policy in `CachedImageView`

Key files
- `Application/AppContainer.swift` – dependency container
- `Domain/Entities/*` – `Recipe`, `Ingredient`
- `Domain/Interfaces/RecipeRepository.swift`
- `Domain/UseCases/*` – fetch/search/filter/favorites/plan/shopping list
- `Data/Remote/RecipesRemoteDataSource.swift` – bundled JSON loader
- `Data/Local/*` – Core Data stack and local data sources
- `Data/Repositories/RecipeRepositoryImpl.swift` – offline-first repository
- `Features/Home/*`, `Features/Detail/*`, `Features/Favorites/*`, `Features/Plan/*`

### Feature checklist (by levels)

Level 1 – Core
- Home list: Loads from bundled `recipes.json`; shows thumbnail, title, tags, and time
- Detail: Image, ingredients with check-off state, step-by-step method
- Search: Debounced (300ms) by title or ingredient; empty and error states
- Favorites (persisted):
  - Toggle in Detail (heart button) and from Favorites flow
  - Persisted via Core Data across launches
  - Row favorite indicator shown in Favorites list
  - Note: favorite toggle directly from Home list row is not implemented
- Architecture/state: MVVM with `RecipeRepository` protocol; async/await; no IO in Views

Level 2 – Plus
- Sort/filter:
  - Filter by tags (multi-select chips) – completed
  - Sort by time (asc/desc) – not implemented
- Offline-first:
  - Repository loads remote, saves to Core Data, and falls back to cache on failure – completed
- Testing and caching:
  - Unit tests: Remote decoding, Repository behaviors (fallback, search, filtering, favorites ordering), HomeViewModel – completed
  - Image caching: `NSCache` with URLCache policy – completed

Level 3 – Pro
- Meal plan + shopping list:
  - Add/remove recipes to “This Week’s Plan” from Detail
  - Consolidated shopping list (duplicates merged by ingredient name, quantities aggregated and listed)
- Share: Shopping list shared via system share sheet

### Trade-offs and notes
- Remote source is bundle-based for reliability in this sample. The repository still provides offline-first behavior via Core Data caching and graceful fallback.
- Core Data model is defined programmatically in `CoreDataStack` (no `.xcdatamodeld`). Arrays are stored as secure transformables.
- Favorites and Planned entities store summary fields (no steps/ingredients). Full favorite detail is fetched when needed.
- Home list does not include a direct favorite toggle. Favorites can be toggled in Detail; favorite badge is shown in Favorites list.
- Search trims whitespace and matches title or ingredient names; debounced on text change.

### What I would add with more time
- Sorting by cook time (asc/desc) and a UI control to select order
- Favorite toggle directly in Home list rows and show favorite state there
- More tests: local data sources, PlanViewModel, shopping list generation edge cases, image loader, and UI tests
- Disk image caching and better placeholders; error image states
- Accessibility (VoiceOver labels, Dynamic Type), localization, and snapshot tests for UI

