import Foundation

enum SituacionVacaciones: String, CaseIterable, Identifiable {
    case goce = "Goce"
    case cese = "Cese"
    var id: String { rawValue }
}

struct DatosVacaciones: Equatable {
    var situacion: SituacionVacaciones = .goce
    var remuneracion = RemuneracionBase()
    var fecha = FechaLaboral(2026, 11, 2)
    var promedioRegular: Decimal = 0
    var anioYRecordAcreditados = true
    var diasPorSemana = 6
    var diasComputablesRecord = 260
    var diasGanados = 30
    var diasGozados = 0
    var diasSolicitados = 15
    var fraccionamientoLegalAcordado = true
    var mesesTruncos = 4
    var diasTruncos = 15
    var diasNoComputables = 0
    var cumplioPrimerMes = true
    var diasIndemnizables = 0
    var gerenteQueDecidioNoDescansar = false
    var diasAdelantados: Decimal = 0
}

struct DetalleGoce {
    let pagoVacacional: Decimal
    let saldoDias: Int
    let ultimoDia: FechaLaboral
    let equivalenteOtrosDias: Decimal
    let equivalenteMensual: Decimal
}

struct DetalleCese {
    let diasTruncosComputables: Int
    let truncasAntesDelAdelanto: Decimal
    let compensacionAdelanto: Decimal
    let truncasPendientes: Decimal
    let ganadasPendientes: Decimal
    let indemnizacion: Decimal
}

struct ResultadoVacaciones {
    let asignacion: Decimal
    let baseComputable: Decimal
    let saldoGanado: Int
    let goce: DetalleGoce?
    let cese: DetalleCese?
    let total: Decimal
}

final class CalculadoraVacaciones {
    func calcular(_ datos: DatosVacaciones) throws -> ResultadoVacaciones {
        try datos.remuneracion.validar()
        try ReglasLaborales.validarFecha(datos.fecha)
        try Dinero.validar(datos.promedioRegular, campo: "Promedio regular confirmado")
        try exigir((0...30).contains(datos.diasGanados),
                   "Registra de 0 a 30 días ganados de un solo período anual.")
        try exigir((0...datos.diasGanados).contains(datos.diasGozados),
                   "Los días ya gozados no pueden superar los días ganados del período.")
        if datos.anioYRecordAcreditados {
            try exigir([5, 6].contains(datos.diasPorSemana), "Elige una semana habitual de cinco o seis días.")
            let minimo = datos.diasPorSemana == 6 ? 260 : 210
            try exigir(datos.diasComputablesRecord >= minimo,
                       "Con semana de \(datos.diasPorSemana) días se exige un récord de al menos \(minimo) días computables en el año.")
        }
        let asignacion = try ReglasLaborales.asignacion(acreditada: datos.remuneracion.asignacionAcreditada, en: datos.fecha)
        // D.S. 012-92-TR, art. 16: las remuneraciones periódicas no integran esta base.
        let base = datos.remuneracion.sueldo + datos.remuneracion.otrosFijos + datos.promedioRegular + asignacion
        let saldo = datos.diasGanados - datos.diasGozados

        switch datos.situacion {
        case .goce:
            try exigir(datos.anioYRecordAcreditados,
                       "Para este goce se requiere acreditar el año completo y el récord vacacional.")
            try exigir(datos.diasSolicitados >= 1 && datos.diasSolicitados <= saldo,
                       "Los días solicitados deben estar entre 1 y el saldo ganado disponible.")
            try exigir(datos.diasSolicitados == 30 || datos.fraccionamientoLegalAcordado,
                       "El descanso fraccionado exige acuerdo escrito y respetar los bloques legales de 15 días y de 7/8 días.")
            let pago = Dinero.redondear(base * Decimal(datos.diasSolicitados) / Decimal(ReglasLaborales.diasMes))
            let otrosDias = Dinero.redondear(base * Decimal(ReglasLaborales.diasMes - datos.diasSolicitados) / Decimal(ReglasLaborales.diasMes))
            let goce = DetalleGoce(pagoVacacional: pago, saldoDias: saldo - datos.diasSolicitados,
                                  ultimoDia: datos.fecha.sumandoDias(datos.diasSolicitados - 1),
                                  equivalenteOtrosDias: otrosDias, equivalenteMensual: pago + otrosDias)
            return ResultadoVacaciones(asignacion: asignacion, baseComputable: base,
                                       saldoGanado: saldo, goce: goce, cese: nil, total: pago)
        case .cese:
            try exigir((0...11).contains(datos.mesesTruncos) && (0...29).contains(datos.diasTruncos),
                       "El período trunco debe tener de 0 a 11 meses y de 0 a 29 días adicionales.")
            let diasAntesDeFaltas = datos.mesesTruncos * 30 + datos.diasTruncos
            try exigir((0...diasAntesDeFaltas).contains(datos.diasNoComputables),
                       "Los días no computables no pueden superar el período trunco.")
            try exigir((0...30).contains(datos.diasIndemnizables),
                       "Registra de 0 a 30 días con indemnización legal procedente de un período.")
            try Dinero.validar(datos.diasAdelantados, campo: "Días de vacaciones adelantados")
            try exigir(datos.anioYRecordAcreditados || (saldo == 0 && datos.diasIndemnizables == 0),
                       "Sin año y récord acreditados no corresponden saldo ganado ni indemnización de ese período.")
            try exigir(datos.cumplioPrimerMes || (datos.mesesTruncos == 0 && datos.diasGanados == 0 && datos.diasIndemnizables == 0),
                       "Sin primer mes de vínculo no puede registrarse un año ganado ni meses de vacaciones truncas.")
            let dias = diasAntesDeFaltas - datos.diasNoComputables
            let trunco = datos.cumplioPrimerMes ? base * Decimal(dias) / Decimal(ReglasLaborales.diasAnio) : 0
            // D. Leg. 1405: el exceso de vacaciones adelantadas no crea deuda del trabajador.
            let compensacion = min(trunco, base * datos.diasAdelantados / Decimal(ReglasLaborales.diasMes))
            let truncas = Dinero.redondear(max(0, trunco - compensacion))
            let ganadas = datos.anioYRecordAcreditados ? Dinero.redondear(base * Decimal(saldo) / Decimal(ReglasLaborales.diasMes)) : 0
            let indemnizacion = datos.gerenteQueDecidioNoDescansar ? 0
                : Dinero.redondear(base * Decimal(datos.diasIndemnizables) / Decimal(ReglasLaborales.diasMes))
            let cese = DetalleCese(diasTruncosComputables: dias, truncasAntesDelAdelanto: trunco,
                                  compensacionAdelanto: compensacion, truncasPendientes: truncas,
                                  ganadasPendientes: ganadas, indemnizacion: indemnizacion)
            return ResultadoVacaciones(asignacion: asignacion, baseComputable: base,
                                       saldoGanado: saldo, goce: nil, cese: cese,
                                       total: truncas + ganadas + indemnizacion)
        }
    }
}
