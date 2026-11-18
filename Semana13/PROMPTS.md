# Registro de asistencia de IA

## Expediente individual

- **Contexto** — Trabajo individual de Ventas del Grupo A. El docente indicó usar SwiftUI y SwiftData.
- **Tarea** — Preparar el expediente en Word y ampliar los requisitos funcionales en subrequisitos numerados.
- **Restricciones** — Mantener tres páginas y limitar el alcance a la sección del trabajo de la semana.
- **Formato esperado** — Archivo Word con tablas de permisos, requisitos, reglas, pantallas y pruebas.
- **Resultado** — Se incorporaron los ocho bloques de requisitos tras la revisión del estudiante. El estudiante informó que el docente aprobó el expediente.

## Implementación de Ventas

- **Contexto** — Expediente aprobado según el estudiante y proyecto de Xcode preparado en Semana13.
- **Tarea** — Implementar la app completa de Ventas y subirla a main.
- **Restricciones** — Usar SwiftUI y SwiftData para el caso Ventas. Publicar exclusivamente en main.
- **Formato esperado** — Proyecto iOS con datos locales, pantallas por rol, registro de ventas, anulación y resumen.
- **Resultado** — La IA generó el código y el ícono. Se revisó la sintaxis Swift y se ejecutaron las comprobaciones de cálculo para las ventas VIP y Regular y los límites de categoría. La ejecución de los casos de la app y la captura del ícono en el simulador quedan pendientes para Xcode.

## Mejoras del registro de clientes y ventas

- **Contexto** — Revisión de los procesos de venta antes de la presentación académica.
- **Tarea** — Crear clientes desde la venta, evitar documentos duplicados, facilitar cantidades, identificar agotados, sumar reposiciones y consultar el desglose de una venta.
- **Restricciones** — Mantener SwiftUI y SwiftData, conservar los permisos y crear únicamente commits locales hasta el visto bueno del estudiante.
- **Formato esperado** — Cambios separados por funcionalidad con mensajes que describan su comportamiento.
- **Resultado parcial** — El formulario de cliente compara el documento sin espacios ni diferencias de mayúsculas, también con registros previos. Desde Nueva venta se puede crear un cliente o elegir el existente sin duplicarlo.

- **Resultado de las mejoras** — Nueva venta permite escribir cantidades y muestra el precio y las existencias. Los productos agotados están identificados y se bloquea la confirmación si la cantidad es inválida o supera el stock. La reposición suma unidades recibidas desde Productos y Resumen, con permiso de supervisor y control de desbordamiento. El historial abre el detalle con el precio aplicado, descuento, IGV, total y estado de la venta.
- **Verificación** — Se comprobó la sintaxis de todos los archivos Swift y se ejecutaron pruebas de cantidades válidas e inválidas, normalización de documentos y cálculos de ventas VIP, Regular y de 25 unidades. La compilación de SwiftUI y SwiftData, la persistencia y los recorridos visuales quedan pendientes de Xcode.

## Identificación de clientes y evaluación de emisión electrónica

- **Contexto** — Solicitud de identificación por documento y emisión electrónica.
- **Tarea** — Distinguir DNI, RUC, carné de extranjería y pasaporte, recuperar clientes por documento y revisar la integración con SUNAT.
- **Restricciones** — Mantener los commits locales. Conservar los registros anteriores y validar su identificación antes de nuevas ventas.
- **Formato esperado** — Selector de documento, validaciones y búsqueda desde Nueva venta.
- **Resultado** — Se añadieron los cuatro tipos, validación de formato, detección de duplicados por tipo y número, búsqueda y registro con documento precargado. Las ventas continúan vinculadas a un cliente identificado conforme al expediente. Los documentos anteriores de ocho u once dígitos se reconocen como DNI o RUC. Los demás requieren revisión del tipo antes de nuevas ventas.
- **Verificación** — Pasaron 18 comprobaciones de formatos e inferencia y la revisión de sintaxis Swift. La migración de datos y los flujos visuales deben comprobarse en Xcode. La validación local comprueba el formato, sin consultar la existencia del documento en RENIEC o SUNAT.
- **Emisión electrónica** — Pendiente de definir con el estudiante el entorno de pruebas o el emisor y servicio de producción. Se revisaron los requisitos y el servicio beta oficial. Esta actualización no incorpora emisión, firma digital ni recepción de CDR.
- **Fuentes** — https://www.sunat.gob.pe/legislacion/superin/2022/anexo-123-2022.pdf ; https://cpe.sunat.gob.pe/sites/default/files/inline-files/anexo%205%20.%20PEI-ESTRUCTURAS_3.pdf ; https://orientacion.sunat.gob.pe/12-pautas-servicio-beta

## Comprobantes para la demostración académica

- **Contexto** — El estudiante aclaró que el proyecto es una tarea académica y eligió una demostración en pruebas.
- **Tarea** — Incorporar un recorrido de preparación, revisión, generación y consulta del comprobante.
- **Restricciones** — Mantener los commits locales hasta su revisión.
- **Formato esperado** — Boleta de demostración con numeración, importes, datos del cliente y opción para compartir.
- **Decisión de implementación** — Se eligió una simulación local para presentar el recorrido sin internet. Los documentos muestran «Documento académico sin valor tributario» y la validación se identifica como local. No se integra el servicio beta de SUNAT ni se generan XML firmados o CDR.
- **Resultado** — Desde el detalle de una venta se puede revisar y confirmar el comprobante. Se asigna un número DEMO y se guarda una copia de sus datos en la venta. Consultarlo de nuevo conserva su numeración. Compartir exporta texto con la identificación académica. La anulación se refleja al consultar y compartir el documento, y bloquea generar uno nuevo.
- **Verificación** — Pasaron las comprobaciones de numeración, consistencia de importes, codificación y recuperación de datos y texto de operaciones vigentes y anuladas. Se revisó la sintaxis Swift. La compilación completa, la migración del almacén existente, la persistencia de la numeración y el menú de compartir requieren verificación en Xcode.
- **Referencia del entorno oficial** — https://orientacion.sunat.gob.pe/12-pautas-servicio-beta
