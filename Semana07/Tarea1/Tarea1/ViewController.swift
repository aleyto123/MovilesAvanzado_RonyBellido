import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let culturas = CatalogoCulturas.todas

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Culturas peruanas"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backButtonTitle = "Culturas"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        culturas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaCultura", for: indexPath)
        let cultura = culturas[indexPath.row]

        var contenido = celda.defaultContentConfiguration()
        contenido.text = cultura.nombre
        contenido.secondaryText = cultura.region
        contenido.textProperties.font = .preferredFont(forTextStyle: .headline)
        contenido.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
        contenido.secondaryTextProperties.color = .secondaryLabel
        contenido.image = cultura.imagen
        contenido.imageProperties.maximumSize = CGSize(width: 64, height: 64)
        contenido.imageProperties.reservedLayoutSize = CGSize(width: 64, height: 64)
        contenido.imageProperties.cornerRadius = 12
        celda.contentConfiguration = contenido
        celda.accessoryType = .disclosureIndicator
        celda.accessibilityLabel = "Cultura \(cultura.nombre), \(cultura.region)"
        celda.accessibilityHint = "Muestra los detalles de esta cultura"
        return celda
    }

    // La fila seleccionada determina qué cultura se entrega al detalle.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cultura = culturas[indexPath.row]
        performSegue(withIdentifier: "mostrarDetalleCultura", sender: cultura)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "mostrarDetalleCultura",
              let detalle = segue.destination as? DetalleCulturaViewController,
              let cultura = sender as? Cultura else { return }

        detalle.cultura = cultura
    }
}
