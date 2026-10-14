# Tarea 1: Culturas peruanas

Aplicación de UIKit con Storyboard para explorar culturas peruanas.

## Ejecución

Abrir `Tarea1.xcodeproj` en Xcode, seleccionar el esquema **Tarea1** y ejecutar la aplicación en un simulador o dispositivo iOS.

## Requerimientos funcionales

Los requerimientos de la aplicación se describen en [REQUERIMIENTOS_FUNCIONALES.md](REQUERIMIENTOS_FUNCIONALES.md).

## Funcionamiento

La pantalla inicial muestra Caral, Paracas, Wari, Chachapoyas y Lima. Cada fila incluye una imagen, el nombre y la región. Al tocar una fila, el segue `mostrarDetalleCultura` abre `DetalleCulturaViewController`; `prepare(for:sender:)` entrega la cultura seleccionada. El botón Culturas permite regresar a la lista.

El detalle utiliza un UIScrollView y un UIStackView con Auto Layout para mostrar la imagen completa, el nombre, la región, la descripción y el autor de la fotografía. Los textos admiten varias líneas y el tamaño de letra del sistema.

## Culturas incluidas

| Cultura | Región | Imagen representativa |
|---|---|---|
| Caral | Lima · Valle de Supe | Ciudad Sagrada de Caral |
| Paracas | Ica · Costa sur | Fragmento textil bordado |
| Wari | Ayacucho · Sierra central | Complejo Arqueológico Wari |
| Chachapoyas | Amazonas · Andes nororientales | Muros y entrada de Kuélap |
| Lima | Lima · Costa central | Huaca Pucllana |

## Fuentes

- [Ciudad Sagrada de Caral-Supe, UNESCO](https://whc.unesco.org/en/list/1269/)
- [Manto Paracas, Museo Larco](https://www.museolarco.org/en/exhibition/permanent-exhibition/masterpieces/paracas-mantle/)
- [Complejo Arqueológico Wari, Ministerio de Cultura](https://www.gob.pe/institucion/cultura/noticias/641571-ayacucho-ministerio-de-cultura-impulsa-proyecto-para-mejorar-y-conservar-el-complejo-arqueologico-wari)
- [Kuélap, Ministerio de Cultura](https://kuelap.cultura.pe/)
- [Museo de Sitio Pucllana, Ministerio de Cultura](https://museos.cultura.pe/index.php/museos/museo-de-sitio-pucllana)

Las imágenes y sus licencias se documentan en `CREDITOS_IMAGENES.md`.
