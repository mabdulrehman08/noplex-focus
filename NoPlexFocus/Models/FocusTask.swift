import Foundation

struct FocusTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var firstStep: String
    var minutes: Int

    init(id: UUID = UUID(), title: String, firstStep: String, minutes: Int) {
        self.id = id
        self.title = title
        self.firstStep = firstStep
        self.minutes = minutes
    }
}

struct TimeAnchor: Codable {
    var title: String
    var date: Date
}

struct FocusState: Codable {
    var tasks: [FocusTask]
    var captured: [String]
    var anchor: TimeAnchor
    var sessionEnd: Date?
    var sessionDuration: TimeInterval?
    var pausedRemaining: TimeInterval?

    static func sample(now: Date = Date()) -> FocusState {
        FocusState(
            tasks: [
                FocusTask(title: "Send the project update", firstStep: "Open the draft. Write just the first sentence.", minutes: 10),
                FocusTask(title: "Get ready to head out", firstStep: "Put your keys and water bottle by the door.", minutes: 5),
                FocusTask(title: "Clear a little desk space", firstStep: "Move three things off the desk.", minutes: 5)
            ],
            captured: [],
            anchor: TimeAnchor(title: "Leave for your appointment", date: now.addingTimeInterval(45 * 60))
        )
    }
}
