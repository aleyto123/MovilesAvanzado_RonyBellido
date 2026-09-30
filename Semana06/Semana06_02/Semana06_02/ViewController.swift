import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tfApellido: UITextField!
    @IBOutlet weak var tfNombre: UITextField!
    @IBOutlet weak var tfDni: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btnContinuar(_ sender: Any) {
        let oCliente = ClienteModel(
            pCodigo: 0,
            pApellido: self.tfApellido.text ?? "",
            pNombre: self.tfNombre.text ?? "",
            pDni: self.tfDni.text ?? ""
        )
        
        // Crear el Storyboard con el nombre Main y asociarlo a la pantalla de confirmación
        let osb = UIStoryboard(name: "Main", bundle: nil)
        let oPantalla2 = osb.instantiateViewController(identifier: "ViewControllerConfirmacion") as! ViewControllerConfirmacion
        
        // Le pasamos los datos del cliente
        oPantalla2.pCliente = oCliente
        self.present(oPantalla2, animated: true, completion: nil)
    }
}
