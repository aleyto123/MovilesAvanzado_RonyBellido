import UIKit

class DetalleViewController: UIViewController {
    var producto: Producto!
    var carrito: CarritoModel!
    
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblPrecio: UILabel!
    @IBOutlet weak var lblStock: UILabel!
    @IBOutlet weak var txtCantidad: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNombre.text = producto.nombre
        lblPrecio.text = String(format: "S/ %.2f", producto.precio)
        lblStock.text = "Stock disponible: \(producto.stock)"
        txtCantidad.text = "1"
    }
    
    @IBAction func agregarAlCarrito(_ sender: UIButton) {
        guard let texto = txtCantidad.text, let cantidad = Int(texto), cantidad > 0 else {
            mostrarAlerta(titulo: "Error", mensaje: "Ingrese una cantidad válida.")
            return
        }
        
        let exito = carrito.agregar(producto: producto, cantidad: cantidad)
        if exito {
            navigationController?.popViewController(animated: true)
        } else {
            mostrarAlerta(titulo: "Stock insuficiente", mensaje: "No hay suficiente stock disponible.")
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}