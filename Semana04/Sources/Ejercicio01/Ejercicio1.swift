// ===== CASO 1.5: HERENCIA Y POLIMORFISMO — LA CADENA DE SUCURSALES =====

enum CategoriaElectro {
    case lineaBlanca, tecnologia, pequenos
}

struct Electrodomestico {
    let nombre: String
    let marca: String
    let precioLista: Double
    let categoria: CategoriaElectro
}

class Sucursal {
    let nombre: String
    let ciudad: String
    
    init(nombre: String, ciudad: String) {
        self.nombre = nombre
        self.ciudad = ciudad
    }
    
    func descuento() -> Double {
        return 0.05
    }
    
    func costoEnvio(monto: Double) -> Double {
        return 30.0
    }
    
    // REGLA 2: Este método NO se sobreescribe en subclases
    func cotizar(item: Electrodomestico) {
        let precioConDescuento = item.precioLista * (1 - descuento())
        let envio = costoEnvio(monto: precioConDescuento)
        let total = precioConDescuento + envio
        print("\(nombre): \(item.nombre) -> S/ \(precioConDescuento) + envio S/ \(envio) = S/ \(total)")
    }
}

// --- TODO 14: SucursalLima ---
class SucursalLima: Sucursal {
    override func descuento() -> Double {
        return 0.10
    }
    
    override func costoEnvio(monto: Double) -> Double {
        if monto >= 1500.0 {
            return 0.0
        } else {
            return 30.0
        }
    }
}

// --- TODO 15: SucursalProvincia ---
class SucursalProvincia: Sucursal {
    // REGLA 3: Hereda descuento() del 5% de la base sin sobreescribirlo
    override func costoEnvio(monto: Double) -> Double {
        let costoCalculado = monto * 0.08
        if costoCalculado < 50.0 {
            return 50.0
        } else {
            return costoCalculado
        }
    }
}

// --- TODO 16: SucursalOutlet ---
class SucursalOutlet: Sucursal {
    override func descuento() -> Double {
        return 0.25
    }
    
    override func costoEnvio(monto: Double) -> Double {
        return 0.0
    }
}

// --- TODO 18: Prueba de polimorfismo ---
class SucursalOnline: Sucursal {
    override func costoEnvio(monto: Double) -> Double {
        return 15.0
    }
}

// --- TODO 17: Recorrido polimórfico (REGLA 1, 4 y 5) ---
let refrigeradora = Electrodomestico(nombre: "Refrigeradora", marca: "Frost", precioLista: 2000.0, categoria: .lineaBlanca)
let licuadora = Electrodomestico(nombre: "Licuadora", marca: "Mix", precioLista: 250.0, categoria: .pequenos)

let sucursales: [Sucursal] = [
    SucursalLima(nombre: "Lima Centro", ciudad: "Lima"),
    SucursalProvincia(nombre: "Provincia Cusco", ciudad: "Cusco"),
    SucursalOutlet(nombre: "Outlet Ate", ciudad: "Lima")
]

print("===== Refrigeradora (S/ 2000.0) =====")
for sucursal in sucursales {
    sucursal.cotizar(item: refrigeradora)
}

print("===== Licuadora (S/ 250.0) =====")
for sucursal in sucursales {
    sucursal.cotizar(item: licuadora)
}

// ===== FIX =====

// FIX 7: Uso explícito de 'override'
class SucursalMall: Sucursal {
    override func descuento() -> Double {
        return 0.12
    }
}

// FIX 8: Llamada a 'super.init'
class SucursalExpress: Sucursal {
    let radioKm: Int
    init(nombre: String, ciudad: String, radioKm: Int) {
        self.radioKm = radioKm
        super.init(nombre: nombre, ciudad: ciudad)
    }
}

// ===== PREDICT =====
let misteriosa: Sucursal = SucursalLima(nombre: "Lima Centro", ciudad: "Lima")

print(misteriosa.descuento())

let monto = 2000.0 * (1 - misteriosa.descuento())
print(misteriosa.costoEnvio(monto: monto))