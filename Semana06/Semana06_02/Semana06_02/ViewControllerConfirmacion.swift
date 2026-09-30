import UIKit

class ViewControllerConfirmacion: UIViewController {

    // Instanciar la clase ClienteModel
    var pCliente: ClienteModel = ClienteModel()

    // Definir los controles (Labels)
    @IBOutlet weak var tfApellido: UILabel!
    @IBOutlet weak var tfNombre: UILabel!
    @IBOutlet weak var tfDni: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Mostrar los datos en los controles
        self.tfApellido.text = pCliente.Apellido
        self.tfNombre.text = pCliente.Nombre
        self.tfDni.text = pCliente.Dni
    }
    
    @IBAction func btnVolver(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
