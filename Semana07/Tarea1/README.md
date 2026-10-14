# Tarea 1: Culturas peruanas

Aplicación de UIKit con Storyboard para explorar culturas peruanas.

## Ejecución

Abrir `Tarea1.xcodeproj` en Xcode, seleccionar el esquema **Tarea1** y ejecutar la aplicación en un simulador o dispositivo iOS.

## Requerimientos funcionales

Los requerimientos de la aplicación se describen en [REQUERIMIENTOS_FUNCIONALES.md](REQUERIMIENTOS_FUNCIONALES.md).

## Funcionamiento

La pantalla inicial muestra Chavín, Nazca, Moche, Chimú e Inca. Cada fila incluye una imagen, el nombre y la región. Al tocar una fila, el segue `mostrarDetalleCultura` abre `DetalleCulturaViewController`; `prepare(for:sender:)` entrega la cultura seleccionada. El botón Culturas permite regresar a la lista.

El detalle utiliza un UIScrollView y un UIStackView con Auto Layout para mostrar la imagen completa, el nombre, la región, la descripción y el autor de la fotografía. Los textos admiten varias líneas y el tamaño de letra del sistema.

## Fuentes

- [Chavín de Huántar, UNESCO](https://whc.unesco.org/en/list/330/)
- [Líneas y geoglifos de Nasca y Palpa, UNESCO](https://whc.unesco.org/en/list/700/)
- [Chan Chan, UNESCO](https://whc.unesco.org/en/list/366/)
- [Machu Picchu, UNESCO](https://whc.unesco.org/en/list/274/)
- [Huaca de la Luna, Wikimedia Commons](https://commons.wikimedia.org/wiki/Category:Huaca_de_la_Luna)

Las fotografías y sus licencias se documentan en `CREDITOS_IMAGENES.md`.
