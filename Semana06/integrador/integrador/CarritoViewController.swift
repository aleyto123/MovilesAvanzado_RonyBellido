import UIKit

class CarritoViewController: UIViewController {
    var carrito: CarritoModel!
    
    @IBOutlet weak var txtResumen: UITextView!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblDescuento: UILabel!
    @IBOutlet weak var lblIGV: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        actualizarResumen()
    }
    
    func actualizarResumen() {
        var texto = ""
        for item in carrito.items {
            texto += "\(item.producto.nombre) x\(item.cantidad) - S/ \(String(format: "%.2f", item.subtotal()))\n"
        }
        txtResumen.text = texto.isEmpty ? "El carrito está vacío." : texto
        
        lblSubtotal.text = String(format: "S/ %.2f", carrito.subtotal())
        lblDescuento.text = String(format: "-S/ %.2f (%.0f%%)", carrito.montoDescuento(), carrito.porcentajeDescuento() * 100)
        lblIGV.text = String(format: "S/ %.2f", carrito.igv())
        lblTotal.text = String(format: "S/ %.2f", carrito.total())
    }
    
    @IBAction func irDatosClienteTapped(_ sender: UIButton) {
        if carrito.items.isEmpty {
            let alert = UIAlertController(title: "Carrito vacío", message: "Agregue productos antes de continuar.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        performSegue(withIdentifier: "irDatosCliente", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irDatosCliente" {
            let destino = segue.destination as! DatosClienteViewController
            destino.carrito = carrito
        }
    }
}