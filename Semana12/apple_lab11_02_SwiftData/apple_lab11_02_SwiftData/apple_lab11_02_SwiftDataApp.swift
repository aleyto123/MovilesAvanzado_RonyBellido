import SwiftUI
import SwiftData

@main
struct apple_lab11_02_SwiftDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Alumno.self)
    }
}