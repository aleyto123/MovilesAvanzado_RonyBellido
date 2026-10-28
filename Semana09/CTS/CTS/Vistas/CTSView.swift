import SwiftUI

struct CTSView: View {
    @State private var formulario = FormularioCTS()
    @State private var resultado: ResultadoCTS?
    @State private var error: String?
    @FocusState private var campoActivo: String?

    var body: some View {
        NavigationStack {
            Form {
                AlcanceCalculo()
                Section("Período CTS") {
                    Picker("Tipo de cálculo", selection: $formulario.tipo) {
                        ForEach(TipoCTS.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented).accessibilityIdentifier("cts.tipo")
                    DatePicker(formulario.tipo == .trunca ? "Fecha de cese" : "Fecha base", selection: $formulario.fecha,
                               in: FechasFormulario.anio2026, displayedComponents: .date)
                    CampoNumero(titulo: "Meses completos", texto: $formulario.meses, id: "cts.meses", entero: true, foco: $campoActivo)
                    CampoNumero(titulo: "Días adicionales", texto: $formulario.dias, id: "cts.dias", entero: true, foco: $campoActivo)
                    CampoNumero(titulo: "Días no computables", texto: $formulario.faltas, id: "cts.faltas", entero: true, foco: $campoActivo)
                    CampoNumero(titulo: "Días pendientes previos", texto: $formulario.arrastre, id: "cts.arrastre", entero: true, foco: $campoActivo)
                    Toggle("Cumplió un mes con el empleador", isOn: $formulario.primerMes)
                }
                Section {
                    CamposRemuneracion(datos: $formulario.remuneracion, prefijo: "cts", foco: $campoActivo)
                    CampoNumero(titulo: "Gratificación anterior percibida S/", texto: $formulario.gratificacion,
                                id: "cts.gratificacion", foco: $campoActivo)
                } header: { Text("Remuneración computable") } footer: {
                    Text("Usa el sueldo de abril u octubre; al cesar, el vigente al cese. La gratificación anterior es el importe legal percibido, sin el bono del 9% o 6.75%. El arrastre solo admite una fracción menor a un mes aplazada del semestre previo.")
                }
                Section {
                    CamposVariables(datos: $formulario.variables, meses: formulario.mesesDelSemestre,
                                    prefijo: "cts", foco: $campoActivo)
                }
                Section {
                    Button("Calcular CTS", action: calcular)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .accessibilityIdentifier("cts.calcular")
                }
                if let error = error { MensajeError(texto: error, id: "cts.error") }
                if let resultado = resultado {
                    Section("Resultado CTS") {
                        FilaImporte(titulo: "CTS por depositar o pagar", valor: resultado.total, destacado: true, id: "cts.total")
                        if let aviso = resultado.aviso { Text(aviso).foregroundColor(.secondary) }
                        FilaImporte(titulo: "RMV de la fecha base", valor: resultado.rmv)
                        FilaImporte(titulo: "Asignación familiar", valor: resultado.asignacion)
                        FilaImporte(titulo: "Promedio de horas extras", valor: resultado.promedioExtras)
                        FilaImporte(titulo: "Promedio de comisiones", valor: resultado.promedioComisiones)
                        FilaImporte(titulo: "Un sexto de gratificación", valor: resultado.sextoGratificacion)
                        FilaImporte(titulo: "Remuneración computable", valor: resultado.baseComputable)
                        LabeledContent("Días computables", value: String(resultado.diasComputables))
                        LabeledContent("Pago referencial", value: resultado.fechaPagoReferencial.texto)
                    }
                    Section {
                        DisclosureGroup("Cómo se calculó") {
                            Text("Base = básico + asignación + otros fijos + promedios regulares + gratificación anterior ÷ 6.")
                            Text("CTS = base × días computables ÷ 360. Equivale a base × meses ÷ 12 + base × días ÷ 360.")
                            Text("Se conserva la precisión de los sextos y promedios; el pago final se redondea a dos decimales.")
                        }
                    } footer: {
                        Text("Depósito: hasta el día 15 de mayo o noviembre, trasladado al hábil siguiente si corresponde. La fecha referencial ajusta sábados y domingos; revisa feriados aplicables. Al cese, el plazo es de 48 horas.")
                    }
                }
                BasesLegales(fuentes: [.cts, .rmv, .rmvAnterior, .asignacion])
            }
            .navigationTitle("CTS")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") { campoActivo = nil }
                }
            }
            .onChange(of: formulario) { _ in resultado = nil; error = nil }
            .onChange(of: formulario.mesesDelSemestre) { _ in formulario.variables = FormularioVariables() }
        }
    }

    private func calcular() {
        campoActivo = nil
        resultado = nil
        error = nil
        do { resultado = try CalculadoraCTS().calcular(formulario.datos()) }
        catch { self.error = error.localizedDescription }
    }
}
