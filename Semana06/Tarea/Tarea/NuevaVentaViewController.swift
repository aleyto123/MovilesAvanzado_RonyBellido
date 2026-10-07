import UIKit

class NuevaVentaViewController: UIViewController {
    @IBOutlet weak var txtElectrodomestico: UITextField!
    @IBOutlet weak var txtPrecioUnitario: UITextField!
    @IBOutlet weak var txtCantidad: UITextField!
    @IBOutlet weak var txtMeses: UITextField!
    @IBOutlet weak var txtInteresMensual: UITextField!

    @IBAction func calcular(_ sender: UIButton) {
        let precioUnitario = Double(txtPrecioUnitario.text ?? "") ?? 0
        let cantidad = Double(txtCantidad.text ?? "") ?? 0
        let meses = Double(txtMeses.text ?? "") ?? 0
        let interesMensual = Double(txtInteresMensual.text ?? "") ?? 0

        let subtotal = precioUnitario * cantidad
        let igv = subtotal * 0.18
        let base = subtotal + igv
        let intereses = base * (interesMensual / 100) * meses
        let total = base + intereses
        let cuota = meses > 0 ? total / meses : 0

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
