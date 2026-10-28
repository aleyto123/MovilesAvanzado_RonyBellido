import Foundation

enum TipoCTS: String, CaseIterable, Identifiable {
    case semestral = "Semestral"
    case trunca = "Trunca"
    var id: String { rawValue }
}

struct DatosCTS: Equatable {
    var tipo: TipoCTS = .semestral
    var remuneracion = RemuneracionBase()
    var fechaBase = FechaLaboral(2026, 10, 31)
    var gratificacionPercibida: Decimal = 3000
    var meses = 6
    var dias = 0
    var diasNoComputables = 0
    var diasArrastrados = 0
    var cumplioPrimerMes = true
    var variables = VariablesSemestrales()

    var mesesDelSemestre: [FechaLaboral] {
        let primerMes = fechaBase.mes <= 4 || fechaBase.mes >= 11 ? 11 : 5
        let anio = fechaBase.anio - (fechaBase.mes <= 4 ? 1 : 0)
        let inicio = FechaLaboral(anio, primerMes, 1)
        return (0..<6).map { inicio.sumandoMeses($0) }
    }
}

struct ResultadoCTS {
    let rmv: Decimal
    let asignacion: Decimal
    let promedioExtras: Decimal
    let promedioComisiones: Decimal
    let sextoGratificacion: Decimal
    let baseComputable: Decimal
    let diasComputables: Int
    let importeProporcional: Decimal
    let total: Decimal
    let fechaPagoReferencial: FechaLaboral
    let aviso: String?
}

final class CalculadoraCTS {
    func calcular(_ datos: DatosCTS) throws -> ResultadoCTS {
        try datos.remuneracion.validar()
        try ReglasLaborales.validarFecha(datos.fechaBase)
        try Dinero.validar(datos.gratificacionPercibida, campo: "Gratificación anterior percibida")
        try exigir((0...6).contains(datos.meses) && (0...29).contains(datos.dias),
                   "CTS: utiliza de 0 a 6 meses y de 0 a 29 días adicionales.")
        try exigir(datos.meses * 30 + datos.dias <= 180,
                   "El período CTS actual no puede superar seis meses; con seis meses no añadas días.")
        try exigir((0...29).contains(datos.diasArrastrados),
                   "El arrastre debe ser la fracción acreditada de 0 a 29 días del semestre previo.")
        let diasAntesDeFaltas = datos.meses * 30 + datos.dias + datos.diasArrastrados
        try exigir((0...diasAntesDeFaltas).contains(datos.diasNoComputables),
                   "Los días no computables no pueden superar el tiempo registrado.")
        try exigir(datos.cumplioPrimerMes || (datos.meses == 0 && datos.diasArrastrados == 0),
                   "Si aún no cumple su primer mes de vínculo, registra cero meses y ningún arrastre.")
        if datos.tipo == .semestral {
            try exigir([4, 10].contains(datos.fechaBase.mes) && datos.fechaBase == datos.fechaBase.ultimoDia,
                       "CTS semestral: la fecha base debe ser el 30 de abril o el 31 de octubre.")
        }
        try datos.variables.validar(meses: datos.mesesDelSemestre, hasta: datos.fechaBase)

        let rmv = try ReglasLaborales.rmv(en: datos.fechaBase)
        let asignacion = try ReglasLaborales.asignacion(acreditada: datos.remuneracion.asignacionAcreditada, en: datos.fechaBase)
        let sexto = datos.gratificacionPercibida / Decimal(ReglasLaborales.mesesSemestre)
        let base = datos.remuneracion.sueldo + datos.remuneracion.otrosFijos + asignacion
            + datos.variables.promedioExtras + datos.variables.promedioComisiones + sexto
        let diasComputables = diasAntesDeFaltas - datos.diasNoComputables
        let proporcional = Dinero.redondear(base * Decimal(diasComputables) / Decimal(ReglasLaborales.diasAnio))
        let total = datos.cumplioPrimerMes ? proporcional : 0
        let aviso: String? = datos.cumplioPrimerMes ? nil : (datos.tipo == .semestral
            ? "Menos de un mes: la fracción queda pendiente para el siguiente depósito."
            : "Cese antes del primer mes: no corresponde pago de CTS.")

        var fechaPago: FechaLaboral
        if datos.tipo == .trunca {
            fechaPago = datos.fechaBase.sumandoDias(2)
        } else {
            let siguiente = datos.fechaBase.primerDia.sumandoMeses(1)
            fechaPago = FechaLaboral(siguiente.anio, siguiente.mes, 15)
            while [1, 7].contains(FechaLaboral.calendario.component(.weekday, from: fechaPago.fecha)) {
                fechaPago = fechaPago.sumandoDias(1)
            }
        }
        return ResultadoCTS(rmv: rmv, asignacion: asignacion,
                            promedioExtras: datos.variables.promedioExtras,
                            promedioComisiones: datos.variables.promedioComisiones,
                            sextoGratificacion: sexto, baseComputable: base,
                            diasComputables: diasComputables, importeProporcional: proporcional,
                            total: total, fechaPagoReferencial: fechaPago, aviso: aviso)
    }
}
