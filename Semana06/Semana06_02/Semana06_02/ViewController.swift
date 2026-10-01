import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tfApellido: UITextField!
    @IBOutlet weak var tfNombre: UITextField!
    @IBOutlet weak var tfDni: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfApellido.delegate = self
        tfNombre.delegate = self
        tfDni.delegate = self
    }

    @IBAction func btnContinuar(_ sender: UIButton) {
        let oCliente = ClienteModel(
            pCodigo: 0,
            pApellido: self.tfApellido.text ?? "",
            pNombre: self.tfNombre.text ?? "",
            pDni: self.tfDni.text ?? ""
        )
        
        // Crear el Storyboard con el nombre Main y asociarlo a la pantalla de confirmación
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let pantalla2 = storyboard.instantiateViewController(withIdentifier: "ViewControllerConfirmacion") as? ViewControllerConfirmacion else { return }
        pantalla2.pCliente = oCliente
        navigationController?.pushViewController(pantalla2, animated: true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
