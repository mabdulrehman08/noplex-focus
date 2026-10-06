import SwiftUI

struct AnchorView: View {
    let anchor: TimeAnchor
    let now: Date
    let edit: () -> Void

    private var minutes: Int { Int(ceil(anchor.date.timeIntervalSince(now) / 60)) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("TIME ANCHOR", systemImage: "sun.max")
                    .font(.caption.weight(.bold)).tracking(1.5)
                Spacer()
                Button("Edit", action: edit).font(.subheadline)
            }
            Text(minutes > 0 ? "In \(minutes) min" : "Your anchor is here")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            HStack(alignment: .firstTextBaseline) {
                Text(anchor.title).font(.headline)
                Spacer()
                Text(anchor.date, style: .time).font(.subheadline).monospacedDigit()
            }
            // Each mark represents five minutes in the hour before the anchor.
            HStack(spacing: 5) {
                ForEach(0..<12) { index in
                    Capsule().fill(index < min(12, max(0, Int(ceil(Double(minutes) / 5))))
                        ? FocusStyle.moss : FocusStyle.ink.opacity(0.10))
                        .frame(height: index.isMultiple(of: 3) ? 18 : 11)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(minutes > 0 ? "\(minutes) minutes until \(anchor.title)" : "\(anchor.title) is due")
            Text(minutes > 60 ? "More than an hour away · each mark is 5 min" : "Each mark is 5 min · a little space to land")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(22).background(FocusStyle.pale, in: RoundedRectangle(cornerRadius: 26))
    }
}
