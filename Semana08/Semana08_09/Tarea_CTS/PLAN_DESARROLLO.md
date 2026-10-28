# Plan de desarrollo individual

Actualizado el 21 de octubre de 2026 a partir de la aclaración del profesor transmitida por el estudiante. Se mantienen seis commits en total. Solo el primero está realizado; los demás describen trabajo pendiente.

## Resultado esperado

La aplicación y el Excel deben resolver los mismos casos y permitir explicar de dónde sale cada importe. La cadena de explicación será: dato de entrada, regla legal, fórmula, operación y resultado.

Los entregables previstos son:

- El proyecto SwiftUI `Tarea_CTS.xcodeproj`.
- El libro `Excel/CTS_Peru.xlsx`, con fórmulas editables, ejemplos y fuentes. Todavía no existe.
- Una guía breve de sustentación con un ejemplo normal y otros con vacaciones y ausencias.

El desarrollo es individual. Cada avance se cierra cuando su contenido se pueda ejecutar y explicar. La evaluación de ambos productos se ha mencionado en clase, pero no se presuponen porcentajes ni una rúbrica exacta.

## Alcance que guiará la implementación

Se toma como caso de referencia el régimen laboral general privado, con remuneración mensual fija y verificación de la jornada exigida para CTS. Se registrarán sueldo, conceptos regulares aplicables, fechas de ingreso y cálculo, historial de gratificaciones y eventos del periodo.

La app determinará el semestre y el tiempo computable a partir de las fechas y eventos. El usuario proporcionará datos laborales reales; los resultados intermedios se calcularán automáticamente. Cuando falte el historial necesario para reconstruir una gratificación, se solicitará el importe realmente percibido y su fecha en lugar de suponer que equivale al sueldo.

Se cubrirán las vacaciones efectivamente gozadas y remuneradas, su importe proporcional al descanso y su efecto en CTS y gratificación. Las faltas injustificadas y licencias sin goce se registrarán como eventos distintos. No se confundirá el descanso vacacional con una ausencia no computable.

El plan no convierte el proyecto en una planilla universal: MYPE, CAS, otros regímenes especiales, remuneración principal por comisiones, indemnizaciones, venta de vacaciones y liquidación integral de cese requieren reglas adicionales. Ante datos de esos supuestos, se explicará el límite del cálculo, sin devolver un importe del régimen general como si fuera aplicable.

## Los seis commits

### Commit 1 Formulario y alcance inicial

Mensaje: `feat(cts): iniciar formulario y plan de app y Excel`

Estado: realizado.

Contiene el proyecto de Xcode, los tres campos básicos y este plan. Permite estudiar `@State` y `TextField` antes de conectar operaciones. La actualización del plan no significa que ya existan el motor ni el Excel.

### Commit 2 Base legal y Excel de referencia

Mensaje: `feat(excel): fundamentar y calcular CTS y gratificacion`

Preparar primero las reglas y el libro. Completar la matriz norma-artículo-regla-fórmula, comprobar las modificaciones aplicables y documentar requisitos y exclusiones. Implementar los casos básicos de CTS y gratificación con celdas enlazadas, explicación paso a paso y la regla de vacaciones remuneradas.

El libro tendrá un caso resuelto manualmente que sirva como referencia independiente. Debe distinguir la gratificación legal, su bonificación extraordinaria y el sexto que corresponde incorporar a la CTS. También debe identificar el periodo de origen de cada importe.

Se cierra cuando cambiar un dato actualice las fórmulas, los ejemplos básicos coincidan con la referencia manual y cada regla tenga una fuente oficial y un artículo identificado.

### Commit 3 Motor y pruebas en Swift

Mensaje: `feat(cts): implementar calculos y periodos con pruebas`

Crear funciones pequeñas, separadas de las vistas, para remuneración computable, CTS por meses y días, gratificación y bonificación. Incorporar los requisitos de derecho al beneficio y las fechas de los periodos. Utilizar `Decimal` para los importes.

Comprobar entradas inválidas, periodos incompletos, límites de fechas y meses de 28, 29, 30 y 31 días. La convención laboral de cómputo debe estar documentada; no se sustituirá por una división indiscriminada de días naturales entre 360.

Se cierra cuando las funciones pasan pruebas con resultados esperados derivados de los ejemplos manuales y del Excel. Dos implementaciones que repiten un error no cuentan como validación.

### Commit 4 Aplicación conectada y explicable

Mensaje: `feat(app): conectar formularios y explicar resultados`

Ampliar el formulario por secciones: datos laborales, periodo, remuneraciones y resultados. Conectar Calcular y Limpiar al motor; mostrar errores junto a los datos que requieren corrección.

Mostrar el semestre elegido, el origen de la gratificación utilizada, sus componentes, el tiempo computable y la sustitución numérica de la fórmula. Cada explicación tendrá acceso a su referencia legal. El resultado monetario se presentará en soles.

Se cierra cuando un usuario puede ingresar un caso desde cero, calcularlo y explicar cada cantidad que aparece en pantalla. El código seguirá usando vistas y funciones pequeñas que se puedan estudiar individualmente.

### Commit 5 Vacaciones y eventos del periodo

Mensaje: `feat(beneficios): cubrir vacaciones y ausencias en app y Excel`

Registrar rangos de vacaciones remuneradas y eventos no computables. Validar solapamientos, eventos fuera del vínculo laboral y cruces de semestre. Calcular el importe del descanso para el caso admitido y explicar su tratamiento sin duplicar la remuneración mensual.

Completar en ambos productos los casos de ingreso durante el semestre, días residuales, vacaciones y ausencias. Incorporar conceptos complementarios variables únicamente después de validar su regla de regularidad y promedio para el periodo correspondiente.

Se cierra cuando el caso base conserva el resultado al añadir vacaciones remuneradas con las mismas remuneraciones y tiempo elegible; y cuando una ausencia no computable cambia el importe conforme a la regla documentada. Los escenarios con reglas adicionales sin implementar deben quedar identificados.

### Commit 6 Verificación y sustentación

Mensaje: `test(cts): contrastar app y Excel y documentar sustentacion`

Comparar caso por caso el cálculo manual, las fórmulas recalculadas del Excel y los resultados de la app. Revisar importes a dos decimales, entradas vacías, fechas incompatibles, periodos sin derecho al depósito actual y ausencia de datos históricos.

Preparar la guía para exponer qué es la CTS, por qué se usa un sexto de gratificación, cómo cambia el tiempo computable y qué ocurre durante vacaciones. Incluir las fuentes y la fecha de revisión en el Excel final.

Se cierra cuando la app compila, las pruebas pasan, no hay errores de fórmula en Excel y todos los casos admitidos tienen resultados conciliados al céntimo con el mismo criterio de redondeo.

## Diseño previsto del Excel

| Hoja | Contenido que se debe poder explicar |
| --- | --- |
| Guía | Objetivo, régimen admitido, instrucciones y significado de los colores |
| Base legal | Norma, artículo, regla resumida, enlace oficial y fecha de consulta |
| Datos | Entradas del trabajador, remuneraciones, fechas e historial necesario |
| Periodos | Semestres, meses y días computables, eventos y motivos de exclusión |
| Gratificación | Base, meses calendario, ajustes, gratificación legal y bonificación separada |
| CTS | Componentes de remuneración computable, sexto correcto, meses, días y depósito |
| Vacaciones | Descanso remunerado, importe y efecto sobre los demás beneficios |
| Casos y control | Datos de prueba, resultado manual, resultado Excel, resultado app y diferencia |

Las celdas de entrada se distinguirán de las fórmulas y los resultados. Las constantes legales tendrán una celda de origen y referencia. Se evitarán resultados escritos a mano en lugar de fórmulas, vínculos externos rotos, macros innecesarias y fórmulas que conviertan errores o datos faltantes en cero silenciosamente. El libro debe poder recalcularse sin ejecutar la app.

## Casos mínimos de comprobación

| Caso | Comprobación requerida |
| --- | --- |
| Semestre completo | Sueldo S/ 3,000, gratificación legal pertinente S/ 3,000, sin otros conceptos: RC S/ 3,500 y CTS S/ 1,750 |
| Vacaciones pagadas | Con iguales datos y tiempo elegible, 30 días de descanso remunerado no reducen la CTS del caso anterior |
| Tiempo proporcional | RC S/ 3,500 y tiempo ya validado de 3 meses y 15 días: CTS S/ 1,020.83 |
| Ausencia no computable | RC S/ 3,500 y 5 días no computables dentro del semestre completo: CTS S/ 1,701.39 |
| Gratificación completa | Base S/ 3,000 y seis meses elegibles: gratificación S/ 3,000; bonificación EsSalud S/ 270, separada |
| Afiliación EPS | Mismo caso de gratificación: bonificación S/ 202.50; no alterar el importe legal usado para el sexto de CTS |
| Fecha de ingreso | Diferenciar meses calendario completos de gratificación del cómputo de meses y días de CTS |
| Límites de fechas | Fin de febrero, año bisiesto, fin de mes y cruces de semestre |
| Historial insuficiente | Pedir la gratificación realmente percibida; no deducirla automáticamente del sueldo actual |
| Requisitos incompletos | Explicar por qué no corresponde depósito actual o por qué falta información, según la norma |
| Datos inválidos | Rechazar negativos, fechas invertidas y eventos superpuestos |

Los importes de los primeros casos son referencias aritméticas bajo las condiciones descritas. Las fechas y los requisitos de cada expediente de prueba se completarán en el commit 2 antes de usarlos como prueba jurídica del caso.

## Orden para estudiar y exponer

Primero explicar un caso del Excel sin usar la app. Después mostrar que las funciones Swift realizan las mismas operaciones. Finalmente, modificar un dato y justificar el cambio con la regla correspondiente. El ejemplo con vacaciones deberá compararse con uno de licencia sin goce para demostrar que son situaciones distintas.
