import SwiftUI

/// Main entry point for the app.
@main
struct NextBikeRouterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Task {
                        await appMain(url)
                    }
                }
        }
    }
}
