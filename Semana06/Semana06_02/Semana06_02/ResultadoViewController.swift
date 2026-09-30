import UIKit

class ResultadoViewController: UIViewController {

    var pVenta: VentaModel?

    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblIGV: UILabel!
    @IBOutlet weak var lblBase: UILabel!
    @IBOutlet weak var lblIntereses: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblCuotaMensual: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let venta = pVenta {
            lblSubtotal.text = String(format: "S/. %.2f", venta.subtotal)
            lblIGV.text = String(format: "S/. %.2f", venta.igv)
            lblBase.text = String(format: "S/. %.2f", venta.base)
            lblIntereses.text = String(format: "S/. %.2f", venta.interesesTotales)
            lblTotal.text = String(format: "S/. %.2f", venta.totalPagar)
            lblCuotaMensual.text = String(format: "S/. %.2f", venta.cuotaMensual)
        }
    }
}