import XCTest
import CoreGraphics

final class BoletaUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(es)", "-AppleLocale", "es_PE"]
        app.launch()
        XCTAssertTrue(app.textFields["sueldo"].waitForExistence(timeout: 15))
        escribir("2500", en: "sueldo")
    }

    func testCaso1ONP() {
        calcular()
        comprobar("importe.Total remuneraciones", "2500.00")
        comprobar("importe.ONP", "325.00")
        comprobar("importe.AFP fondo", "0.00")
        comprobar("netoPagar", "2175.00")
        capturar("caso-1")
    }

    func testCaso2ConHijosY27Dias() {
        escribir("1800", en: "sueldo")
        escribir("27", en: "dias")
        seleccionar("Sí", en: "tieneHijos")
        calcular()
        comprobar("importe.Asignación familiar", "123.00")
        comprobar("importe.Total remuneraciones", "1743.00")
        comprobar("netoPagar", "1516.41")
        capturar("caso-2")
    }

    func testCaso3AFPExtrasYAdelanto() {
        completarAFP(sueldo: "3000", dias: "30", horas: "4", adelanto: "200")
        calcular()
        comprobar("importe.Horas extras 25%", "62.50")
        comprobar("importe.Horas extras 35%", "67.50")
        comprobar("importe.AFP fondo", "325.30")
        comprobar("importe.AFP comisión", "52.05")
        comprobar("importe.AFP seguro", "43.92")
        comprobar("importe.Total descuentos", "621.27")
        comprobar("netoPagar", "2631.73")
        capturar("caso-3")
    }

    func testCaso4Evaluacion() {
        completarAFP(sueldo: "4200", dias: "24", horas: "2", adelanto: "100")
        calcular()
        comprobar("importe.Sueldo computable", "3360.00")
        comprobar("importe.Total remuneraciones", "3574.00")
        comprobar("importe.Total descuentos", "562.83")
        comprobar("importe.EsSalud (9%)", "321.66")
        comprobar("netoPagar", "3011.17")
        capturar("caso-4")
    }

    func testCambioDeAFPCambiaElNeto() {
        seleccionar("AFP", en: "sistemaPension")
        let selector = app.buttons["selectorAFP"]
        mostrar(selector)
        selector.tap()
        app.buttons["Prima (flujo)"].tap()
        calcular()
        comprobar("netoPagar", "2175.75")
    }

    func testDiasInvalidosRetiranLaBoletaAnterior() {
        calcular()
        comprobar("netoPagar", "2175.00")
        escribir("31", en: "dias")
        XCTAssertFalse(app.staticTexts["netoPagar"].exists)
        calcular()
        let mensaje = app.staticTexts["errorValidacion"]
        mostrar(mensaje)
        XCTAssertTrue(mensaje.label.contains("entre 1 y 30"))
        XCTAssertFalse(app.staticTexts["netoPagar"].exists)
        capturar("validacion-dias")
    }

    private func completarAFP(sueldo: String, dias: String, horas: String, adelanto: String) {
        escribir(sueldo, en: "sueldo")
        escribir(dias, en: "dias")
        seleccionar("Sí", en: "tieneHijos")
        seleccionar("AFP", en: "sistemaPension")
        XCTAssertTrue(app.buttons["selectorAFP"].exists)
        escribir(horas, en: "horas25")
        escribir(horas, en: "horas35")
        escribir(adelanto, en: "adelanto")
    }

    private func seleccionar(_ opcion: String, en id: String) {
        let boton = app.segmentedControls[id].buttons[opcion]
        mostrar(boton)
        boton.tap()
    }

    private func escribir(_ texto: String, en id: String) {
        let campo = app.textFields[id]
        mostrar(campo)
        // El extremo derecho sitúa el cursor al final del importe existente.
        campo.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
        let anterior = campo.value as? String ?? ""
        let contenido = anterior.hasPrefix("Ej.") ? "" : anterior
        campo.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: contenido.count) + texto)
        app.scrollViews["boletaScroll"].swipeUp()
    }

    private func calcular() {
        let boton = app.buttons["calcularBoleta"]
        mostrar(boton)
        boton.tap()
    }

    private func comprobar(_ id: String, _ esperado: String) {
        let importe = app.staticTexts[id]
        mostrar(importe)
        XCTAssertEqual(importe.label.filter { $0.isNumber }, esperado.filter { $0.isNumber }, id)
    }

    private func mostrar(_ elemento: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(elemento.waitForExistence(timeout: 5), "No existe \(elemento)", file: file, line: line)
        for _ in 0..<24 {
            if elemento.isHittable { return }
            if elemento.frame.midY < app.frame.midY {
                app.scrollViews["boletaScroll"].swipeDown()
            } else {
                app.scrollViews["boletaScroll"].swipeUp()
            }
        }
        XCTFail("No se pudo mostrar \(elemento)", file: file, line: line)
    }

    private func capturar(_ nombre: String) {
        let imagen = XCTAttachment(screenshot: app.screenshot())
        imagen.name = nombre
        imagen.lifetime = .keepAlways
        add(imagen)
    }
}
