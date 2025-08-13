import Foundation

actor AsyncDebouncer {
    private var currentTask: Task<Void, Never>?

    func debounce(milliseconds: Int, action: @escaping () async -> Void) {
        currentTask?.cancel()
        currentTask = Task { [milliseconds] in
            try? await Task.sleep(nanoseconds: UInt64(milliseconds) * 1_000_000)
            guard !Task.isCancelled else { return }
            await action()
        }
    }
}


