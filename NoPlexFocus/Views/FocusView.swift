import SwiftUI

struct FocusView: View {
    @ObservedObject var model: FocusViewModel
    @State private var showingThoughts = false
    @State private var editingAnchor = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("a little less chaos").font(.caption).foregroundStyle(.secondary)
                            Text("Find your now.")
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        }
                        Spacer()
                        Image(systemName: "leaf").font(.title).foregroundStyle(FocusStyle.moss)
                            .accessibilityHidden(true)
                    }.padding(.vertical, 8)
                    AnchorView(anchor: model.state.anchor, now: context.date) { editingAnchor = true }
                    FocusCard(model: model, now: context.date)
                    if let next = model.next {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NEXT · IT CAN WAIT").font(.caption.weight(.bold)).tracking(1.5)
                                .foregroundStyle(.secondary)
                            Text(next.title).font(.headline)
                            Text("A \(next.minutes)-minute starting point")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }.focusCard()
                    }
                    if let feedback = model.feedback {
                        Text(feedback).font(.subheadline).foregroundStyle(FocusStyle.moss)
                            .accessibilityAddTraits(.updatesFrequently)
                    }
                    if let message = model.storageMessage {
                        Text(message).font(.subheadline).foregroundStyle(.red)
                    }
                    Button { showingThoughts = true } label: {
                        HStack {
                            Label("Parked thoughts", systemImage: "tray")
                            Spacer()
                            Text("\(model.state.captured.count)").monospacedDigit()
                            Image(systemName: "chevron.right")
                        }.font(.subheadline).padding(.vertical, 8)
                    }
                }.padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(FocusStyle.paper)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                CaptureBar(model: model)
            }
        }
        .foregroundStyle(FocusStyle.ink).tint(FocusStyle.moss)
        .sheet(isPresented: $showingThoughts) { ParkedThoughtsView(model: model) }
        .sheet(isPresented: $editingAnchor) { AnchorEditor(model: model) }
    }
}
