import UIKit

class BoletaViewController: UIViewController {
    var carrito: CarritoModel!
    var cliente: ClienteModel!
    
    @IBOutlet weak var txtBoleta: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generarBoleta()
    }
    
    func generarBoleta() {
        var texto = "=========== BOLETA DE COMPRA ===========\n"
        texto += "Cliente: \(cliente.nombre) (\(cliente.categoria)) DNI: \(cliente.dni)\n"
        texto += "----------------------------------------\n"
        for item in carrito.items {
            texto += "\(item.producto.nombre) x\(item.cantidad) S/ \(String(format: "%.2f", item.subtotal()))\n"
        }
        texto += "----------------------------------------\n"
        texto += String(format: "Subtotal: S/ %.2f\n", carrito.subtotal())
        texto += String(format: "Descuento (%.0f%%): -S/ %.2f\n", carrito.porcentajeDescuento() * 100, carrito.montoDescuento())
        texto += String(format: "IGV (18%%): S/ %.2f\n", carrito.igv())
        texto += String(format: "TOTAL: S/ %.2f\n", carrito.total())
        texto += "========================================"
        
        txtBoleta.text = texto
    }
    
    @IBAction func confirmarYFinalizar(_ sender: UIButton) {
        carrito.confirmarCompra()
        dismiss(animated: true)
    }
}