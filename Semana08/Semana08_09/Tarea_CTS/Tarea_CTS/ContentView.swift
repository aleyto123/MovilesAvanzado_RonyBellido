import SwiftUI

struct ContentView: View {
    // @State guarda lo que se escribe en cada campo.
    @State private var sueldo = ""
    @State private var gratificacion = ""
    @State private var meses = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Calculadora de CTS")
                .font(.title)
                .fontWeight(.bold)

            Text("Ingrese los datos del trabajador.")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Sueldo mensual (S/)")
                TextField("Ejemplo: 3000", text: $sueldo)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Gratificación percibida (S/)")
                TextField("Ejemplo: 3000", text: $gratificacion)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Meses trabajados")
                TextField("Entre 0 y 6 meses", text: $meses)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
