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
        let P = Double(txtCapital.text ?? "") ?? 0
        let tasaAnual = Double(txtInteresAnual.text ?? "") ?? 0
        let anios = Double(txtAnios.text ?? "") ?? 0

        if P <= 0 || tasaAnual <= 0 || anios <= 0 {
            lblCuotaMensual.text = "Ingresa valores válidos mayores a 0"
            lblMontoTotal.text = ""
            return
        }

        // 3. Calcular tasa mensual (r) y número total de pagos (n)
        let r = (tasaAnual / 100) / 12
        let n = anios * 12

        // 4. Aplicar fórmula de cuota mensual: M = P * [ r * (1+r)^n / ((1+r)^n - 1) ]
        let factor = pow(1 + r, n)
        let M = P * ((r * factor) / (factor - 1))

        // 5. Calcular el monto total a pagar
        let montoTotal = M * n

        // 6. Mostrar resultados formateados a 2 decimales
        lblCuotaMensual.text = String(format: "Cuota mensual: $%.2f", M)
        lblMontoTotal.text = String(format: "Monto total a pagar: $%.2f", montoTotal)
    }
}