## 📋 Requerimientos Funcionales

### RF-01: Registro de Datos del Mes

* **RF-01.1 Captura de Información:** La aplicación debe permitir ingresar el sueldo básico, los días laborados, si el trabajador tiene hijos, las horas extras al 25%, las horas extras al 35% y los adelantos.
* **RF-01.2 Selección del Sistema de Pensiones:** El usuario podrá elegir ONP o AFP. Al seleccionar AFP, debe aparecer un selector con AFP Ejemplo, Habitat, Integra, Prima y Profuturo. Las AFP reales deben identificarse como comisión sobre flujo.
* **RF-01.3 Procesamiento de Datos:** El formulario debe incluir el botón **Calcular boleta**, que valide los datos ingresados y genere los resultados en la misma pantalla.

### RF-02: Cálculo de Remuneraciones

* **RF-02.1 Sueldo Computable:** La aplicación debe calcular el sueldo correspondiente a los días trabajados: `sueldoBásico / 30 × díasLaborados`.
* **RF-02.2 Asignación Familiar:** Si el trabajador tiene hijos, se debe agregar el 10% de la RMV. Con la RMV de S/ 1,230.00 utilizada en la actividad, corresponde S/ 123.00, sin prorratear por días. Si no tiene hijos, se debe mostrar 0.00.
* **RF-02.3 Valor Hora:** El sistema debe obtener el valor de la hora ordinaria mediante `sueldoBásico / 30 / 8`, conservando los decimales intermedios.
* **RF-02.4 Horas Extras:** Se deben calcular por separado los pagos al 25% y al 35%, multiplicando el valor hora por 1.25 o 1.35 y por la cantidad de horas correspondiente.
* **RF-02.5 Total de Remuneraciones:** Suma del sueldo computable, la asignación familiar y los dos pagos por horas extras.

### RF-03: Retenciones, Adelantos y Neto a Pagar

* **RF-03.1 Retención ONP:** Si se elige ONP, la aplicación debe calcular el 13% del total de remuneraciones y mostrar los conceptos AFP en cero.
* **RF-03.2 Retenciones AFP:** Si se elige AFP, se deben calcular por separado el fondo, la comisión y el seguro con las tasas de la AFP seleccionada. AFP Ejemplo debe utilizar 10.00%, 1.60% y 1.35%, respectivamente. ONP debe mostrarse en cero.
* **RF-03.3 Aplicación del Adelanto:** El monto ingresado como adelanto debe añadirse a los descuentos, sin reducir la base de cálculo de la pensión.
* **RF-03.4 Total de Descuentos:** Suma de la retención ONP o de los tres conceptos AFP, más el adelanto. No se deben descontar ambos sistemas al mismo tiempo.
* **RF-03.5 Neto a Pagar:** Cálculo final mediante `totalRemuneraciones - totalDescuentos`. Si el resultado es negativo, se debe mostrar un mensaje que lo identifique como saldo pendiente.

### RF-04: Validación de Datos

* **RF-04.1 Validación de Campos:** La aplicación no debe calcular si un campo numérico está vacío o contiene texto. Los importes y las horas deben admitir punto o coma decimal, sin separadores de miles y con un máximo de dos decimales.
* **RF-04.2 Validación del Sueldo y Días:** El sueldo debe ser mayor que cero. Los días laborados deben ser un número entero entre 1 y 30.
* **RF-04.3 Validación de Horas y Adelantos:** Las horas extras de ambos tipos y el adelanto deben ser números mayores o iguales a cero.
* **RF-04.4 Mensajes de Error:** Si se encuentra un dato incorrecto, se debe mostrar un mensaje claro que indique qué corregir y evitar la presentación de una boleta incompleta.

### RF-05: Presentación de la Boleta y Aportaciones del Empleador

* **RF-05.1 Identificación de Ejemplo:** La pantalla debe mostrar el título **Boleta de ejemplo**, el nombre de un trabajador y una empresa ficticios, sin utilizar DNI ni RUC reales.
* **RF-05.2 Desglose de Conceptos:** La boleta debe aparecer debajo del formulario y mostrar los bloques **Remuneraciones**, **Retenciones / Descuentos** y **Aportaciones del empleador**, con sus conceptos e importes.
* **RF-05.3 Cálculo de EsSalud:** Se debe calcular el 9% del total de remuneraciones como aporte del empleador. Este importe no debe descontarse al trabajador. El costo para la empresa debe ser la suma de las remuneraciones y EsSalud.
* **RF-05.4 Formato de Importes:** Los montos deben mostrarse en soles y con dos decimales. Cada concepto monetario debe redondearse antes de sumar. Los conceptos que no apliquen deben aparecer con 0.00 y el **Neto a pagar** debe resaltarse.
* **RF-05.5 Consulta del Contenido:** La pantalla debe utilizar un **ScrollView** que permita consultar el formulario y todos los bloques de la boleta mediante desplazamiento vertical.

### RF-06: Comparación de Pensiones y Nueva Consulta

* **RF-06.1 Comparación ONP y AFP:** La aplicación debe mostrar, uno al lado del otro, el neto con ONP y el neto con la AFP seleccionada, utilizando los mismos datos del trabajador.
* **RF-06.2 Actualización del Cálculo:** Al modificar cualquier entrada, se deben retirar los resultados anteriores. El usuario podrá presionar nuevamente **Calcular boleta** para realizar otra consulta sin reiniciar la aplicación.

## Ejecución

Abrir `BoletaPago.xcodeproj` en Xcode 16 o posterior, seleccionar el esquema **BoletaPago** y ejecutar en un simulador de iPhone con iOS 16 o posterior. El paquete local `BoletaCore` está incluido en esta carpeta.

También se puede ejecutar y comprobar la app en un simulador de iPhone mediante **GitHub Actions**. El workflow **Semana09 - Simulador iPhone** compila la app, prueba los cuatro casos y publica capturas y una grabación. Ver [cómo ejecutar y consultar los resultados](docs/GITHUB_ACTIONS.md).

## Evidencia de Ejecución

[Ejecución verificada en GitHub Actions](https://github.com/aleyto123/MovilesAvanzado_RonyBellido/actions/runs/40594621152): compilación en Xcode 16.4, cinco pruebas del motor y cinco pruebas de interfaz aprobadas, sin fallos. Simulador de iPhone 16 Pro con iOS 18.6, 27/10/2026.

Capturas reales del simulador: [formulario](docs/capturas/app-formulario.png), [caso 1](docs/capturas/app-caso1.png), [caso 2](docs/capturas/app-caso2.png), [caso 3](docs/capturas/app-caso3.png), [caso 4](docs/capturas/app-caso4.png) y [validación de días](docs/capturas/app-validacion.png).

## Archivos de la Actividad

* [Excel con los cuatro casos y sus fórmulas](outputs/semana09/Boleta_Grupo_B.xlsx).
* [Respuestas de análisis y caso 4 resuelto](docs/ANALISIS.md).
* [Tabla de fuentes y parámetros](docs/FUENTES.md).
