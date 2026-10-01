import UIKit

class ViewControllerConfirmacion: UIViewController {

    // Instanciar la clase ClienteModel
    var pCliente = ClienteModel(pCodigo: 0, pApellido: "", pNombre: "", pDni: "")

    // Definir los controles (Labels)
    @IBOutlet weak var tfApellido: UILabel!
    @IBOutlet weak var tfNombre: UILabel!
    @IBOutlet weak var tfDni: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Mostrar los datos en los controles
        tfApellido.text = pCliente.apellido
        tfNombre.text = pCliente.nombre
        tfDni.text = pCliente.dni
    }
    
    @IBAction func btnVolver(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
