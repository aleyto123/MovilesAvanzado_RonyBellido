import XCTest
@testable import CTS

final class BeneficiosTests: XCTestCase {
    private func decimal(_ texto: String) -> Decimal { Decimal(string: texto)! }

    func testCTSSemestreCompleto() throws {
        let resultado = try CalculadoraCTS().calcular(DatosCTS())
        XCTAssertEqual(resultado.sextoGratificacion, 500)
        XCTAssertEqual(resultado.baseComputable, 3500)
        XCTAssertEqual(resultado.diasComputables, 180)
        XCTAssertEqual(resultado.total, 1750)
        XCTAssertEqual(resultado.fechaPagoReferencial, FechaLaboral(2026, 11, 16))
    }

    func testCTSFraccionYFaltas() throws {
        var datos = DatosCTS()
        datos.meses = 3
        datos.dias = 15
        XCTAssertEqual(try CalculadoraCTS().calcular(datos).total, decimal("1020.83"))
        datos.meses = 6
        datos.dias = 0
        datos.diasNoComputables = 5
        XCTAssertEqual(try CalculadoraCTS().calcular(datos).total, decimal("1701.39"))
    }

    func testCTSSinGratificacionPercibida() throws {
        var datos = DatosCTS()
        datos.remuneracion.sueldo = 2000
        datos.gratificacionPercibida = 0
        datos.meses = 2
        datos.dias = 15
        XCTAssertEqual(try CalculadoraCTS().calcular(datos).total, decimal("416.67"))
    }

    func testCTSAsignacionYGratificacionHistorica() throws {
        var datos = DatosCTS()
        datos.remuneracion.asignacionAcreditada = true
        datos.gratificacionPercibida = 3113
        let resultado = try CalculadoraCTS().calcular(datos)
        XCTAssertEqual(resultado.asignacion, 123)
        XCTAssertEqual(resultado.total, decimal("1820.92"))
    }

    func testCTSRegularidadPorConcepto() throws {
        var datos = DatosCTS()
        datos.variables.horasExtras = [100, 0, 200, 0, 300, 0]
        XCTAssertEqual(try CalculadoraCTS().calcular(datos).total, 1800)
        datos.variables.horasExtras = [100, 0, 200, 0, 0, 0]
        datos.variables.comisiones = [0, 0, 0, 0, 300, 0]
        XCTAssertEqual(try CalculadoraCTS().calcular(datos).total, 1750)
    }

    func testCTSPrimerMesPendienteYTruncaSinPrimerMes() throws {
        var datos = DatosCTS()
        datos.meses = 0
        datos.dias = 15
        datos.cumplioPrimerMes = false
        var resultado = try CalculadoraCTS().calcular(datos)
        XCTAssertEqual(resultado.total, 0)
        XCTAssertTrue(resultado.aviso!.contains("pendiente"))
        datos.tipo = .trunca
        resultado = try CalculadoraCTS().calcular(datos)
        XCTAssertEqual(resultado.total, 0)
        XCTAssertTrue(resultado.aviso!.contains("no corresponde"))
    }

    func testCTSTruncaYArrastre() throws {
        var datos = DatosCTS()
        datos.tipo = .trunca
        datos.fechaBase = FechaLaboral(2026, 8, 16)
        datos.meses = 3
        datos.dias = 15
        XCTAssertEqual(try CalculadoraCTS().calcular(datos).total, decimal("1020.83"))
        XCTAssertEqual(try CalculadoraCTS().calcular(datos).fechaPagoReferencial, FechaLaboral(2026, 8, 18))
        datos.diasArrastrados = 10
        XCTAssertEqual(try CalculadoraCTS().calcular(datos).total, decimal("1118.06"))
    }

    func testCTSCortesYPeriodosInvalidos() {
        var datos = DatosCTS()
        datos.fechaBase = FechaLaboral(2026, 10, 30)
        XCTAssertThrowsError(try CalculadoraCTS().calcular(datos))
        datos = DatosCTS(); datos.meses = 6; datos.dias = 1
        XCTAssertThrowsError(try CalculadoraCTS().calcular(datos))
        datos = DatosCTS(); datos.diasNoComputables = 181
        XCTAssertThrowsError(try CalculadoraCTS().calcular(datos))
        datos = DatosCTS(); datos.diasArrastrados = 30
        XCTAssertThrowsError(try CalculadoraCTS().calcular(datos))
    }

    func testCTSVariablesFuturasYArrayIncompleto() {
        var datos = DatosCTS()
        datos.tipo = .trunca; datos.fechaBase = FechaLaboral(2026, 8, 1)
        datos.meses = 3
        datos.variables.horasExtras[5] = 100
        XCTAssertThrowsError(try CalculadoraCTS().calcular(datos))
        datos = DatosCTS(); datos.variables.horasExtras = [100]
        XCTAssertThrowsError(try CalculadoraCTS().calcular(datos))
    }

    func testCTSTruncaNoPuedeIncluirTiempoPosteriorAlCese() {
        var datos = DatosCTS()
        datos.tipo = .trunca
        datos.fechaBase = FechaLaboral(2026, 8, 16)
        XCTAssertThrowsError(try CalculadoraCTS().calcular(datos))
    }

    func testGratificacionEsSaludYEPS() throws {
        var datos = DatosGratificacion()
        var resultado = try CalculadoraGratificacion().calcular(datos)
        XCTAssertEqual(resultado.gratificacion, 3000)
        XCTAssertEqual(resultado.bonificacion, 270)
        XCTAssertEqual(resultado.total, 3270)
        datos.cobertura = .eps
        resultado = try CalculadoraGratificacion().calcular(datos)
        XCTAssertEqual(resultado.bonificacion, decimal("202.50"))
        XCTAssertEqual(resultado.total, decimal("3202.50"))
    }

    func testGratificacionSoloMesesCalendarioCompletos() throws {
        var datos = DatosGratificacion()
        datos.ingreso = FechaLaboral(2026, 9, 15)
        let resultado = try CalculadoraGratificacion().calcular(datos)
        XCTAssertEqual(resultado.cantidadMeses, 3)
        XCTAssertEqual(resultado.total, 1635)
    }

    func testGratificacionTrunca() throws {
        var datos = DatosGratificacion()
        datos.tipo = .trunca
        datos.ingreso = FechaLaboral(2026, 8, 1)
        datos.cese = FechaLaboral(2026, 10, 16)
        let resultado = try CalculadoraGratificacion().calcular(datos)
        XCTAssertEqual(resultado.fechaBase, FechaLaboral(2026, 9, 30))
        XCTAssertEqual(resultado.cantidadMeses, 2)
        XCTAssertEqual(resultado.total, 1090)
    }

    func testGratificacionSinMesCompleto() throws {
        var datos = DatosGratificacion()
        datos.tipo = .trunca
        datos.ingreso = FechaLaboral(2026, 9, 15)
        datos.cese = FechaLaboral(2026, 9, 30)
        XCTAssertEqual(try CalculadoraGratificacion().calcular(datos).total, 0)
    }

    func testGratificacionAsignacionHistorica() throws {
        var datos = DatosGratificacion()
        datos.remuneracion.asignacionAcreditada = true
        datos.tipo = .julio
        var resultado = try CalculadoraGratificacion().calcular(datos)
        XCTAssertEqual(resultado.asignacion, 113)
        XCTAssertEqual(resultado.total, decimal("3393.17"))
        datos.tipo = .navidad
        resultado = try CalculadoraGratificacion().calcular(datos)
        XCTAssertEqual(resultado.asignacion, 123)
        XCTAssertEqual(resultado.total, decimal("3404.07"))
    }

    func testGratificacionTruncaDeEneroUsaDiciembreAnterior() throws {
        var datos = DatosGratificacion()
        datos.tipo = .trunca
        datos.cese = FechaLaboral(2026, 1, 31)
        datos.remuneracion.asignacionAcreditada = true
        let resultado = try CalculadoraGratificacion().calcular(datos)
        XCTAssertEqual(resultado.fechaBase, FechaLaboral(2025, 12, 31))
        XCTAssertEqual(resultado.asignacion, 113)
        XCTAssertEqual(resultado.total, decimal("565.52"))
    }

    func testGratificacionFaltasPorCientoOchenta() throws {
        var datos = DatosGratificacion()
        datos.diasNoComputables = 2
        let resultado = try CalculadoraGratificacion().calcular(datos)
        XCTAssertEqual(resultado.gratificacion, decimal("2966.67"))
        XCTAssertEqual(resultado.bonificacion, 267)
        XCTAssertEqual(resultado.total, decimal("3233.67"))
    }

    func testGratificacionVariableRegular() throws {
        var datos = DatosGratificacion()
        datos.variables.horasExtras = [100, 200, 300, 0, 0, 0]
        XCTAssertEqual(try CalculadoraGratificacion().calcular(datos).total, 3379)
        datos.variables.horasExtras = [100, 200, 0, 0, 0, 0]
        XCTAssertEqual(try CalculadoraGratificacion().calcular(datos).total, 3270)
    }

    func testGratificacionVariablesFueraDelVinculo() {
        var datos = DatosGratificacion()
        datos.tipo = .trunca; datos.ingreso = FechaLaboral(2026, 8, 1); datos.cese = FechaLaboral(2026, 10, 16)
        datos.variables.horasExtras[4] = 100
        XCTAssertThrowsError(try CalculadoraGratificacion().calcular(datos))
        datos.variables.horasExtras = [100, 0, 0, 0, 0, 0]
        XCTAssertThrowsError(try CalculadoraGratificacion().calcular(datos))
    }

    func testGratificacionRequisitosYFechasInvalidas() throws {
        var datos = DatosGratificacion()
        datos.cese = nil
        XCTAssertEqual(try CalculadoraGratificacion().calcular(datos).total, 3270)
        datos.cumpleRequisitoAlPago = false
        XCTAssertThrowsError(try CalculadoraGratificacion().calcular(datos))
        datos = DatosGratificacion(); datos.diasNoComputables = 181
        XCTAssertThrowsError(try CalculadoraGratificacion().calcular(datos))
        datos = DatosGratificacion(); datos.tipo = .trunca; datos.cese = nil
        XCTAssertThrowsError(try CalculadoraGratificacion().calcular(datos))
        datos = DatosGratificacion(); datos.tipo = .trunca; datos.ingreso = FechaLaboral(2026, 11, 1)
        XCTAssertThrowsError(try CalculadoraGratificacion().calcular(datos))
    }

    func testVacacionesGoceNoAgregaOtroSueldo() throws {
        var datos = DatosVacaciones()
        var resultado = try CalculadoraVacaciones().calcular(datos)
        XCTAssertEqual(resultado.total, 1500)
        XCTAssertEqual(resultado.goce?.equivalenteMensual, 3000)
        XCTAssertEqual(resultado.goce?.ultimoDia, FechaLaboral(2026, 11, 16))
        XCTAssertEqual(resultado.goce?.saldoDias, 15)
        XCTAssertNil(resultado.cese)
        datos.diasSolicitados = 30
        datos.fraccionamientoLegalAcordado = false
        resultado = try CalculadoraVacaciones().calcular(datos)
        XCTAssertEqual(resultado.total, 3000)
        XCTAssertEqual(resultado.goce?.saldoDias, 0)
    }

    func testVacacionesRecordDeCincoYSeisDias() throws {
        var datos = DatosVacaciones()
        datos.diasComputablesRecord = 259
        XCTAssertThrowsError(try CalculadoraVacaciones().calcular(datos))
        datos.diasPorSemana = 5; datos.diasComputablesRecord = 210
        XCTAssertEqual(try CalculadoraVacaciones().calcular(datos).total, 1500)
        datos.diasComputablesRecord = 209
        XCTAssertThrowsError(try CalculadoraVacaciones().calcular(datos))
    }

    func testVacacionesSaldoYFraccionamiento() {
        var datos = DatosVacaciones()
        datos.diasSolicitados = 31
        XCTAssertThrowsError(try CalculadoraVacaciones().calcular(datos))
        datos = DatosVacaciones(); datos.fraccionamientoLegalAcordado = false
        XCTAssertThrowsError(try CalculadoraVacaciones().calcular(datos))
        datos = DatosVacaciones(); datos.diasGozados = 20
        XCTAssertThrowsError(try CalculadoraVacaciones().calcular(datos))
        datos = DatosVacaciones(); datos.anioYRecordAcreditados = false
        XCTAssertThrowsError(try CalculadoraVacaciones().calcular(datos))
    }

    private func truncas() -> DatosVacaciones {
        var datos = DatosVacaciones()
        datos.situacion = .cese
        datos.anioYRecordAcreditados = false
        datos.diasGanados = 0
        return datos
    }

    func testVacacionesTruncasYGanadasSonPeriodosDistintos() throws {
        let resultado = try CalculadoraVacaciones().calcular(truncas())
        XCTAssertEqual(resultado.total, 1125)
        XCTAssertEqual(resultado.cese?.truncasPendientes, 1125)
        XCTAssertNil(resultado.goce)
        var datos = DatosVacaciones()
        datos.situacion = .cese; datos.diasGozados = 10
        let combinado = try CalculadoraVacaciones().calcular(datos)
        XCTAssertEqual(combinado.cese?.ganadasPendientes, 2000)
        XCTAssertEqual(combinado.total, 3125)
    }

    func testVacacionesVencidasYExclusionGerencial() throws {
        var datos = DatosVacaciones()
        datos.situacion = .cese; datos.mesesTruncos = 0; datos.diasTruncos = 0; datos.diasIndemnizables = 30
        XCTAssertEqual(try CalculadoraVacaciones().calcular(datos).total, 6000)
        datos.gerenteQueDecidioNoDescansar = true
        XCTAssertEqual(try CalculadoraVacaciones().calcular(datos).total, 3000)
    }

    func testVacacionesAdelantoNoGeneraDeuda() throws {
        var datos = truncas()
        datos.diasAdelantados = 15
        XCTAssertEqual(try CalculadoraVacaciones().calcular(datos).total, 0)
        datos.diasAdelantados = 5
        XCTAssertEqual(try CalculadoraVacaciones().calcular(datos).total, 625)
    }

    func testVacacionesPrimerMesYValidacionesAlCese() throws {
        var datos = truncas()
        datos.mesesTruncos = 0; datos.diasTruncos = 20; datos.cumplioPrimerMes = false
        XCTAssertEqual(try CalculadoraVacaciones().calcular(datos).total, 0)
        datos = truncas(); datos.mesesTruncos = 12
        XCTAssertThrowsError(try CalculadoraVacaciones().calcular(datos))
        datos = truncas(); datos.diasTruncos = 30
        XCTAssertThrowsError(try CalculadoraVacaciones().calcular(datos))
        datos = truncas(); datos.diasIndemnizables = 1
        XCTAssertThrowsError(try CalculadoraVacaciones().calcular(datos))
    }

    func testVacacionesNoIncluyeUnSextoYSiIncluyeRegulares() throws {
        var datos = DatosVacaciones()
        datos.remuneracion.asignacionAcreditada = true
        datos.promedioRegular = 100
        let resultado = try CalculadoraVacaciones().calcular(datos)
        XCTAssertEqual(resultado.baseComputable, 3223)
        XCTAssertEqual(resultado.total, decimal("1611.50"))
    }

    func testRemuneracionesInvalidas() {
        for sueldo in [Decimal(0), Decimal(-1), Decimal.nan] {
            var datos = DatosCTS(); datos.remuneracion.sueldo = sueldo
            XCTAssertThrowsError(try CalculadoraCTS().calcular(datos))
        }
        for jornada in [Decimal(3), Decimal(9), Decimal.nan] {
            var datos = DatosGratificacion(); datos.remuneracion.jornada = jornada
            XCTAssertThrowsError(try CalculadoraGratificacion().calcular(datos))
        }
        var vacaciones = DatosVacaciones(); vacaciones.promedioRegular = -1
        XCTAssertThrowsError(try CalculadoraVacaciones().calcular(vacaciones))
    }

    func testFechasYVigenciaDeRMV() throws {
        XCTAssertFalse(FechaLaboral(2026, 2, 29).esValida)
        XCTAssertEqual(try ReglasLaborales.rmv(en: FechaLaboral(2026, 9, 30)), 1130)
        XCTAssertEqual(try ReglasLaborales.rmv(en: FechaLaboral(2026, 10, 1)), 1230)
        var datos = DatosCTS(); datos.fechaBase = FechaLaboral(2027, 4, 30)
        XCTAssertThrowsError(try CalculadoraCTS().calcular(datos))
    }

    func testEntradaDecimalSinAmbiguedades() throws {
        XCTAssertEqual(try EntradaNumero.importe(" 3000,25 ", campo: "Prueba"), decimal("3000.25"))
        XCTAssertEqual(try EntradaNumero.importe("3000.25", campo: "Prueba"), decimal("3000.25"))
        for texto in ["", "abc", "-1", "1,000.00", "1.000,00", "1.234", "1e3", "NaN"] {
            XCTAssertThrowsError(try EntradaNumero.importe(texto, campo: "Prueba"), texto)
        }
        for texto in ["", "1.5", "-1", "abc", "999999999999999999"] {
            XCTAssertThrowsError(try EntradaNumero.entero(texto, campo: "Prueba"), texto)
        }
    }

    func testFormulariosSoloLeenCamposDeLaSituacionActiva() throws {
        var vacaciones = FormularioVacaciones()
        vacaciones.mesesTruncos = ""; vacaciones.diasTruncos = "abc"; vacaciones.indemnizables = ""
        vacaciones.adelantados = ""; vacaciones.faltasTruncas = ""
        XCTAssertEqual(try CalculadoraVacaciones().calcular(vacaciones.datos()).total, 1500)
        vacaciones.situacion = .cese
        XCTAssertThrowsError(try vacaciones.datos())
        vacaciones = FormularioVacaciones(); vacaciones.situacion = .cese
        vacaciones.solicitados = "abc"
        XCTAssertEqual(try CalculadoraVacaciones().calcular(vacaciones.datos()).total, 4125)
        var cts = FormularioCTS(); cts.remuneracion.sueldo = ""
        XCTAssertThrowsError(try cts.datos())
    }

    func testRedondeoYFormatoMonetario() {
        XCTAssertEqual(Dinero.redondear(decimal("52.048")), decimal("52.05"))
        XCTAssertEqual(Dinero.redondear(decimal("43.9155")), decimal("43.92"))
        XCTAssertEqual(Dinero.redondear(decimal("0.005")), decimal("0.01"))
        XCTAssertTrue(Dinero.mostrar(1750).contains("1,750.00"))
    }
}
