# Especificación de Requerimientos - Actividad Propuesta 02

## 1. Requerimientos Funcionales

* **RF-01: Registro de Información Base del Cliente**  
  El sistema debe registrar y almacenar los atributos fundamentales de todo cliente: código identificador, dirección, fecha de registro, número de cuenta asignado y monto mínimo de apertura.

* **RF-02: Especialización de Cliente Natural**  
  El sistema debe permitir el registro de personas naturales agregando sus datos específicos: nombre completo y número de DNI.

* **RF-03: Especialización de Cliente Jurídico**  
  El sistema debe permitir el registro de organizaciones o empresas capturando sus datos específicos: razón social, RUC y representante legal.

* **RF-04: Impresión y Reporte de Datos**  
  El sistema debe proveer una función para imprimir en consola el detalle completo del cliente, adaptando los encabezados e íconos identificadores según corresponda (👤 *Cliente Natural* o 🏢 *Cliente Jurídico*).

* **RF-05: Formato Monetario**  
  El sistema debe dar formato al valor numérico del monto mínimo de apertura expresándolo en soles (`S/`) y configurado a 2 decimales.

* **RF-06: Procesamiento Polimórfico en Colecciones**  
  El sistema debe permitir agrupar instancias de distintas clases derivadas dentro de un mismo arreglo o lista base, ejecutando de forma secuencial el reporte de datos de cada cliente con separadores en consola.

---

## 2. Modelo de Datos

| Entidad | Campo | Tipo de Dato | Requerido | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| **Cliente** *(Base)* | `codigo` | `String` | Sí | Identificador único del cliente |
| | `direccion` | `String` | Sí | Dirección domiciliaria o fiscal |
| | `fechaRegistro` | `String` | Sí | Fecha de registro en el sistema |
| | `numeroCuenta` | `String` | Sí | Identificador de la cuenta bancaria |
| | `montoMinimoApertura` | `Double` | Sí | Monto mínimo de apertura exigido |
| **ClienteNatural** | `nombreCompleto` | `String` | Sí | Nombres y apellidos del cliente |
| | `dni` | `String` | Sí | Documento Nacional de Identidad |
| **ClienteJuridico** | `razonSocial` | `String` | Sí | Denominación o razón social |
| | `ruc` | `String` | Sí | Registro Único de Contribuyentes |
| | `representanteLegal` | `String` | Sí | Nombre del apoderado legal |

---

## 3. Requerimientos No Funcionales

* **RNF-01: Orientación a Objetos (Herencia)**  
  La arquitectura del módulo debe basarse en clases, declarando `Cliente` como clase superpadre de la cual extienden `ClienteNatural` y `ClienteJuridico`.

* **RNF-02: Aplicación de Polimorfismo**  
  Las clases hijas deben sobrescribir (`override`) el método de presentación de datos `mostrarDatos()` sin modificar la firma original de la clase base.

* **RNF-03: Plataforma y Tecnologías**  
  El desarrollo debe estar implementado en el lenguaje **Swift** haciendo uso del framework **Foundation**.