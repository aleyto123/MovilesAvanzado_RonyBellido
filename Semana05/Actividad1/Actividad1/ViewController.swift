import UIKit

class ViewController: UIViewController {

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

    @IBAction func calcularPrestamo(_ sender: Any) {
        // 1. Obtener datos de los campos
        let P = Double(txtCapital.text ?? "") ?? 0
        let tasaAnual = Double(txtInteresAnual.text ?? "") ?? 0
        let anios = Double(txtAnios.text ?? "") ?? 0

        // 2. Validar que los datos ingresados sean mayores a cero
        if P <= 0 || tasaAnual <= 0 || anios <= 0 {
            lblCuotaMensual.text = "Ingresa valores válidos mayores a 0"
            lblMontoTotal.text = ""
            return
        }
        
        // El cálculo matemático se implementará en el siguiente paso
    }
}