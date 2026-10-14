import UIKit

class DetalleCulturaViewController: UIViewController {
    // La pantalla de lista entrega la cultura seleccionada antes de navegar.
    var cultura: Cultura?

    @IBOutlet private weak var fotoCultura: UIImageView!
    @IBOutlet private weak var nombreCultura: UILabel!
    @IBOutlet private weak var regionCultura: UILabel!
    @IBOutlet private weak var descripcionCultura: UILabel!
    @IBOutlet private weak var creditoImagen: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let cultura = cultura else { return }

        title = cultura.nombre
        nombreCultura.text = cultura.nombre
        regionCultura.text = "Región: \(cultura.region)"
        descripcionCultura.text = cultura.descripcion
        fotoCultura.image = cultura.imagen
        fotoCultura.accessibilityLabel = "Imagen representativa de la cultura \(cultura.nombre)"
        fotoCultura.isAccessibilityElement = true
        nombreCultura.accessibilityTraits = .header

        let autores = [
            "chavin": "kcorac · CC BY-SA 4.0",
            "nazca": "PsamatheM · CC BY-SA 4.0",
            "moche": "Velvet · CC BY-SA 4.0",
            "chimu": "David Holt · CC BY-SA 3.0",
            "inca": "Lindaazucena00 · CC BY-SA 4.0"
        ]
        creditoImagen.text = "Fotografía: \(autores[cultura.nombreImagen] ?? "Wikimedia Commons")\nWikimedia Commons"
    }
}
