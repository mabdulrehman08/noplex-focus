import Foundation
import Combine

@MainActor
final class FocusViewModel: ObservableObject {
    @Published private(set) var state: FocusState
    @Published private(set) var storageMessage: String?
    @Published var feedback: String?
    private let store: any FocusStore

    init(store: any FocusStore = LocalFocusStore(), now: Date = Date()) {
        self.store = store
        state = store.load() ?? .sample(now: now)
    }

    var current: FocusTask? { state.tasks.first }
    var next: FocusTask? { state.tasks.dropFirst().first }
    var hasSession: Bool { state.sessionDuration != nil }
    var isPaused: Bool { state.pausedRemaining != nil }

    func remaining(at now: Date) -> TimeInterval {
        if let paused = state.pausedRemaining { return paused }
        return max(0, state.sessionEnd?.timeIntervalSince(now) ?? 0)
    }

    func progress(at now: Date) -> Double {
        guard let duration = state.sessionDuration, duration > 0 else { return 0 }
        return min(1, max(0, 1 - remaining(at: now) / duration))
    }

    func start(now: Date = Date()) {
        guard let task = current, !hasSession else { return }
        let duration = Double(task.minutes * 60)
        state.sessionDuration = duration
        state.sessionEnd = now.addingTimeInterval(duration)
        persist()
    }

    func togglePause(now: Date = Date()) {
        guard hasSession else { return }
        if let remaining = state.pausedRemaining {
            state.sessionEnd = now.addingTimeInterval(remaining)
            state.pausedRemaining = nil
        } else {
            state.pausedRemaining = remaining(at: now)
            state.sessionEnd = nil
        }
        persist()
    }

    func addTwoMinutes(now: Date = Date()) {
        guard hasSession else { return }
        state.sessionDuration = (state.sessionDuration ?? 0) + 120
        if let paused = state.pausedRemaining {
            state.pausedRemaining = paused + 120
        } else {
            state.sessionEnd = max(state.sessionEnd ?? now, now).addingTimeInterval(120)
        }
        persist()
    }

    func complete() {
        guard current != nil else { return }
        state.tasks.removeFirst()
        clearSession()
        feedback = "That counts. Take a breath before the next thing."
        persist()
    }

    func deferCurrent() {
        guard !state.tasks.isEmpty else { return }
        let task = state.tasks.removeFirst()
        state.tasks.append(task)
        clearSession()
        feedback = "Moved to later. You can choose a different starting point."
        persist()
    }

    func capture(_ text: String) {
        let title = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        state.captured.append(title)
        feedback = "Saved for later. Your focus is still here."
        persist()
    }

    func promoteCapture(at index: Int) {
        guard state.captured.indices.contains(index) else { return }
        let title = state.captured.remove(at: index)
        let task = FocusTask(title: title, firstStep: "Give this five minutes. Find one small place to begin.", minutes: 5)
        state.tasks.insert(task, at: min(1, state.tasks.count))
        persist()
    }

    func removeCapture(at index: Int) {
        guard state.captured.indices.contains(index) else { return }
        state.captured.remove(at: index)
        persist()
    }

    func updateAnchor(title: String, date: Date) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }
        state.anchor = TimeAnchor(title: cleanTitle, date: date)
        persist()
    }

    private func clearSession() {
        state.sessionEnd = nil
        state.sessionDuration = nil
        state.pausedRemaining = nil
    }

    private func persist() {
        do {
            try store.save(state)
            storageMessage = nil
        } catch {
            storageMessage = "Your changes are here, but could not be saved on this device."
        }
    }
}
