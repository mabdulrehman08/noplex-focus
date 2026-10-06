import SwiftUI

struct CaptureBar: View {
    @ObservedObject var model: FocusViewModel
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 12) {
            TextField("A thought to park…", text: $text, axis: .vertical)
                .lineLimit(1...3).submitLabel(.done).focused($focused)
                .onSubmit(save)
                .accessibilityLabel("Capture a thought for later")
            Button(action: save) {
                Image(systemName: "plus").font(.title3.weight(.bold))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.borderedProminent).tint(FocusStyle.moss)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityLabel("Save thought")
        }
        .padding(14).background(FocusStyle.paper)
    }

    private func save() {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        model.capture(text)
        text = ""
        focused = false
    }
}

struct ParkedThoughtsView: View {
    @ObservedObject var model: FocusViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Nothing needs sorting right now. When you’re ready, choose one thought as your next five-minute step.")
                        .foregroundStyle(.secondary)
                }
                if model.state.captured.isEmpty {
                    Text("No parked thoughts. There’s space here whenever you need it.")
                }
                ForEach(Array(model.state.captured.enumerated()), id: \.offset) { index, title in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(title)
                        Button("Make this Next", systemImage: "arrow.right.circle") {
                            model.promoteCapture(at: index)
                            dismiss()
                        }.font(.subheadline)
                    }.padding(.vertical, 6)
                        .swipeActions {
                            Button("Remove", role: .destructive) { model.removeCapture(at: index) }
                        }
                }
            }
            .navigationTitle("Parked thoughts")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Close") { dismiss() } } }
        }.tint(FocusStyle.moss)
    }
}

struct AnchorEditor: View {
    @ObservedObject var model: FocusViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var date: Date

    init(model: FocusViewModel) {
        self.model = model
        _title = State(initialValue: model.state.anchor.title)
        _date = State(initialValue: model.state.anchor.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("One real-world anchor") {
                    TextField("What’s coming up?", text: $title)
                    DatePicker("When", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                Section {
                    Text("Use a departure, meal, or meeting to give the day a visible edge.")
                }
            }
            .navigationTitle("Time anchor")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        model.updateAnchor(title: title, date: date)
                        dismiss()
                    }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }.tint(FocusStyle.moss)
    }
}
