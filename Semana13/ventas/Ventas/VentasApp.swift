import SwiftUI
import SwiftData

@main
struct VentasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Usuario.self, Producto.self, Cliente.self, Venta.self], isAutosaveEnabled: false)
    }
}
