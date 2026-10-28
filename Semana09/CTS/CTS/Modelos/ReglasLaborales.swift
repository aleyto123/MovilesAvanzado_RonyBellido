import Foundation

struct ErrorCalculo: LocalizedError, Equatable {
    let mensaje: String
    init(_ mensaje: String) { self.mensaje = mensaje }
    var errorDescription: String? { mensaje }
}

func exigir(_ condicion: Bool, _ mensaje: String) throws {
    guard condicion else { throw ErrorCalculo(mensaje) }
}

enum Dinero {
    static func redondear(_ valor: Decimal) -> Decimal {
        var entrada = valor
        var salida = Decimal()
        NSDecimalRound(&salida, &entrada, 2, .plain)
        return salida
    }

    static func validar(_ valor: Decimal, campo: String, positivo: Bool = false) throws {
        try exigir(!valor.isNaN && valor >= 0 && valor <= 1_000_000_000,
                   "\(campo): ingresa un importe entre 0 y 1 000 000 000.")
        if positivo { try exigir(valor > 0, "\(campo): debe ser mayor que cero.") }
    }

    static func mostrar(_ valor: Decimal) -> String {
        let formato = NumberFormatter()
        formato.locale = Locale(identifier: "es_PE")
        formato.numberStyle = .currency
        formato.currencySymbol = "S/ "
        formato.currencyDecimalSeparator = "."
        formato.currencyGroupingSeparator = ","
        formato.minimumFractionDigits = 2
        formato.maximumFractionDigits = 2
        return formato.string(from: NSDecimalNumber(decimal: redondear(valor))) ?? "—"
    }
}

struct FechaLaboral: Equatable, Comparable {
    var anio: Int
    var mes: Int
    var dia: Int

    static var calendario: Calendar {
        var calendario = Calendar(identifier: .gregorian)
        calendario.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendario
    }

    init(_ anio: Int, _ mes: Int, _ dia: Int) {
        self.anio = anio
        self.mes = mes
        self.dia = dia
    }

    init(_ fecha: Date) {
        let componentes = Self.calendario.dateComponents([.year, .month, .day], from: fecha)
        anio = componentes.year!
        mes = componentes.month!
        dia = componentes.day!
    }

    var fecha: Date {
        Self.calendario.date(from: DateComponents(year: anio, month: mes, day: dia, hour: 12)) ?? .distantPast
    }

    var esValida: Bool {
        guard (1900...2100).contains(anio), (1...12).contains(mes), (1...31).contains(dia) else { return false }
        return FechaLaboral(fecha) == self
    }

    var primerDia: FechaLaboral { FechaLaboral(anio, mes, 1) }
    var ultimoDia: FechaLaboral {
        let dias = Self.calendario.range(of: .day, in: .month, for: primerDia.fecha)!.count
        return FechaLaboral(anio, mes, dias)
    }

    func sumandoMeses(_ meses: Int) -> FechaLaboral {
        FechaLaboral(Self.calendario.date(byAdding: .month, value: meses, to: fecha)!)
    }

    func sumandoDias(_ dias: Int) -> FechaLaboral {
        FechaLaboral(Self.calendario.date(byAdding: .day, value: dias, to: fecha)!)
    }

    var texto: String { String(format: "%02d/%02d/%04d", dia, mes, anio) }
    var nombreMes: String {
        let formato = DateFormatter()
        formato.locale = Locale(identifier: "es_PE")
        formato.calendar = Self.calendario
        formato.timeZone = Self.calendario.timeZone
        formato.dateFormat = "MMM yyyy"
        return formato.string(from: fecha)
    }

    static func < (izquierda: Self, derecha: Self) -> Bool {
        (izquierda.anio, izquierda.mes, izquierda.dia) < (derecha.anio, derecha.mes, derecha.dia)
    }
}

enum ReglasLaborales {
    static let diasMes = 30
    static let mesesAnio = 12
    static let diasAnio = diasMes * mesesAnio
    static let mesesSemestre = 6
    static let mesesRegularidad = 3
    static let diasVacaciones = 30
    static let tasaAsignacion = Decimal(string: "0.10")!
    static let bonoEsSalud = Decimal(string: "0.09")!
    static let bonoEPS = Decimal(string: "0.0675")!
    static let fechaConsulta = FechaLaboral(2026, 10, 27)

    static func validarFecha(_ fecha: FechaLaboral) throws {
        try exigir(fecha.esValida && fecha.anio == 2026,
                   "La fecha de cálculo debe ser válida y corresponder a 2026, año cubierto por los parámetros.")
    }

    static func rmv(en fecha: FechaLaboral) throws -> Decimal {
        try exigir(fecha.esValida && fecha >= FechaLaboral(2025, 1, 1) && fecha <= FechaLaboral(2026, 12, 31),
                   "No hay parámetros de RMV para la fecha base indicada.")
        // D.S. 015-2026-TR, art. 1.2. Junio de 2026 conserva la RMV anterior.
        return fecha >= FechaLaboral(2026, 10, 1) ? 1230 : 1130
    }

    static func asignacion(acreditada: Bool, en fecha: FechaLaboral) throws -> Decimal {
        let minima = try rmv(en: fecha)
        return acreditada ? minima * tasaAsignacion : 0
    }
}

struct RemuneracionBase: Equatable {
    var sueldo: Decimal = 3000
    var asignacionAcreditada = false
    var otrosFijos: Decimal = 0
    var jornada: Decimal = 8

    func validar() throws {
        try Dinero.validar(sueldo, campo: "Sueldo básico", positivo: true)
        try Dinero.validar(otrosFijos, campo: "Otros fijos computables")
        try exigir(!jornada.isNaN && jornada >= 4 && jornada <= 8,
                   "Esta calculadora cubre jornadas ordinarias de 4 a 8 horas, con remuneración principal fija.")
    }
}

struct VariablesSemestrales: Equatable {
    var horasExtras: [Decimal] = Array(repeating: 0, count: 6)
    var comisiones: [Decimal] = Array(repeating: 0, count: 6)

    func validar(meses: [FechaLaboral], desde ingreso: FechaLaboral? = nil, hasta corte: FechaLaboral) throws {
        try exigir(horasExtras.count == 6 && comisiones.count == 6 && meses.count == 6,
                   "Cada complemento necesita los seis meses del semestre; utiliza cero donde no hubo percepción.")
        for i in 0..<6 {
            try Dinero.validar(horasExtras[i], campo: "Horas extras de \(meses[i].nombreMes)")
            try Dinero.validar(comisiones[i], campo: "Comisiones de \(meses[i].nombreMes)")
            let antesDelIngreso = ingreso.map { meses[i] < $0.primerDia } ?? false
            if meses[i] > corte || antesDelIngreso {
                try exigir(horasExtras[i] == 0 && comisiones[i] == 0,
                           "\(meses[i].nombreMes): no registres variables fuera del vínculo o después del corte.")
            }
        }
    }

    static func promedio(_ importes: [Decimal]) -> Decimal {
        guard importes.filter({ $0 > 0 }).count >= ReglasLaborales.mesesRegularidad else { return 0 }
        // Cada complemento se evalúa por separado: D.S. 001-97-TR, art. 16.
        return importes.reduce(0, +) / Decimal(ReglasLaborales.mesesSemestre)
    }

    var promedioExtras: Decimal { Self.promedio(horasExtras) }
    var promedioComisiones: Decimal { Self.promedio(comisiones) }
}

struct FuenteLegal: Identifiable {
    let id: String
    let titulo: String
    let direccion: String
    var url: URL { URL(string: direccion)! }

    static let cts = FuenteLegal(id: "cts", titulo: "CTS · D.S. 001-97-TR, arts. 2, 9, 16, 18 y 21",
        direccion: "https://cdn.www.gob.pe/uploads/document/file/289875/Compendio_normas_laborales_29-01-19.pdf?v=1549987495")
    static let gratificacion = FuenteLegal(id: "gratificacion", titulo: "Gratificaciones · Ley 27735 y D.S. 005-2002-TR",
        direccion: "https://cdn.www.gob.pe/uploads/document/file/3321103/guia_gratificaciones.pdf")
    static let bonificacion = FuenteLegal(id: "bonificacion", titulo: "Bonificación · Ley 30334 y D.S. 012-2016-TR",
        direccion: "https://busquedas.elperuano.pe/api/visor_html/1436137-3")
    static let vacaciones = FuenteLegal(id: "vacaciones", titulo: "Vacaciones · D. Leg. 713 y D.S. 012-92-TR",
        direccion: "https://cdn.www.gob.pe/uploads/document/file/2925494/guia_para_el_descanso_vacacional.pdf?v=1647874466")
    static let fraccionamiento = FuenteLegal(id: "fraccionamiento", titulo: "Fraccionamiento y adelanto · D. Leg. 1405",
        direccion: "https://busquedas.elperuano.pe/dispositivo/NL/1690481-1")
    static let rmv = FuenteLegal(id: "rmv", titulo: "RMV · D.S. 015-2026-TR, art. 1.2",
        direccion: "https://busquedas.elperuano.pe/dispositivo/EX/2559163-1")
    static let asignacion = FuenteLegal(id: "asignacion", titulo: "Asignación familiar · Ley 25129, modificada por Ley 31600",
        direccion: "https://www.pj.gob.pe/wps/wcm/connect/a3ed468040e366e0bd54bf1666a80600/RESOLUCION%2BADMINISTRATIVA-000114-2024-UAF-GAD-CSJPU.pdf?CACHEID=a3ed468040e366e0bd54bf1666a80600&MOD=AJPERES")
}
