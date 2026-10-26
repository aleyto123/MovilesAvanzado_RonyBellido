import SwiftUI
import UIKit
import BoletaCore

struct ContentView: View {
    @State private var sueldo = "2500"
    @State private var dias = "30"
    @State private var hijos = false
    @State private var sistema = SistemaPension.onp
    @State private var afp = "AFP Ejemplo"
    @State private var horas25 = "0"
    @State private var horas35 = "0"
    @State private var adelanto = "0"
    @State private var resultado: ResultadoBoleta?
    @State private var comparacion: ResultadoBoleta?
    @State private var error = ""
    @State private var resumen = ""

    private let azul = Color(red: 0.08, green: 0.20, blue: 0.33)
    private let verde = Color(red: 0.03, green: 0.42, blue: 0.34)
    private var firma: String { [sueldo, dias, String(hijos), sistema.rawValue, afp, horas25, horas35, adelanto].joined(separator: "|") }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                encabezado
                VStack(alignment: .leading, spacing: 16) {
                    Text("Datos del mes").font(.title2.bold()).foregroundColor(azul)
                    Text("Montos en soles, sin separador de miles. Puedes usar punto o coma decimal.")
                        .font(.footnote).foregroundColor(.secondary)
                    campo("Sueldo básico", texto: $sueldo)
                    campo("Días laborados (1–30)", texto: $dias, teclado: .numberPad)
                    Text("¿Tiene hijos?").font(.subheadline.bold())
                    Picker("¿Tiene hijos?", selection: $hijos) {
                        Text("No").tag(false)
                        Text("Sí").tag(true)
                    }.pickerStyle(.segmented)
                    Text("Sistema de pensiones").font(.subheadline.bold())
                    Picker("Sistema de pensiones", selection: $sistema) {
                        ForEach(SistemaPension.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                    if sistema == .afp {
                        HStack {
                            Text("AFP").font(.subheadline.bold())
                            Spacer()
                            Picker("AFP", selection: $afp) {
                                ForEach(Parametros.afps.keys.sorted(), id: \.self) { Text($0).tag($0) }
                            }.pickerStyle(.menu)
                        }
                        Text(afp == "AFP Ejemplo" ? "Tasas de prueba: fondo 10%, comisión 1.60%, seguro 1.35%." : "SBS octubre 2026 · comisión sobre flujo. Cálculo simplificado de la actividad.")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    campo("Horas extras al 25%", texto: $horas25)
                    campo("Horas extras al 35%", texto: $horas35)
                    campo("Adelantos", texto: $adelanto)
                    Button(action: calcular) {
                        Text("Calcular boleta").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 8)
                    }.buttonStyle(.borderedProminent).tint(verde)
                    if !error.isEmpty {
                        Text(error).foregroundColor(.red).font(.subheadline)
                            .accessibilityLabel("Error: \(error)")
                    }
                }.padding(20).background(Color(uiColor: .secondarySystemGroupedBackground)).cornerRadius(20)

                if let r = resultado {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Tu boleta").font(.title2.bold()).foregroundColor(azul)
                        Text(resumen).font(.footnote).foregroundColor(.secondary)
                        bloque("REMUNERACIONES", conceptos: r.remuneraciones)
                        fila("Total remuneraciones", monto: r.totalRemuneraciones, destacado: true)
                        bloque("RETENCIONES / DESCUENTOS", conceptos: r.descuentos)
                        fila("Total descuentos", monto: r.totalDescuentos, destacado: true)
                        bloque("APORTACIONES DEL EMPLEADOR", conceptos: r.aportaciones)
                        Text("EsSalud lo paga el empleador y no reduce tu neto.")
                            .font(.caption).foregroundColor(.secondary)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NETO A PAGAR").font(.caption.bold())
                            Text(r.neto.soles).font(.largeTitle.bold()).minimumScaleFactor(0.6)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(20)
                            .foregroundColor(.white).background(verde).cornerRadius(16)
                        if r.neto < 0 {
                            Text("Los descuentos superan las remuneraciones. El neto negativo representa un saldo pendiente.")
                                .font(.footnote).foregroundColor(.red)
                        }
                        fila("Costo para el empleador", monto: r.costoEmpleador)
                        if let otro = comparacion {
                            Text("Comparación del neto este mes").font(.headline)
                            HStack(alignment: .top, spacing: 14) {
                                comparador("ONP", monto: sistema == .onp ? r.neto : otro.neto)
                                comparador(afp, monto: sistema == .afp ? r.neto : otro.neto)
                            }
                        }
                    }.padding(20).background(Color(uiColor: .secondarySystemGroupedBackground)).cornerRadius(20)
                }
                Text("RMV académica S/ 1,230 · Asignación familiar 10% · ONP 13% · EsSalud 9%. Sin renta de quinta categoría ni bases mínimas. Las AFP usan comisión sobre flujo y las bases simplificadas de la actividad.")
                    .font(.caption).foregroundColor(.secondary)
            }.padding(18).frame(maxWidth: 640).frame(maxWidth: .infinity)
        }.background(Color(uiColor: .systemGroupedBackground)).tint(verde)
            .onChange(of: firma) { _ in resultado = nil; comparacion = nil; error = "" }
    }

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SEMANA 09 / GRUPO B").font(.caption.bold()).foregroundColor(verde)
            Text("Boleta de ejemplo").font(.largeTitle.bold()).foregroundColor(azul)
            Text("Del sueldo al neto").font(.title3).foregroundColor(.secondary)
            Text("Trabajador: Alex Ejemplo\nEmpresa: Horizonte Académico S.A.C.\nPersonas y empresa ficticias")
                .font(.footnote).foregroundColor(.secondary)
        }.padding(.vertical, 8)
    }

    private func campo(_ titulo: String, texto: Binding<String>, teclado: UIKeyboardType = .decimalPad) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo).font(.subheadline.bold())
            TextField(titulo, text: texto).keyboardType(teclado).textFieldStyle(.roundedBorder)
                .accessibilityLabel(titulo)
        }
    }

    private func fila(_ nombre: String, monto: Decimal, destacado: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(nombre)
            Spacer(minLength: 12)
            Text(monto.soles).monospacedDigit().multilineTextAlignment(.trailing)
        }.font(destacado ? .headline : .subheadline)
    }

    private func bloque(_ titulo: String, conceptos: [Concepto]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titulo).font(.caption.bold()).foregroundColor(verde)
            ForEach(conceptos) { fila($0.nombre, monto: $0.monto) }
        }
    }

    private func comparador(_ titulo: String, monto: Decimal) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo).font(.caption).foregroundColor(.secondary)
            Text(monto.soles).font(.headline).monospacedDigit()
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func calcular() {
        resultado = nil; comparacion = nil; error = ""
        do {
            let datos = try Formulario.datos(sueldo: sueldo, dias: dias, hijos: hijos, sistema: sistema,
                afp: afp, horas25: horas25, horas35: horas35, adelanto: adelanto)
            let calculadora = Boleta()
            let calculado = try calculadora.calcular(datos)
            var alternativo = datos
            alternativo.sistema = sistema == .onp ? .afp : .onp
            comparacion = try calculadora.calcular(alternativo)
            resumen = "\(dias) días · \(sistema.rawValue)\(sistema == .afp ? " / " + afp : "") · \(hijos ? "Con" : "Sin") asignación familiar"
            resultado = calculado
        } catch { self.error = error.localizedDescription }
    }
}
