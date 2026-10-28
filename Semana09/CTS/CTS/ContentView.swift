import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CTSView()
                .tabItem { Label("CTS", systemImage: "banknote") }
            GratificacionView()
                .tabItem { Label("Gratificación", systemImage: "gift") }
            VacacionesView()
                .tabItem { Label("Vacaciones", systemImage: "sun.max") }
        }
        .environment(\.locale, Locale(identifier: "es_PE"))
        .environment(\.calendar, FechaLaboral.calendario)
        .environment(\.timeZone, FechaLaboral.calendario.timeZone)
    }
}
