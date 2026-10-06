import SwiftUI

@main
struct NoPlexFocusApp: App {
    @StateObject private var model = FocusViewModel()

    var body: some Scene {
        WindowGroup {
            FocusView(model: model)
                .preferredColorScheme(.light)
        }
    }
}
