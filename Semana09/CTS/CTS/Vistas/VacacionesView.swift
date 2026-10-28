import SwiftUI

struct VacacionesView: View {
    @State private var formulario = FormularioVacaciones()
    @State private var resultado: ResultadoVacaciones?
    @State private var error: String?
    @FocusState private var campoActivo: String?

    var body: some View {
        NavigationStack {
            Form {
                AlcanceCalculo()
                Section("Situación") {
                    Picker("Cálculo vacacional", selection: $formulario.situacion) {
                        ForEach(SituacionVacaciones.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("vac.situacion")
                    DatePicker(formulario.situacion == .goce ? "Primer día de descanso" : "Fecha de cese",
                               selection: $formulario.fecha, in: FechasFormulario.anio2026, displayedComponents: .date)
                }
                Section {
                    CamposRemuneracion(datos: $formulario.remuneracion, prefijo: "vac", foco: $campoActivo)
                    CampoNumero(titulo: "Promedio regular confirmado S/", texto: $formulario.promedio,
                                id: "vac.promedio", foco: $campoActivo)
                } header: { Text("Remuneración vacacional") } footer: {
                    Text("Ingresa solo complementos regulares computables ya validados según su naturaleza. El sexto de gratificación no integra esta base.")
                }
                Section {
                    Toggle("Año y récord ganados acreditados", isOn: $formulario.anioYRecord)
                        .accessibilityIdentifier("vac.anioRecord")
                    if formulario.anioYRecord {
                        Picker("Días de jornada por semana", selection: $formulario.semana) {
                            Text("5 días").tag(5)
                            Text("6 días").tag(6)
                        }.pickerStyle(.segmented)
                        CampoNumero(titulo: "Récord computable del año", texto: $formulario.record,
                                    id: "vac.record", entero: true, foco: $campoActivo)
                    }
                    CampoNumero(titulo: "Días ganados del período", texto: $formulario.ganados,
                                id: "vac.ganados", entero: true, foco: $campoActivo)
                    CampoNumero(titulo: "Días ya gozados", texto: $formulario.gozados,
                                id: "vac.gozados", entero: true, foco: $campoActivo)
                } header: { Text("Derecho adquirido") } footer: {
                    Text("Un período anual: 30 días calendario. Récord mínimo: 260 días con semana de seis días o 210 con semana de cinco. Incluye días equiparados por ley. El año completo también debe estar acreditado.")
                }
                if formulario.situacion == .goce {
                    Section {
                        CampoNumero(titulo: "Días solicitados de descanso", texto: $formulario.solicitados,
                                    id: "vac.solicitados", entero: true, foco: $campoActivo)
                        Toggle("Fraccionamiento legal acordado", isOn: $formulario.acuerdo)
                            .accessibilityIdentifier("vac.acuerdo")
                    } header: { Text("Salida de vacaciones") } footer: {
                        Text("Si fraccionas el descanso, acredita el acuerdo escrito: 15 días pueden distribuirse en bloques de 7 y 8; los otros 15, en períodos desde un día. El registro laboral y el acuerdo determinan qué bloque estás usando.")
                    }
                } else {
                    Section {
                        CampoNumero(titulo: "Meses del período trunco", texto: $formulario.mesesTruncos,
                                    id: "vac.mesesTruncos", entero: true, foco: $campoActivo)
                        CampoNumero(titulo: "Días truncos adicionales", texto: $formulario.diasTruncos,
                                    id: "vac.diasTruncos", entero: true, foco: $campoActivo)
                        CampoNumero(titulo: "Días no computables truncos", texto: $formulario.faltasTruncas,
                                    id: "vac.faltasTruncas", entero: true, foco: $campoActivo)
                        Toggle("Cumplió un mes con el empleador", isOn: $formulario.primerMes)
                        CampoNumero(titulo: "Días de vacaciones adelantados", texto: $formulario.adelantados,
                                    id: "vac.adelantados", foco: $campoActivo)
                    } header: { Text("Período trunco al cese") } footer: {
                        Text("Es un período distinto al año ganado. No descuentes las faltas dos veces. El requisito de un mes se refiere al vínculo con el empleador, no al nuevo año vacacional.")
                    }
                    Section {
                        CampoNumero(titulo: "Días con indemnización procedente", texto: $formulario.indemnizables,
                                    id: "vac.indemnizables", entero: true, foco: $campoActivo)
                        Toggle("Gerente que decidió no descansar", isOn: $formulario.gerente)
                    } header: { Text("Indemnización vacacional") } footer: {
                        Text("Registra solo días cuyo plazo legal de goce venció y que aún no han sido indemnizados. No se deducen automáticamente del saldo. La exclusión gerencial exige que el gerente o representante haya decidido no descansar.")
                    }
                }
                Section {
                    Button("Calcular vacaciones", action: calcular)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .accessibilityIdentifier("vac.calcular")
                }
                if let error = error { MensajeError(texto: error, id: "vac.error") }
                if let resultado = resultado {
                    Section("Resultado vacacional") {
                        FilaImporte(titulo: formulario.situacion == .goce ? "Pago vacacional bruto" : "Total vacacional al cese",
                                    valor: resultado.total, destacado: true, id: "vac.total")
                        FilaImporte(titulo: "Asignación familiar", valor: resultado.asignacion)
                        FilaImporte(titulo: "Remuneración computable", valor: resultado.baseComputable)
                        LabeledContent("Saldo de días ganados", value: String(resultado.saldoGanado))
                    }
                    if let goce = resultado.goce {
                        Section {
                            FilaImporte(titulo: "Pago antes del descanso", valor: goce.pagoVacacional)
                            LabeledContent("Saldo después del descanso", value: String(goce.saldoDias))
                            LabeledContent("Último día de descanso", value: goce.ultimoDia.texto)
                            FilaImporte(titulo: "Equivalente por otros días del mes", valor: goce.equivalenteOtrosDias)
                            FilaImporte(titulo: "Equivalente mensual", valor: goce.equivalenteMensual)
                        } header: { Text("Durante el descanso") } footer: {
                            Text("Pago = base ÷ 30 × días de descanso. Se abona antes de salir. La comparación mensual ilustra un mes convencional de 30 días con el resto trabajado: el pago vacacional forma parte del sueldo; no es otro sueldo completo adicional.")
                        }
                    }
                    if let cese = resultado.cese {
                        Section {
                            LabeledContent("Días truncos computables", value: String(cese.diasTruncosComputables))
                            FilaImporte(titulo: "Truncas antes de compensación", valor: cese.truncasAntesDelAdelanto)
                            FilaImporte(titulo: "Adelanto compensado", valor: cese.compensacionAdelanto)
                            FilaImporte(titulo: "Vacaciones truncas pendientes", valor: cese.truncasPendientes)
                            FilaImporte(titulo: "Ganadas no gozadas", valor: cese.ganadasPendientes)
                            FilaImporte(titulo: "Indemnización procedente", valor: cese.indemnizacion)
                        } header: { Text("Desglose al cese") } footer: {
                            Text("Truncas = base × (meses ÷ 12 + días ÷ 360), menos adelanto compensable. Ganadas e indemnización: base ÷ 30 × días correspondientes. El exceso adelantado no crea deuda. La llamada triple remuneración incluye el sueldo trabajado, normalmente ya pagado; no se vuelve a sumarlo aquí.")
                        }
                    }
                }
                BasesLegales(fuentes: [.vacaciones, .fraccionamiento, .rmv, .rmvAnterior, .asignacion])
            }
            .navigationTitle("Vacaciones")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") { campoActivo = nil }
                }
            }
            .onChange(of: formulario) { _ in resultado = nil; error = nil }
            .onChange(of: formulario.anioYRecord) { acreditado in
                if !acreditado { formulario.ganados = "0"; formulario.gozados = "0"; formulario.indemnizables = "0" }
            }
        }
    }

    private func calcular() {
        campoActivo = nil
        resultado = nil
        error = nil
        do { resultado = try CalculadoraVacaciones().calcular(formulario.datos()) }
        catch { self.error = error.localizedDescription }
    }
}
