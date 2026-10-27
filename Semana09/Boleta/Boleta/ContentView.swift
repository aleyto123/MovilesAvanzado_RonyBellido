import SwiftUI

struct ContentView: View {
    @State private var sueldo = ""
    @State private var dias = "30"
    @State private var tieneHijos = false
    @State private var sistema = SistemaPension.onp
    @State private var afp = "AFP Ejemplo"
    @State private var horas25 = "0"
    @State private var horas35 = "0"
    @State private var adelanto = "0"
    @State private var resultado: ResultadoBoleta?
    @State private var comparacion: ResultadoBoleta?
    @State private var resumen = ""
    @State private var mensaje = ""

    private var firma: String {
        [sueldo, dias, String(tieneHijos), sistema.rawValue, afp, horas25, horas35, adelanto].joined(separator: "|")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                encabezado
                formulario
                if let resultado = resultado, let comparacion = comparacion {
                    BoletaView(resultado: resultado, comparacion: comparacion,
                               sistema: sistema, afp: afp, resumen: resumen)
                }
                Text("Importes en soles. Cada concepto se redondea a dos decimales antes de sumar. Sin renta de quinta categoría ni bases mínimas, según la actividad.")
                    .font(.caption).foregroundColor(.secondary)
            }
            .padding()
        }
        .accessibilityIdentifier("boletaScroll")
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: firma) { _ in
            resultado = nil
            comparacion = nil
            mensaje = ""
        }
    }

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Boleta de ejemplo").font(.title2.bold())
            Text("Del sueldo al neto").foregroundColor(.secondary)
            Text("Trabajador: Alex Ejemplo\nEmpresa: Horizonte Académico S.A.C.")
                .font(.footnote)
            Text("Personas y empresa ficticias").font(.caption).foregroundColor(.secondary)
        }
    }

    private var formulario: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Datos del mes").font(.headline)
            Text("Usa punto o coma decimal, sin separadores de miles. Escribe 0 cuando no haya horas extras o adelantos.")
                .font(.caption).foregroundColor(.secondary)

            campo("Sueldo básico", ejemplo: "Ej. 2500", texto: $sueldo, id: "sueldo")
            campo("Días laborados (1–30)", ejemplo: "Ej. 30", texto: $dias, id: "dias", entero: true)

            Text("¿Tiene hijos?").font(.subheadline)
            Picker("¿Tiene hijos?", selection: $tieneHijos) {
                Text("No").tag(false)
                Text("Sí").tag(true)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("tieneHijos")

            Text("Sistema de pensiones").font(.subheadline)
            Picker("Sistema de pensiones", selection: $sistema) {
                ForEach(SistemaPension.allCases, id: \.self) { pension in
                    Text(pension.rawValue).tag(pension)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("sistemaPension")

            if sistema == .afp {
                HStack {
                    Text("AFP")
                    Spacer()
                    Picker("AFP", selection: $afp) {
                        ForEach(Parametros.afps.keys.sorted(), id: \.self) { nombre in
                            Text(nombre).tag(nombre)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("selectorAFP")
                }
                Text(afp == "AFP Ejemplo"
                     ? "Tasas de prueba: fondo 10%, comisión 1.60% y seguro 1.35%."
                     : "SBS, octubre 2026. Comisión sobre flujo; bases simplificadas de la actividad.")
                    .font(.caption).foregroundColor(.secondary)
            }

            campo("Horas extras al 25%", ejemplo: "Ej. 4", texto: $horas25, id: "horas25")
            campo("Horas extras al 35%", ejemplo: "Ej. 4", texto: $horas35, id: "horas35")
            campo("Adelantos", ejemplo: "Ej. 200", texto: $adelanto, id: "adelanto")

            Button(action: calcular) {
                Text("Calcular boleta").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("calcularBoleta")

            if !mensaje.isEmpty {
                Text(mensaje).font(.subheadline).foregroundColor(.red)
                    .accessibilityIdentifier("errorValidacion")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func campo(_ titulo: String, ejemplo: String, texto: Binding<String>, id: String, entero: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(titulo).font(.subheadline)
            Spacer(minLength: 10)
            TextField(ejemplo, text: texto)
                .keyboardType(entero ? .numberPad : .decimalPad)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(width: 125)
                .accessibilityLabel(titulo)
                .accessibilityIdentifier(id)
        }
    }

    private func calcular() {
        resultado = nil
        comparacion = nil
        mensaje = ""
        do {
            let datos = try Formulario.datos(sueldo: sueldo, dias: dias, hijos: tieneHijos,
                sistema: sistema, afp: afp, horas25: horas25, horas35: horas35, adelanto: adelanto)
            let calculadora = Boleta()
            let boleta = try calculadora.calcular(datos)
            var alternativo = datos
            alternativo.sistema = sistema == .onp ? .afp : .onp
            let otraBoleta = try calculadora.calcular(alternativo)
            resumen = "\(datos.dias) días · \(sistema.rawValue)\(sistema == .afp ? " / " + afp : "") · \(tieneHijos ? "Con" : "Sin") asignación familiar"
            comparacion = otraBoleta
            resultado = boleta
        } catch {
            mensaje = error.localizedDescription
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View { ContentView() }
}
