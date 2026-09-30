import UIKit

class NuevaVentaViewController: UIViewController {

    @IBOutlet weak var txtElectrodomestico: UITextField!
    @IBOutlet weak var txtPrecioUnitario: UITextField!
    @IBOutlet weak var txtCantidad: UITextField!
    @IBOutlet weak var txtMeses: UITextField!
    @IBOutlet weak var txtInteresMensual: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btnCalcular(_ sender: UIButton) {
        let electrodomestico = txtElectrodomestico.text ?? ""
        let precio = Double(txtPrecioUnitario.text ?? "") ?? 0.0
        let cantidad = Int(txtCantidad.text ?? "") ?? 0
        let meses = Int(txtMeses.text ?? "") ?? 0
        let interes = Double(txtInteresMensual.text ?? "") ?? 0.0

        let oVenta = VentaModel(
            electrodomestico: electrodomestico,
            precioUnitario: precio,
            cantidad: cantidad,
            meses: meses,
            interesMensual: interes
        )

        let osb = UIStoryboard(name: "Main", bundle: nil)
        if let oResultado = osb.instantiateViewController(identifier: "ResultadoViewController") as? ResultadoViewController {
            oResultado.pVenta = oVenta
            self.show(oResultado, sender: nil)
        }
    }
}