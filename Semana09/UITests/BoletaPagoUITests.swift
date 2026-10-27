import XCTest

final class BoletaPagoUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(es)", "-AppleLocale", "es_PE"]
        app.launch()
        XCTAssertTrue(app.textFields["sueldo"].waitForExistence(timeout: 15))
    }

    func testCaso1ONPMesCompleto() {
        capturar("caso-1-formulario")
        calcular()
        comprobar("importe.Total remuneraciones", "2500.00")
        comprobar("importe.Total descuentos", "325.00")
        comprobar("importe.EsSalud (9%)", "225.00")
        comprobar("netoPagar", "2175.00")
        capturar("caso-1-neto")
    }

    func testCaso2ConHijosDiasIncompletos() {
        escribir("1800", en: "sueldo")
        escribir("27", en: "dias")
        seleccionar("Sí", en: "tieneHijos")
        calcular()
        comprobar("importe.Sueldo computable", "1620.00")
        comprobar("importe.Asignación familiar", "123.00")
        comprobar("importe.Total remuneraciones", "1743.00")
        comprobar("importe.Total descuentos", "226.59")
        comprobar("netoPagar", "1516.41")
        capturar("caso-2-neto")
    }

    func testCaso3AFPExtrasYAdelanto() {
        completarAFP(sueldo: "3000", dias: "30", horas: "4", adelanto: "200")
        capturar("caso-3-formulario")
        calcular()
        comprobar("importe.Horas extras 25%", "62.50")
        comprobar("importe.Horas extras 35%", "67.50")
        comprobar("importe.Total remuneraciones", "3253.00")
        capturar("caso-3-remuneraciones")
        comprobar("importe.AFP fondo", "325.30")
        comprobar("importe.AFP comisión", "52.05")
        comprobar("importe.AFP seguro", "43.92")
        comprobar("importe.Total descuentos", "621.27")
        capturar("caso-3-descuentos")
        comprobar("importe.EsSalud (9%)", "292.77")
        comprobar("netoPagar", "2631.73")
        capturar("caso-3-neto")
    }

    func testCaso4Evaluacion() {
        completarAFP(sueldo: "4200", dias: "24", horas: "2", adelanto: "100")
        calcular()
        comprobar("importe.Sueldo computable", "3360.00")
        comprobar("importe.Total remuneraciones", "3574.00")
        comprobar("importe.Total descuentos", "562.83")
        comprobar("importe.EsSalud (9%)", "321.66")
        comprobar("netoPagar", "3011.17")
        capturar("caso-4-neto")
    }

    func testDiasInvalidosRetiranResultadoAnterior() {
        calcular()
        comprobar("netoPagar", "2175.00")
        escribir("31", en: "dias")
        XCTAssertFalse(app.staticTexts["netoPagar"].exists)
        calcular()
        let error = app.staticTexts["errorValidacion"]
        mostrar(error)
        XCTAssertTrue(error.label.contains("entre 1 y 30"))
        XCTAssertFalse(app.staticTexts["netoPagar"].exists)
        capturar("validacion-dias-31")
    }

    private func completarAFP(sueldo: String, dias: String, horas: String, adelanto: String) {
        escribir(sueldo, en: "sueldo")
        escribir(dias, en: "dias")
        seleccionar("Sí", en: "tieneHijos")
        seleccionar("AFP", en: "sistemaPension")
        let selector = app.buttons["selectorAFP"]
        mostrar(selector)
        XCTAssertTrue(selector.label.contains("AFP Ejemplo"))
        escribir(horas, en: "horas25")
        escribir(horas, en: "horas35")
        escribir(adelanto, en: "adelanto")
    }

    private func seleccionar(_ opcion: String, en identificador: String) {
        let boton = app.segmentedControls[identificador].buttons[opcion]
        mostrar(boton)
        boton.tap()
    }

    private func escribir(_ valor: String, en identificador: String) {
        let campo = app.textFields[identificador]
        mostrar(campo)
        campo.tap()
        let actual = campo.value as? String ?? ""
        campo.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: actual.count) + valor)
        let listo = app.buttons["cerrarTeclado"]
        XCTAssertTrue(listo.waitForExistence(timeout: 3), "Falta el botón para cerrar el teclado")
        listo.tap()
    }

    private func calcular() {
        let boton = app.buttons["calcularBoleta"]
        mostrar(boton)
        boton.tap()
    }

    private func comprobar(_ identificador: String, _ esperado: String) {
        let importe = app.staticTexts[identificador]
        mostrar(importe)
        // ICU puede presentar es_PE con punto o coma decimal según la versión de iOS.
        let digitos = importe.label.filter { $0.isNumber }
        XCTAssertEqual(digitos, esperado.filter { $0.isNumber }, "Importe incorrecto en \(identificador): \(importe.label)")
    }

    private func mostrar(_ elemento: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(elemento.waitForExistence(timeout: 5), "No existe \(elemento)", file: file, line: line)
        let scroll = app.scrollViews["boletaScroll"]
        for _ in 0..<24 {
            if elemento.isHittable { return }
            if elemento.frame.midY < app.frame.midY {
                scroll.swipeDown()
            } else {
                scroll.swipeUp()
            }
        }
        XCTFail("No se pudo mostrar \(elemento)", file: file, line: line)
    }

    private func capturar(_ nombre: String) {
        let adjunto = XCTAttachment(screenshot: app.screenshot())
        adjunto.name = nombre
        adjunto.lifetime = .keepAlways
        add(adjunto)
    }
}
