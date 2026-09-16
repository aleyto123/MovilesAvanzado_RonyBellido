# Especificación de Requerimientos - Actividad Propuesta 01

## 1. Requerimientos Funcionales

* **RF-01: Registro e Inscripción de Cursos**  
  El sistema debe registrar cursos individuales especificando nombre, precio unitario y cantidad seleccionada, permitiendo asignarlos a la lista de estudio de un alumno.

* **RF-02: Gestión de Datos del Alumno**  
  El sistema debe almacenar la información del estudiante: nombre completo, DNI y la condición booleana de si es alumno activo de Tecsup.

* **RF-03: Cálculo de Subtotal e Impuestos (IGV)**  
  El sistema debe calcular el subtotal multiplicando precio por cantidad de cada curso, aplicando posteriormente el cálculo del Impuesto General a las Ventas (IGV del 18%) sobre dicho subtotal.

* **RF-04: Descuento por Volumen de Cursos**  
  El sistema debe aplicar automáticamente un **10% de descuento** sobre el total con IGV cuando el alumno registre 3 o más cursos.

* **RF-05: Descuento Especial Tecsup**  
  El sistema debe abonar un **descuento fijo de S/ 400.00** al total acumulado, siempre y cuando el estudiante sea de Tecsup y registre 3 o más cursos.

* **RF-06: Generación e Impresión de Factura**  
  El sistema debe imprimir en consola un comprobante detallado con la información del alumno, desglose de cursos adquiridos, subtotal, IGV, descuentos aplicados y el total final formatted a 2 decimales en soles (`S/`).

---

## 2. Modelo de Datos

| Entidad | Campo | Tipo de Dato | Requerido | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| **Curso** *(Struct)* | `nombre` | `String` | Sí | Nombre de la asignatura |
| | `precio` | `Double` | Sí | Precio unitario del curso |
| | `cantidad` | `Int` | Sí | Unidades/Cupos a comprar |
| **Alumno** *(Class)* | `nombre` | `String` | Sí | Nombres y apellidos del alumno |
| | `dni` | `String` | Sí | Documento Nacional de Identidad |
| | `esAlumnoTecsup` | `Bool` | Sí | `true` si pertenece a Tecsup |
| | `cursos` | `[Curso]` | Sí | Lista de cursos matriculados |

---

## 3. Requerimientos No Funcionales

* **RNF-01: Arquitectura de Software**  
  Uso combinado de estructuras (`struct`) para modelos de valor livianos (`Curso`) y clases (`class`) para la gestión de lógica de negocio del cliente (`Alumno`).

* **RNF-02: Precisión en Cálculos Financieros**  
  Todas las operaciones de subtotal, IGV, descuentos y totales deben gestionarse mediante tipos de datos decimales (`Double`) y con salida visual redondeada a 2 decimales (`%.2f`).

* **RNF-03: Lenguaje y Entorno**  
  Desarrollado en **Swift** utilizando el framework estándar **Foundation**.