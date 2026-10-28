import SwiftUI

struct GratificacionView: View {
    @State private var formulario = FormularioGratificacion()
    @State private var resultado: ResultadoGratificacion?
    @State private var error: String?
    @FocusState private var campoActivo: String?

    var body: some View {
        NavigationStack {
            Form {
                AlcanceCalculo()
                Section {
                    Picker("Gratificación", selection: $formulario.tipo) {
                        ForEach(TipoGratificacion.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented).accessibilityIdentifier("grati.tipo")
                    DatePicker("Fecha de ingreso", selection: $formulario.ingreso,
                               in: FechasFormulario.ingreso, displayedComponents: .date)
                    if formulario.tipo == .trunca {
                        DatePicker("Fecha de cese", selection: $formulario.cese,
                                   in: FechasFormulario.anio2026, displayedComponents: .date)
                    } else {
                        Toggle("Cumple el requisito al pago", isOn: $formulario.requisitoAlPago)
                    }
                    if let base = formulario.periodo.fechaBase {
                        LabeledContent("Fecha base del sueldo", value: base.texto)
                    }
                    CampoNumero(titulo: "Días no computables", texto: $formulario.faltas,
                                id: "grati.faltas", entero: true, foco: $campoActivo)
                } header: { Text("Período de gratificación · 2026") } footer: {
                    Text("Solo cuentan meses calendario completos. Las vacaciones, licencias pagadas y supuestos legales asimilados cumplen el requisito al pago. Los días no computables deben pertenecer a meses incluidos.")
                }
                Section {
                    CamposRemuneracion(datos: $formulario.remuneracion, prefijo: "grati", foco: $campoActivo)
                    Picker("Cobertura de salud", selection: $formulario.cobertura) {
                        ForEach(CoberturaSalud.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented).accessibilityIdentifier("grati.cobertura")
                } header: { Text("Remuneración y cobertura") } footer: {
                    Text("Sueldo vigente al 30 de junio o al 30 de noviembre. Para una gratificación trunca, usa el mes inmediato anterior al cese. No agregues un sexto de gratificación anterior.")
                }
                Section {
                    CamposVariables(datos: $formulario.variables, meses: formulario.periodo.mesesDelSemestre,
                                    prefijo: "grati", foco: $campoActivo)
                }
                Section {
                    Button("Calcular gratificación", action: calcular)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .accessibilityIdentifier("grati.calcular")
                }
                if let error = error { MensajeError(texto: error, id: "grati.error") }
                if let resultado = resultado {
                    Section("Resultado de gratificación") {
                        FilaImporte(titulo: "Gratificación más bono bruto", valor: resultado.total, destacado: true, id: "grati.total")
                        FilaImporte(titulo: "Asignación familiar", valor: resultado.asignacion)
                        FilaImporte(titulo: "Promedio de horas extras", valor: resultado.promedioExtras)
                        FilaImporte(titulo: "Promedio de comisiones", valor: resultado.promedioComisiones)
                        FilaImporte(titulo: "Remuneración computable", valor: resultado.baseComputable)
                        LabeledContent("Meses completos", value: String(resultado.cantidadMeses))
                        FilaImporte(titulo: "Importe por meses", valor: resultado.importePorMeses)
                        FilaImporte(titulo: "Descuento por días no computables", valor: resultado.descuentoPorDias)
                        FilaImporte(titulo: "Gratificación bruta", valor: resultado.gratificacion)
                        FilaImporte(titulo: "Bono \(formulario.cobertura == .eps ? "6.75%" : "9%")", valor: resultado.bonificacion)
                    }
                    Section {
                        DisclosureGroup("Meses incluidos") {
                            ForEach(Array(resultado.meses.enumerated()), id: \.offset) { indice, mes in
                                LabeledContent(mes.nombreMes, value: resultado.mesesCompletos[indice] ? "Completo" : "No incluido")
                            }
                        }
                        DisclosureGroup("Cómo se calculó") {
                            Text("Gratificación = base × meses completos ÷ 6 − base × días no computables ÷ 180.")
                            Text("Bonificación = gratificación bruta × 9% con EsSalud, o × 6.75% con EPS. Ambos pagos se redondean a dos decimales antes de sumarlos.")
                            Text("No se descuentan aportes ONP o AFP de la gratificación legal. La bonificación no integra la base de CTS.")
                        }
                    } footer: {
                        Text("El total es bruto. La renta de quinta categoría y descuentos legales, judiciales o autorizados requieren una liquidación aparte. Gratificación trunca: pago dentro de las 48 horas del cese.")
                    }
                }
                BasesLegales(fuentes: [.gratificacion, .bonificacion, .rmv, .rmvAnterior, .asignacion])
            }
            .navigationTitle("Gratificación")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") { campoActivo = nil }
                }
            }
            .onChange(of: formulario) { _ in resultado = nil; error = nil }
            .onChange(of: formulario.periodo.mesesDelSemestre) { _ in formulario.variables = FormularioVariables() }
        }
    }

    private func calcular() {
        campoActivo = nil
        resultado = nil
        error = nil
        do { resultado = try CalculadoraGratificacion().calcular(formulario.datos()) }
        catch { self.error = error.localizedDescription }
    }
}
