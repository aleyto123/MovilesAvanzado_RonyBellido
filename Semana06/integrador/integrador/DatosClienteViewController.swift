import UIKit

class DatosClienteViewController: UIViewController {
    var carrito: CarritoModel!
    
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtDNI: UITextField!
    
    @IBAction func generarBoletaTapped(_ sender: UIButton) {
        guard let nombre = txtNombre.text, !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
              let dni = txtDNI.text, !dni.trimmingCharacters(in: .whitespaces).isEmpty else {
            mostrarAlerta("Todos los campos son obligatorios.")
            return
        }
        
        if dni.count != 8 || Int(dni) == nil {
            mostrarAlerta("El DNI debe tener exactamente 8 dígitos numéricos.")
            return
        }
        
        performSegue(withIdentifier: "verBoleta", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verBoleta" {
            let destino = segue.destination as! BoletaViewController
            destino.cliente = ClienteModel(nombre: txtNombre.text!, dni: txtDNI.text!, categoria: carrito.categoriaCliente())
            destino.carrito = carrito
        }
    }
    
    func mostrarAlerta(_ mensaje: String) {
        let alert = UIAlertController(title: "Validación", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}