import Foundation

protocol FocusStore {
    func load() -> FocusState?
    func save(_ state: FocusState) throws
}

struct LocalFocusStore: FocusStore {
    private let key = "noplex.focus.state.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func load() -> FocusState? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(FocusState.self, from: data)
    }

    func save(_ state: FocusState) throws {
        defaults.set(try JSONEncoder().encode(state), forKey: key)
    }
}
