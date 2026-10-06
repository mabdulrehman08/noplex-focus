import SwiftUI

struct FocusCard: View {
    @ObservedObject var model: FocusViewModel
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("NOW · JUST THIS").font(.caption.weight(.bold)).tracking(1.5)
                .foregroundStyle(FocusStyle.moss)
            if let task = model.current {
                Text(task.title).font(.system(.title, design: .rounded, weight: .bold))
                Label(task.firstStep, systemImage: "arrow.turn.down.right")
                    .font(.body).fixedSize(horizontal: false, vertical: true)
                if model.hasSession {
                    session
                } else {
                    Text("Try \(task.minutes) minutes. You can stop anytime.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Button { model.start() } label: {
                        Label("Start small · \(task.minutes) min", systemImage: "play.fill")
                            .frame(maxWidth: .infinity).padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent).tint(FocusStyle.moss)
                }
                HStack {
                    Button("Done for now", systemImage: "checkmark.circle") { model.complete() }
                    Spacer()
                    Button("Try another") { model.deferCurrent() }
                }
                .font(.subheadline).padding(.top, 4)
            } else {
                Text("A little breathing room.")
                    .font(.system(.title, design: .rounded, weight: .bold))
                Text("Capture a thought below. When you’re ready, make one your next small step.")
            }
        }
        .focusCard()
    }

    private var session: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(countdown(model.remaining(at: now)))
                    .font(.system(.largeTitle, design: .rounded, weight: .medium)).monospacedDigit()
                    .accessibilityLabel("\(Int(ceil(model.remaining(at: now) / 60))) minutes remaining")
                Spacer()
                Text(model.isPaused ? "PAUSED" : "YOUR SMALL WINDOW")
                    .font(.caption.weight(.semibold))
            }
            ProgressView(value: model.progress(at: now)).tint(FocusStyle.moss)
            if model.remaining(at: now) == 0 {
                Text("A gentle check-in: enough for now, or two more minutes?")
                    .font(.subheadline).accessibilityAddTraits(.updatesFrequently)
            } else {
                Text("No need to finish everything. Just stay with this step.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            HStack {
                if model.remaining(at: now) > 0 {
                    Button(model.isPaused ? "Resume" : "Pause") { model.togglePause() }
                }
                Spacer()
                Button("+2 min") { model.addTwoMinutes() }
            }.buttonStyle(.bordered)
        }
    }
}
