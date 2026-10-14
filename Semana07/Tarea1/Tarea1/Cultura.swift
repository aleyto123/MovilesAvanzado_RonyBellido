import UIKit

// Modelo de datos que comparten la lista y la pantalla de detalle.
struct Cultura {
    let nombre: String
    let region: String
    let descripcion: String
    let nombreImagen: String

    var imagen: UIImage? {
        UIImage(named: nombreImagen)
    }
}
