import Foundation

// Datos locales: la aplicación puede consultarse sin conexión a internet.
enum CatalogoCulturas {
    static let todas: [Cultura] = [
        Cultura(
            nombre: "Chavín",
            region: "Áncash · Sierra central",
            descripcion: "Se desarrolló alrededor de Chavín de Huántar, un importante centro ceremonial de los Andes. Su arte en piedra representa seres con rasgos humanos y animales. Las cabezas clavas y el Lanzón son algunas de sus expresiones más conocidas.",
            nombreImagen: "chavin"
        ),
        Cultura(
            nombre: "Nazca",
            region: "Ica · Costa sur",
            descripcion: "Destacó por su cerámica policroma y por los grandes geoglifos trazados en el desierto. Las líneas de Nazca representan animales, plantas y formas geométricas. También desarrolló sistemas de conducción de agua para aprovechar el ambiente árido.",
            nombreImagen: "nazca"
        ),
        Cultura(
            nombre: "Moche",
            region: "La Libertad y Lambayeque · Costa norte",
            descripcion: "Se distinguió por su cerámica escultórica, sus trabajos en metal y sus construcciones de adobe. Las huacas del Sol y de la Luna muestran la importancia de sus centros ceremoniales. Sus piezas artísticas representan personajes, animales y escenas de su vida y sus rituales.",
            nombreImagen: "moche"
        ),
        Cultura(
            nombre: "Chimú",
            region: "La Libertad · Costa norte",
            descripcion: "Tuvo como capital a Chan Chan, una extensa ciudad construida en adobe cerca de Trujillo. Sus habitantes sobresalieron en la orfebrería y en el manejo del agua. Los relieves de sus muros incluyen peces, aves y otras figuras relacionadas con el mar.",
            nombreImagen: "chimu"
        ),
        Cultura(
            nombre: "Inca",
            region: "Cusco · Andes peruanos",
            descripcion: "Organizó el Tahuantinsuyo con su centro político en Cusco. Desarrolló una amplia red de caminos, terrazas agrícolas y construcciones de piedra. Machu Picchu es uno de los ejemplos más conocidos de su arquitectura y de su adaptación al paisaje andino.",
            nombreImagen: "inca"
        )
    ]
}
