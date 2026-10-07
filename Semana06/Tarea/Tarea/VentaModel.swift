import Foundation

class VentaModel: NSObject {
    let subtotal: Double
    let igv: Double
    let base: Double
    let intereses: Double
    let total: Double
    let cuota: Double

    init(subtotal: Double, igv: Double, base: Double, intereses: Double, total: Double, cuota: Double) {
        self.subtotal = subtotal
        self.igv = igv
        self.base = base
        self.intereses = intereses
        self.total = total
        self.cuota = cuota
    }
}
