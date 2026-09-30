import UIKit

class VentaModel: NSObject {
    var electrodomestico: String = ""
    var precioUnitario: Double = 0.0
    var cantidad: Int = 0
    var meses: Int = 0
    var interesMensual: Double = 0.0
    
    init(electrodomestico: String, precioUnitario: Double, cantidad: Int, meses: Int, interesMensual: Double) {
        self.electrodomestico = electrodomestico
        self.precioUnitario = precioUnitario
        self.cantidad = cantidad
        self.meses = meses
        self.interesMensual = interesMensual
    }
    
    var subtotal: Double {
        return precioUnitario * Double(cantidad)
    }
    
    var igv: Double {
        return subtotal * 0.18
    }
    
    var base: Double {
        return subtotal + igv
    }
    
    var interesesTotales: Double {
        return base * (interesMensual / 100.0) * Double(meses)
    }
    
    var totalPagar: Double {
        return base + interesesTotales
    }
    
    var cuotaMensual: Double {
        return meses > 0 ? totalPagar / Double(meses) : 0.0
    }
}