import XCTest
@testable import NoPlexFocus

private final class MemoryStore: FocusStore {
    var saved: FocusState?
    func load() -> FocusState? { saved }
    func save(_ state: FocusState) throws { saved = state }
}

final class FocusViewModelTests: XCTestCase {
    @MainActor
    func testTimerUsesElapsedTimeAcrossRelaunch() {
        let clock = Date(timeIntervalSince1970: 1_000)
        let store = MemoryStore()
        let model = FocusViewModel(store: store, now: clock)
        model.start(now: clock)
        let relaunched = FocusViewModel(store: store, now: clock.addingTimeInterval(90))
        XCTAssertEqual(relaunched.remaining(at: clock.addingTimeInterval(90)), 510)
        XCTAssertEqual(relaunched.remaining(at: clock.addingTimeInterval(900)), 0)
        XCTAssertEqual(relaunched.current?.title, "Send the project update")
    }

    @MainActor
    func testPauseFreezesTimeAndResumeKeepsRemainder() {
        let clock = Date(timeIntervalSince1970: 1_000)
        let model = FocusViewModel(store: MemoryStore(), now: clock)
        model.start(now: clock)
        model.togglePause(now: clock.addingTimeInterval(60))
        XCTAssertEqual(model.remaining(at: clock.addingTimeInterval(900)), 540)
        model.togglePause(now: clock.addingTimeInterval(900))
        XCTAssertEqual(model.remaining(at: clock.addingTimeInterval(960)), 480)
    }

    @MainActor
    func testExpiredWindowCanBeExtendedWithoutCompletingTask() {
        let clock = Date(timeIntervalSince1970: 1_000)
        let model = FocusViewModel(store: MemoryStore(), now: clock)
        model.start(now: clock)
        model.addTwoMinutes(now: clock.addingTimeInterval(900))
        XCTAssertEqual(model.remaining(at: clock.addingTimeInterval(900)), 120)
        XCTAssertEqual(model.state.tasks.count, 3)
    }

    @MainActor
    func testCaptureDoesNotInterruptFocusAndCanBecomeNext() {
        let store = MemoryStore()
        let model = FocusViewModel(store: store)
        model.start()
        let original = model.current
        let end = model.state.sessionEnd
        model.capture("   Buy groceries  ")
        model.capture(" \n ")
        XCTAssertEqual(model.state.captured, ["Buy groceries"])
        XCTAssertEqual(model.current, original)
        XCTAssertEqual(model.state.sessionEnd, end)
        model.promoteCapture(at: 0)
        XCTAssertEqual(model.next?.title, "Buy groceries")
        XCTAssertEqual(model.current, original)
        XCTAssertTrue(model.state.captured.isEmpty)
        XCTAssertEqual(store.saved?.tasks, model.state.tasks)
    }

    @MainActor
    func testCompletionClearsTimerAndRevealsNext() {
        let model = FocusViewModel(store: MemoryStore())
        let next = model.next
        model.start()
        model.complete()
        XCTAssertEqual(model.current, next)
        XCTAssertFalse(model.hasSession)
        XCTAssertFalse(model.isPaused)
    }

    @MainActor
    func testTryingAnotherKeepsTaskForLater() {
        let model = FocusViewModel(store: MemoryStore())
        let first = model.current
        let next = model.next
        model.start()
        model.deferCurrent()
        XCTAssertEqual(model.current, next)
        XCTAssertEqual(model.state.tasks.last, first)
        XCTAssertEqual(model.state.tasks.count, 3)
        XCTAssertFalse(model.hasSession)
    }
}
