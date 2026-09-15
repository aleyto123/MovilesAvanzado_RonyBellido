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

    func mostrarDatos() {
        print("Código: \(codigo)")
        print("Dirección: \(direccion)")
        print("Fecha de registro: \(fechaRegistro)")
        print("N° Cuenta: \(numeroCuenta)")
        print("Monto mínimo de apertura: S/ \(String(format: "%.2f", montoMinimoApertura))")
    }
}

// Cliente natural.
class ClienteNatural: Cliente {
    let nombreCompleto: String
    let dni: String

    init(
        nombreCompleto: String,
        dni: String,
        codigo: String,
        direccion: String,
        fechaRegistro: String,
        numeroCuenta: String,
        montoMinimoApertura: Double
    ) {
        self.nombreCompleto = nombreCompleto
        self.dni = dni

        super.init(
            codigo: codigo,
            direccion: direccion,
            fechaRegistro: fechaRegistro,
            numeroCuenta: numeroCuenta,
            montoMinimoApertura: montoMinimoApertura
        )
    }

    override func mostrarDatos() {
        print("👤 Cliente Natural:")
        print("Nombre: \(nombreCompleto)")
        print("DNI: \(dni)")
        print("Código: \(codigo)")
        print("Dirección: \(direccion)")
        print("Fecha de registro: \(fechaRegistro)")
        print("N° Cuenta: \(numeroCuenta)")
        print("Monto mínimo de apertura: S/ \(String(format: "%.2f", montoMinimoApertura))")
    }
}

// Cliente jurídico.
class ClienteJuridico: Cliente {
    let razonSocial: String
    let ruc: String
    let representanteLegal: String

    init(
        razonSocial: String,
        ruc: String,
        representanteLegal: String,
        codigo: String,
        direccion: String,
        fechaRegistro: String,
        numeroCuenta: String,
        montoMinimoApertura: Double
    ) {
        self.razonSocial = razonSocial
        self.ruc = ruc
        self.representanteLegal = representanteLegal

        super.init(
            codigo: codigo,
            direccion: direccion,
            fechaRegistro: fechaRegistro,
            numeroCuenta: numeroCuenta,
            montoMinimoApertura: montoMinimoApertura
        )
    }

    // Sobrescribe el método de la clase padre.
    override func mostrarDatos() {
        print("🏢 Cliente Jurídico:")
        print("Razón Social: \(razonSocial)")
        print("RUC: \(ruc)")
        print("Representante Legal: \(representanteLegal)")
        print("Código: \(codigo)")
        print("Dirección: \(direccion)")
        print("Fecha de registro: \(fechaRegistro)")
        print("N° Cuenta: \(numeroCuenta)")
        print("Monto mínimo de apertura: S/ \(String(format: "%.2f", montoMinimoApertura))")
    }
}

// ===== DATOS DE LOS CLIENTES =====

// Cliente natural.
let clienteNatural = ClienteNatural(
    nombreCompleto: "Rony Bellido",
    dni: "12345678",
    codigo: "C001",
    direccion: "Av. Lima 123",
    fechaRegistro: "2025-04-03",
    numeroCuenta: "001-202500123",
    montoMinimoApertura: 500.00
)

// Cliente jurídico.
let clienteJuridico = ClienteJuridico(
    razonSocial: "Soluciones SAC",
    ruc: "20123456789",
    representanteLegal: "Rony Bellido",
    codigo: "C002",
    direccion: "Jr. Empresas 456",
    fechaRegistro: "2025-04-01",
    numeroCuenta: "001-202500456",
    montoMinimoApertura: 3000.00
)


// ===== RECORRIDO POLIMÓRFICO =====

// Guardamos ambos clientes como Cliente.
let clientes: [Cliente] = [
    clienteNatural,
    clienteJuridico
]

// Recorremos todos los clientes.
for cliente in clientes {
    cliente.mostrarDatos()
    print("----------------------------")
}