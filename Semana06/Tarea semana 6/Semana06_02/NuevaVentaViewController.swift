import UIKit

class NuevaVentaViewController: UIViewController {
    @IBOutlet weak var txtElectrodomestico: UITextField!
    @IBOutlet weak var txtPrecioUnitario: UITextField!
    @IBOutlet weak var txtCantidad: UITextField!
    @IBOutlet weak var txtMeses: UITextField!
    @IBOutlet weak var txtInteresMensual: UITextField!

    @IBAction func calcular(_ sender: UIButton) {
        guard !(txtElectrodomestico.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty,
              let precioUnitario = Double(txtPrecioUnitario.text ?? ""), precioUnitario > 0,
              let cantidad = Double(txtCantidad.text ?? ""), cantidad > 0,
              let meses = Double(txtMeses.text ?? ""), meses > 0,
              let interesMensual = Double(txtInteresMensual.text ?? ""), interesMensual >= 0 else {
            let alerta = UIAlertController(title: "Datos incompletos", message: "Ingresa valores válidos en todos los campos.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
            present(alerta, animated: true)
            return
        }

        let subtotal = precioUnitario * cantidad
        let igv = subtotal * 0.18
        let base = subtotal + igv
        let intereses = base * (interesMensual / 100) * meses
        let total = base + intereses
        let cuota = total / meses

        let venta = VentaModel(subtotal: subtotal, igv: igv, base: base, intereses: intereses, total: total, cuota: cuota)
        performSegue(withIdentifier: "showResultado", sender: venta)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResultado",
           let resultado = segue.destination as? ResultadoViewController,
           let venta = sender as? VentaModel {
            resultado.venta = venta
        }
    }
}
