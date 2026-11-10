import Foundation

enum EntradaNumero {
    static func importe(_ texto: String, campo: String) throws -> Decimal {
        let limpio = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        try exigir(!limpio.isEmpty, "\(campo): completa el campo; utiliza 0 si no corresponde.")
        guard limpio.range(of: "^[0-9]+([.,][0-9]{1,2})?$", options: .regularExpression) != nil,
              let valor = Decimal(string: limpio.replacingOccurrences(of: ",", with: "."), locale: Locale(identifier: "en_US_POSIX")) else {
            throw ErrorCalculo("\(campo): usa punto o coma decimal, hasta dos decimales y ningún separador de miles.")
        }
        try Dinero.validar(valor, campo: campo)
        return valor
    }

    static func entero(_ texto: String, campo: String) throws -> Int {
        let limpio = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard limpio.range(of: "^[0-9]{1,6}$", options: .regularExpression) != nil,
              let valor = Int(limpio) else {
            throw ErrorCalculo("\(campo): ingresa un número entero de cero o más, sin decimales.")
        }
        return valor
    }
}

struct FormularioRemuneracion: Equatable {
    var sueldo = "3000"
    var asignacion = false
    var fijos = "0"
    var jornada = "8"

    func datos() throws -> RemuneracionBase {
        RemuneracionBase(sueldo: try EntradaNumero.importe(sueldo, campo: "Sueldo básico"),
                         asignacionAcreditada: asignacion,
                         otrosFijos: try EntradaNumero.importe(fijos, campo: "Otros fijos computables"),
                         jornada: try EntradaNumero.importe(jornada, campo: "Jornada diaria"))
    }
}

struct FormularioVariables: Equatable {
    var extras = Array(repeating: "0", count: 6)
    var comisiones = Array(repeating: "0", count: 6)

    func datos() throws -> VariablesSemestrales {
        try exigir(extras.count == 6 && comisiones.count == 6, "Faltan meses en la tabla de complementos.")
        return try VariablesSemestrales(
            horasExtras: extras.enumerated().map { try EntradaNumero.importe($0.element, campo: "Horas extras, mes \($0.offset + 1)") },
            comisiones: comisiones.enumerated().map { try EntradaNumero.importe($0.element, campo: "Comisiones, mes \($0.offset + 1)") })
    }
}

struct FormularioCTS: Equatable {
    var tipo: TipoCTS = .semestral
    var remuneracion = FormularioRemuneracion()
    var fecha = FechaLaboral(2026, 10, 31).fecha
    var gratificacion = "3000"
    var meses = "6"
    var dias = "0"
    var faltas = "0"
    var arrastre = "0"
    var primerMes = true
    var variables = FormularioVariables()

    var mesesDelSemestre: [FechaLaboral] {
        var periodo = DatosCTS()
        periodo.fechaBase = FechaLaboral(fecha)
        return periodo.mesesDelSemestre
    }

    func datos() throws -> DatosCTS {
        try DatosCTS(tipo: tipo, remuneracion: remuneracion.datos(), fechaBase: FechaLaboral(fecha),
                     gratificacionPercibida: EntradaNumero.importe(gratificacion, campo: "Gratificación anterior"),
                     meses: EntradaNumero.entero(meses, campo: "Meses CTS"),
                     dias: EntradaNumero.entero(dias, campo: "Días adicionales CTS"),
                     diasNoComputables: EntradaNumero.entero(faltas, campo: "Días no computables CTS"),
                     diasArrastrados: EntradaNumero.entero(arrastre, campo: "Días pendientes previos"),
                     cumplioPrimerMes: primerMes, variables: variables.datos())
    }
}

struct FormularioGratificacion: Equatable {
    var tipo: TipoGratificacion = .navidad
    var remuneracion = FormularioRemuneracion()
    var ingreso = FechaLaboral(2024, 1, 1).fecha
    var cese = FechaLaboral(2026, 10, 31).fecha
    var cobertura: CoberturaSalud = .esSalud
    var faltas = "0"
    var requisitoAlPago = true
    var variables = FormularioVariables()

    var periodo: DatosGratificacion {
        var datos = DatosGratificacion()
        datos.tipo = tipo
        datos.ingreso = FechaLaboral(ingreso)
        datos.cese = tipo == .trunca ? FechaLaboral(cese) : nil
        return datos
    }

    func datos() throws -> DatosGratificacion {
        var datos = periodo
        datos.remuneracion = try remuneracion.datos()
        datos.cobertura = cobertura
        datos.diasNoComputables = try EntradaNumero.entero(faltas, campo: "Días no computables de gratificación")
        datos.cumpleRequisitoAlPago = requisitoAlPago
        datos.variables = try variables.datos()
        return datos
    }
}

struct FormularioVacaciones: Equatable {
    var situacion: SituacionVacaciones = .goce
    var remuneracion = FormularioRemuneracion()
    var fecha = FechaLaboral(2026, 11, 2).fecha
    var promedio = "0"
    var anioYRecord = true
    var semana = 6
    var record = "260"
    var ganados = "30"
    var gozados = "0"
    var solicitados = "15"
    var acuerdo = true
    var mesesTruncos = "4"
    var diasTruncos = "15"
    var faltasTruncas = "0"
    var primerMes = true
    var indemnizables = "0"
    var gerente = false
    var adelantados = "0"

    func datos() throws -> DatosVacaciones {
        var datos = DatosVacaciones()
        datos.situacion = situacion
        datos.remuneracion = try remuneracion.datos()
        datos.fecha = FechaLaboral(fecha)
        datos.promedioRegular = try EntradaNumero.importe(promedio, campo: "Promedio regular confirmado")
        datos.anioYRecordAcreditados = anioYRecord
        datos.diasGanados = try EntradaNumero.entero(ganados, campo: "Días ganados")
        datos.diasGozados = try EntradaNumero.entero(gozados, campo: "Días ya gozados")
        if anioYRecord {
            datos.diasPorSemana = semana
            datos.diasComputablesRecord = try EntradaNumero.entero(record, campo: "Récord vacacional")
        }
        if situacion == .goce {
            datos.diasSolicitados = try EntradaNumero.entero(solicitados, campo: "Días de descanso solicitados")
            datos.fraccionamientoLegalAcordado = acuerdo
        } else {
            datos.mesesTruncos = try EntradaNumero.entero(mesesTruncos, campo: "Meses truncos")
            datos.diasTruncos = try EntradaNumero.entero(diasTruncos, campo: "Días truncos adicionales")
            datos.diasNoComputables = try EntradaNumero.entero(faltasTruncas, campo: "Días no computables truncos")
            datos.cumplioPrimerMes = primerMes
            datos.diasIndemnizables = try EntradaNumero.entero(indemnizables, campo: "Días indemnizables")
            datos.gerenteQueDecidioNoDescansar = gerente
            datos.diasAdelantados = try EntradaNumero.importe(adelantados, campo: "Días adelantados")
        }
        return datos
    }
}
