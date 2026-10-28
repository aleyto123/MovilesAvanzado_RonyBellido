import XCTest
import CoreGraphics

final class CTSUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(es)", "-AppleLocale", "es_PE"]
        app.launch()
        XCTAssertTrue(app.navigationBars["CTS"].waitForExistence(timeout: 15))
    }

    func testCTSSemestral() {
        calcular("cts")
        comprobar("cts.total", "1750.00")
    }

    func testCTSFraccionYResultadoSeRetiraAlEditar() {
        calcular("cts")
        comprobar("cts.total", "1750.00")
        escribir("3", campo: "cts.meses")
        escribir("15", campo: "cts.dias")
        XCTAssertFalse(app.staticTexts["cts.total"].exists)
        calcular("cts")
        comprobar("cts.total", "1020.83")
    }

    func testGratificacionEsSaludYEPS() {
        app.tabBars.buttons["Gratificación"].tap()
        calcular("grati")
        comprobar("grati.total", "3270.00")
        inicio()
        let eps = app.segmentedControls["grati.cobertura"].buttons["EPS"]
        mostrar(eps)
        eps.tap()
        XCTAssertFalse(app.staticTexts["grati.total"].exists)
        calcular("grati")
        comprobar("grati.total", "3202.50")
    }

    func testVacacionesGoce() {
        app.tabBars.buttons["Vacaciones"].tap()
        XCTAssertFalse(app.textFields["vac.mesesTruncos"].exists)
        calcular("vac")
        comprobar("vac.total", "1500.00")
    }

    func testVacacionesAlCeseMuestraCamposYDesglose() {
        app.tabBars.buttons["Vacaciones"].tap()
        let cese = app.segmentedControls["vac.situacion"].buttons["Cese"]
        mostrar(cese)
        cese.tap()
        mostrar(app.textFields["vac.mesesTruncos"])
        XCTAssertFalse(app.textFields["vac.solicitados"].exists)
        calcular("vac")
        comprobar("vac.total", "4125.00")
    }

    func testSueldoInvalidoNoConservaResultado() {
        calcular("cts")
        comprobar("cts.total", "1750.00")
        escribir("0", campo: "cts.sueldo")
        calcular("cts")
        let error = app.descendants(matching: .any).matching(identifier: "cts.error").firstMatch
        mostrar(error)
        XCTAssertFalse(app.staticTexts["cts.total"].exists)
    }

    private func inicio() {
        for _ in 0..<7 { app.swipeDown() }
    }

    private func mostrar(_ elemento: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        for _ in 0..<18 {
            if elemento.exists && elemento.isHittable { return }
            if elemento.exists && elemento.frame.maxY < app.frame.midY { app.swipeDown() }
            else { app.swipeUp() }
        }
        XCTFail("No se pudo mostrar \(elemento)", file: file, line: line)
    }

    private func escribir(_ texto: String, campo id: String) {
        inicio()
        let campo = app.textFields[id]
        mostrar(campo)
        campo.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
        let anterior = campo.value as? String ?? ""
        campo.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: anterior.count) + texto)
        let listo = app.buttons["Listo"]
        if listo.waitForExistence(timeout: 3) { listo.tap() }
    }

    private func calcular(_ prefijo: String) {
        let boton = app.buttons[prefijo + ".calcular"]
        mostrar(boton)
        boton.tap()
    }

    private func comprobar(_ id: String, _ esperado: String, file: StaticString = #filePath, line: UInt = #line) {
        let valor = app.staticTexts[id]
        mostrar(valor, file: file, line: line)
        XCTAssertEqual(valor.label.filter(\.isNumber), esperado.filter(\.isNumber), file: file, line: line)
    }
}
