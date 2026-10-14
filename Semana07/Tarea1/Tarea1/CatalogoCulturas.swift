import Foundation

// Datos locales: la aplicación puede consultarse sin conexión a internet.
enum CatalogoCulturas {
    static let todas: [Cultura] = [
        Cultura(
            nombre: "Caral",
            region: "Lima · Valle de Supe",
            descripcion: "Se desarrolló en el valle de Supe y es una de las civilizaciones más antiguas de América. Sus habitantes construyeron edificios piramidales, plazas circulares y espacios para ceremonias. La Ciudad Sagrada de Caral muestra la organización y los conocimientos de esta sociedad.",
            nombreImagen: "caral"
        ),
        Cultura(
            nombre: "Paracas",
            region: "Ica · Costa sur",
            descripcion: "Se desarrolló en la costa sur del Perú y destacó por sus tejidos y bordados. Sus textiles combinan colores y figuras que representan personajes y animales. Los mantos formaban parte de sus prácticas funerarias y permiten conocer aspectos de sus creencias y su forma de vida.",
            nombreImagen: "paracas"
        ),
        Cultura(
            nombre: "Wari",
            region: "Ayacucho · Sierra central",
            descripcion: "Tuvo su centro principal cerca de la actual ciudad de Ayacucho. Destacó por sus asentamientos planificados, sus construcciones de piedra, su cerámica y sus textiles. El complejo arqueológico Wari conserva parte de la antigua capital de esta sociedad.",
            nombreImagen: "wari"
        ),
        Cultura(
            nombre: "Chachapoyas",
            region: "Amazonas · Andes nororientales",
            descripcion: "Se desarrolló en los bosques de montaña del nororiente peruano. Sus pobladores construyeron asentamientos de piedra con viviendas circulares y elaboraron espacios funerarios en lugares elevados. Kuélap es uno de los sitios más representativos de esta cultura.",
            nombreImagen: "chachapoyas"
        ),
        Cultura(
            nombre: "Lima",
            region: "Lima · Costa central",
            descripcion: "Se desarrolló en los valles de la costa central del Perú. Destacó por la construcción de centros ceremoniales de adobe y por sus actividades agrícolas. Huaca Pucllana, ubicada en el actual distrito de Miraflores, es uno de sus principales sitios arqueológicos.",
            nombreImagen: "lima"
        )
    ]
}
