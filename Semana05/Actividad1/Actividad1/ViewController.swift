import UIKit

class ViewController: UIViewController {

    // Conexiones de la interfaz (Outlets)
    @IBOutlet weak var txtCapital: UITextField!
    @IBOutlet weak var txtInteresAnual: UITextField!
    @IBOutlet weak var txtAnios: UITextField!
    
    @IBOutlet weak var lblCuotaMensual: UILabel!
    @IBOutlet weak var lblMontoTotal: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        lblCuotaMensual.text = "Cuota mensual: $0.00"
        lblMontoTotal.text = "Monto total: $0.00"
    }
}