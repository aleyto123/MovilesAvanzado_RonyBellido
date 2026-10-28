import Foundation

enum TipoGratificacion: String, CaseIterable, Identifiable {
    case julio = "Julio"
    case navidad = "Navidad"
    case trunca = "Trunca"
    var id: String { rawValue }
}

enum CoberturaSalud: String, CaseIterable, Identifiable {
    case esSalud = "EsSalud"
    case eps = "EPS"
    var id: String { rawValue }
    var tasaBonificacion: Decimal {
        self == .eps ? ReglasLaborales.bonoEPS : ReglasLaborales.bonoEsSalud
    }
}

struct DatosGratificacion: Equatable {
    var tipo: TipoGratificacion = .navidad
    var remuneracion = RemuneracionBase()
    var ingreso = FechaLaboral(2024, 1, 1)
    var anio = 2026
    var cese: FechaLaboral? = FechaLaboral(2026, 10, 31)
    var cobertura: CoberturaSalud = .esSalud
    var diasNoComputables = 0
    var cumpleRequisitoAlPago = true
    var variables = VariablesSemestrales()

    var fechaBase: FechaLaboral? {
        switch tipo {
        case .julio: return FechaLaboral(anio, 6, 30)
        case .navidad: return FechaLaboral(anio, 11, 30)
        case .trunca: return cese.map { $0.primerDia.sumandoMeses(-1).ultimoDia }
        }
    }

    var mesesDelSemestre: [FechaLaboral] {
        let mesInicial: Int
        switch tipo {
        case .julio: mesInicial = 1
        case .navidad: mesInicial = 7
        case .trunca:
            guard let cese = cese else { return [] }
            mesInicial = cese.mes <= 6 ? 1 : 7
        }
        let inicio = FechaLaboral(anio, mesInicial, 1)
        return (0..<6).map { inicio.sumandoMeses($0) }
    }
}

struct ResultadoGratificacion {
    let fechaBase: FechaLaboral
    let meses: [FechaLaboral]
    let mesesCompletos: [Bool]
    let asignacion: Decimal
    let promedioExtras: Decimal
    let promedioComisiones: Decimal
    let baseComputable: Decimal
    let importePorMeses: Decimal
    let descuentoPorDias: Decimal
    let gratificacion: Decimal
    let tasaBonificacion: Decimal
    let bonificacion: Decimal
    let total: Decimal
    var cantidadMeses: Int { mesesCompletos.filter { $0 }.count }
}

final class CalculadoraGratificacion {
    func calcular(_ datos: DatosGratificacion) throws -> ResultadoGratificacion {
        try datos.remuneracion.validar()
        try exigir(datos.anio == 2026, "El año cubierto por estos parámetros es 2026.")
        try exigir(datos.ingreso.esValida, "La fecha de ingreso no es válida.")
        if datos.tipo == .trunca {
            guard let cese = datos.cese else { throw ErrorCalculo("Selecciona la fecha de cese.") }
            try ReglasLaborales.validarFecha(cese)
            try exigir(cese >= datos.ingreso, "El cese no puede ser anterior al ingreso.")
        } else {
            try exigir(datos.cumpleRequisitoAlPago,
                       "La gratificación ordinaria exige laborar al pago o estar en vacaciones, licencia pagada u otro supuesto legal asimilado.")
        }
        guard let fechaBase = datos.fechaBase else { throw ErrorCalculo("No se pudo determinar la fecha base.") }
        // En un cese de enero de 2026, la base legal es diciembre de 2025 (RMV 1130).
        try exigir(fechaBase.esValida, "La fecha base de remuneración no es válida.")
        let meses = datos.mesesDelSemestre
        let fin = datos.tipo == .trunca ? datos.cese! : meses[5].ultimoDia
        try exigir(datos.ingreso <= fin, "La fecha de ingreso es posterior al período de gratificación.")
        try datos.variables.validar(meses: meses, desde: datos.ingreso, hasta: fin)
        let completos = meses.map { datos.ingreso <= $0 && $0.ultimoDia <= fin }
        let cantidad = completos.filter { $0 }.count
        try exigir(datos.diasNoComputables >= 0 && datos.diasNoComputables <= cantidad * ReglasLaborales.diasMes,
                   "Registra días no computables solo de los meses completos incluidos en el cálculo.")
        let asignacion = try ReglasLaborales.asignacion(acreditada: datos.remuneracion.asignacionAcreditada, en: fechaBase)
        let base = datos.remuneracion.sueldo + datos.remuneracion.otrosFijos + asignacion
            + datos.variables.promedioExtras + datos.variables.promedioComisiones
        let porMeses = base * Decimal(cantidad) / Decimal(ReglasLaborales.mesesSemestre)
        // D.S. 005-2002-TR, art. 3.4: un día descuenta 1/30 de un sexto, no de la gratificación completa.
        let porDias = base * Decimal(datos.diasNoComputables) / Decimal(ReglasLaborales.mesesSemestre * ReglasLaborales.diasMes)
        let gratificacion = Dinero.redondear(porMeses - porDias)
        let bonificacion = Dinero.redondear(gratificacion * datos.cobertura.tasaBonificacion)
        return ResultadoGratificacion(fechaBase: fechaBase, meses: meses, mesesCompletos: completos,
                                      asignacion: asignacion, promedioExtras: datos.variables.promedioExtras,
                                      promedioComisiones: datos.variables.promedioComisiones,
                                      baseComputable: base, importePorMeses: porMeses,
                                      descuentoPorDias: porDias, gratificacion: gratificacion,
                                      tasaBonificacion: datos.cobertura.tasaBonificacion,
                                      bonificacion: bonificacion, total: gratificacion + bonificacion)
    }
}
