import Foundation

// ===== ACTIVIDAD PROPUESTA 02 =====

// Clase base que representa un cliente.
class Cliente {
    let codigo: String
    let direccion: String
    let fechaRegistro: String
    let numeroCuenta: String
    let montoMinimoApertura: Double

    init(
        codigo: String,
        direccion: String,
        fechaRegistro: String,
        numeroCuenta: String,
        montoMinimoApertura: Double
    ) {
        self.codigo = codigo
        self.direccion = direccion
        self.fechaRegistro = fechaRegistro
        self.numeroCuenta = numeroCuenta
        self.montoMinimoApertura = montoMinimoApertura
    }

    // Método que será sobrescrito por las clases hijas.
    func mostrarDatos() {
        print("Código: \(codigo)")
        print("Dirección: \(direccion)")
        print("Fecha de registro: \(fechaRegistro)")
        print("N° Cuenta: \(numeroCuenta)")
        print("Monto mínimo de apertura: S/ \(String(format: "%.2f", montoMinimoApertura))")
    }
}