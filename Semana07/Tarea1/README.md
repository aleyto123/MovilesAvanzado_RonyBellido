# Tarea 1: Culturas peruanas

Aplicación de UIKit con Storyboard para explorar culturas peruanas.

## Desarrollo progresivo

1. Proyecto y modelo `Cultura` con catálogo local.
2. Imágenes representativas en Assets y créditos.
3. Lista de culturas mediante UITableView.
4. Pantalla de detalle con nombre, región, descripción e imagen.
5. Navegación desde la lista al detalle y revisión de conexiones.

Abrir `Tarea1.xcodeproj` en Xcode. La compilación y la ejecución se realizan manualmente.

## Funcionamiento

La pantalla inicial muestra Chavín, Nazca, Moche, Chimú e Inca. Cada fila incluye una imagen, el nombre y la región. Al tocar una fila, el segue `mostrarDetalleCultura` abre `DetalleCulturaViewController`; `prepare(for:sender:)` entrega la cultura seleccionada. El botón Culturas permite regresar a la lista.

El detalle utiliza un UIScrollView y un UIStackView con Auto Layout para mostrar la imagen completa, el nombre, la región, la descripción y el autor de la fotografía. Los textos admiten varias líneas y el tamaño de letra del sistema.

## Revisión manual en Xcode

1. Abrir `Tarea1.xcodeproj` y seleccionar el esquema Tarea1.
2. Ejecutar en un simulador de iPhone.
3. Comprobar que las cinco filas muestran sus nombres e imágenes.
4. Seleccionar cada cultura y comprobar que nombre, región, descripción e imagen corresponden a la fila.
5. Volver con el botón Culturas y seleccionar otra fila.
6. Probar la vista de detalle en horizontal y con texto grande; el contenido debe poder desplazarse.

No se ha compilado ni ejecutado automáticamente, por preferencia del usuario.

## Fuentes

- [Chavín de Huántar, UNESCO](https://whc.unesco.org/en/list/330/)
- [Líneas y geoglifos de Nasca y Palpa, UNESCO](https://whc.unesco.org/en/list/700/)
- [Chan Chan, UNESCO](https://whc.unesco.org/en/list/366/)
- [Machu Picchu, UNESCO](https://whc.unesco.org/en/list/274/)
- [Huaca de la Luna, Wikimedia Commons](https://commons.wikimedia.org/wiki/Category:Huaca_de_la_Luna)

Las fotografías y sus licencias se documentan en `CREDITOS_IMAGENES.md`.
