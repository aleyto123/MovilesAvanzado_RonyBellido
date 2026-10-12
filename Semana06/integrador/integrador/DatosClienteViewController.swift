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
        
        // La emision de la boleta se incorpora en la siguiente etapa.
    }
    

    
    func mostrarAlerta(_ mensaje: String) {
        let alert = UIAlertController(title: "Validación", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}