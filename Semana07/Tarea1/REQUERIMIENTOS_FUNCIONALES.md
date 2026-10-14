# Requerimientos funcionales

## RF-01. Catálogo de culturas peruanas

| Requerimiento funcional |
|---|
| La aplicación debe mostrar la pantalla **Culturas peruanas** con una lista de las culturas **Chavín, Nazca, Moche, Chimú e Inca**. La lista debe utilizar un **UITableView** y presentar una fila por cada cultura. |

## RF-02. Información de cada cultura en la lista

| Requerimiento funcional |
|---|
| Cada fila debe mostrar el **nombre de la cultura**, su **región** y una **imagen representativa**. También debe incluir un indicador que permita reconocer que se puede acceder al detalle de la cultura. |

## RF-03. Selección de una cultura

| Requerimiento funcional |
|---|
| Al seleccionar una fila de la lista, la aplicación debe abrir una segunda pantalla con el detalle de la cultura elegida. La información debe corresponder a la fila seleccionada por el usuario. |

## RF-04. Información detallada de la cultura

| Requerimiento funcional |
|---|
| La pantalla de detalle debe mostrar el **nombre**, la **región del Perú donde se desarrolló**, una **descripción breve** y una **imagen representativa** de la cultura seleccionada. El título de la pantalla debe identificar la cultura consultada. |

## RF-05. Presentación de las imágenes

| Requerimiento funcional |
|---|
| La aplicación debe mostrar una miniatura de la imagen representativa en cada fila del catálogo y una imagen de mayor tamaño en la pantalla de detalle. En el detalle, la imagen debe conservar sus proporciones y mostrarse completa, sin deformarse. |

## RF-06. Navegación entre pantallas

| Requerimiento funcional |
|---|
| El usuario debe poder pasar de la lista al detalle al seleccionar una cultura. Desde la pantalla de detalle, el botón **Culturas** debe permitir regresar a la lista y seleccionar otra cultura sin reiniciar la aplicación. |

## RF-07. Consulta del contenido completo

| Requerimiento funcional |
|---|
| La pantalla de detalle debe permitir el desplazamiento vertical cuando la imagen, la descripción y los demás datos superen el espacio disponible. El usuario debe poder consultar todo el contenido de la cultura seleccionada. |

## RF-08. Consulta sin conexión a internet

| Requerimiento funcional |
|---|
| La aplicación debe permitir consultar la lista y el detalle de las cinco culturas sin conexión a internet. Los nombres, las regiones, las descripciones y las imágenes deben estar disponibles dentro de la aplicación. |

## RF-09. Créditos de las fotografías

| Requerimiento funcional |
|---|
| La pantalla de detalle debe mostrar el **autor**, la **licencia** y la **procedencia** de la fotografía de la cultura seleccionada. Los créditos completos de las imágenes deben estar documentados en el archivo **CREDITOS_IMAGENES.md** del proyecto. |
