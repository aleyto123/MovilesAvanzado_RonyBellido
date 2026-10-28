# CTS

Sección A · CTS, gratificaciones y vacaciones del régimen general de la actividad privada.

## 📋 Requerimientos Funcionales

### RF-01: Registro de Datos del Trabajador y del Período

* **RF-01.1 Selección del Beneficio:** La aplicación debe permitir elegir entre los apartados CTS, Gratificación y Vacaciones mediante pestañas. Cada apartado debe presentar su formulario y sus resultados en la misma pantalla.
* **RF-01.2 Captura de Remuneración:** El usuario podrá registrar el sueldo básico, la asignación familiar acreditada, otros conceptos fijos computables y la jornada diaria. El cálculo debe identificar el régimen general privado, el año 2026 y su alcance de remuneración principal fija con jornadas de 4 a 8 horas y semana habitual de 5 o 6 días.
* **RF-01.3 Registro de Complementos Variables:** Para CTS y gratificaciones, la aplicación debe permitir ingresar por separado los importes mensuales de horas extras y comisiones complementarias de los seis meses del semestre. Cada concepto se incorporará como promedio si tuvo percepción en al menos tres meses, dividiendo su suma entre seis.
* **RF-01.4 Datos Según el Beneficio:** El formulario debe solicitar las fechas, meses, días, faltas y condiciones que correspondan al beneficio seleccionado. En vacaciones debe distinguir el goce del descanso y el cálculo al cese.

### RF-02: Cálculo de CTS

* **RF-02.1 Remuneración Computable:** La aplicación debe sumar el sueldo básico, los otros fijos computables, la asignación familiar, los promedios variables regulares y un sexto de la gratificación legal anterior efectivamente percibida. La bonificación extraordinaria de esa gratificación no debe integrar el sexto.
* **RF-02.2 Cálculo Proporcional:** El sistema debe calcular la CTS mediante `base computable × días computables / 360`, equivalente a sumar dozavos por meses y treintavos de dozavo por días. Debe descontar los días no computables y admitir una fracción acreditada de hasta 29 días aplazada del semestre anterior.
* **RF-02.3 CTS Semestral y Trunca:** El usuario podrá elegir CTS semestral, con corte al 30 de abril o 31 de octubre, o CTS trunca al cese. Si no completó el primer mes de vínculo, el sistema debe identificar el aplazamiento de la fracción semestral o la ausencia de pago al cesar.
* **RF-02.4 Desglose y Fecha Referencial:** El resultado debe mostrar la base, sus componentes, los días computables, el importe y una fecha referencial de pago. Para el depósito semestral debe ajustar sábados y domingos y señalar que corresponde revisar feriados; para el cese debe identificar el plazo de 48 horas.

### RF-03: Cálculo de Gratificaciones

* **RF-03.1 Período y Meses Completos:** La aplicación debe calcular gratificación de julio, Navidad o trunca. Debe contar únicamente meses calendario completos del semestre comprendidos en el vínculo laboral. La fecha base del sueldo será el 30 de junio, el 30 de noviembre o el último día del mes inmediato anterior al cese, respectivamente.
* **RF-03.2 Base de Gratificación:** El sistema debe sumar sueldo básico, asignación familiar, otros fijos computables y promedios complementarios regulares, sin añadir un sexto de gratificación anterior. La asignación familiar de todos los beneficios debe utilizar el 10% de la RMV vigente en su fecha base.
* **RF-03.3 Proporción y Días No Computables:** El importe debe calcularse mediante `base × meses completos / 6`, restando `base × días no computables / 180`. Los días descontados deben pertenecer a los meses completos incluidos; si no existe un mes calendario completo, el resultado proporcional debe ser cero.
* **RF-03.4 Bonificación Extraordinaria:** El usuario podrá seleccionar EsSalud o EPS. El sistema debe sumar a la gratificación bruta una bonificación del 9% o 6.75%, respectivamente, redondeando cada pago antes de sumarlo. No debe descontar aportes ONP o AFP de la gratificación legal.

### RF-04: Cálculo de Vacaciones

* **RF-04.1 Derecho Adquirido y Récord:** La aplicación debe permitir registrar un período anual de hasta 30 días calendario, los días ya gozados y la acreditación del año y récord vacacional. Debe comprobar un mínimo de 260 días computables para semana de seis días o 210 para semana de cinco días.
* **RF-04.2 Pago al Salir de Vacaciones:** En la opción Goce, debe calcular `remuneración vacacional / 30 × días solicitados`, comprobar el saldo y el acuerdo legal de fraccionamiento cuando corresponda, y mostrar el saldo posterior y el último día del descanso. Debe identificar el pago previo al descanso y explicar que forma parte de la remuneración mensual.
* **RF-04.3 Vacaciones Truncas y Adelantos:** Al cese, debe calcular las vacaciones truncas por meses y días mediante dozavos y fracciones de 1/360, comprobando el primer mes de vínculo. Los días adelantados deben compensarse hasta el importe trunco generado; su exceso no debe producir deuda del trabajador.
* **RF-04.4 Ganadas e Indemnización:** El sistema debe distinguir vacaciones ganadas pendientes, truncas e indemnización procedente, utilizando períodos distintos para evitar duplicidades. Los días indemnizables deben ser acreditados por el usuario y debe aplicarse la excepción del gerente o representante que decidió no descansar. El total no debe volver a sumar el sueldo del período trabajado.

### RF-05: Validación de Entradas y Actualización

* **RF-05.1 Validación Numérica:** Los importes deben admitir punto o coma decimal, hasta dos decimales y ningún separador de miles. El sistema debe rechazar campos activos vacíos, texto, valores negativos e importes superiores a S/ 1,000,000,000. Los meses, días y récord deben ser enteros.
* **RF-05.2 Coherencia del Período:** La aplicación debe comprobar los límites de meses y días, las fechas válidas, el orden de ingreso y cese, la jornada, el saldo vacacional y los requisitos aplicables. La CTS trunca no debe incluir tiempo posterior al cese ni variables de meses posteriores al corte.
* **RF-05.3 Campos Condicionales:** Los datos exclusivos de cese deben mostrarse y procesarse únicamente cuando correspondan. Al cambiar de semestre, los complementos variables deben restablecerse para evitar trasladar importes de otros meses.
* **RF-05.4 Mensajes y Resultados Anteriores:** Si existe un error, la aplicación debe indicar qué dato corregir y evitar mostrar un resultado incompleto. Al modificar cualquier entrada debe retirar el resultado anterior hasta que el usuario vuelva a presionar Calcular.

### RF-06: Presentación de Resultados y Base Legal

* **RF-06.1 Formato de Importes:** Los resultados deben mostrarse en soles y con dos decimales, resaltando el total del beneficio. Los cálculos monetarios deben conservar la precisión intermedia y redondear los pagos finales.
* **RF-06.2 Consulta del Desglose:** El usuario podrá desplazarse por el formulario y consultar los componentes de la base computable, el tiempo considerado y los pagos correspondientes. Cada beneficio debe permitir consultar cómo se obtuvo su resultado.
* **RF-06.3 Consulta de Normas:** Cada apartado debe incluir enlaces a las fuentes oficiales de sus reglas, entre ellas las normas de CTS, gratificaciones, bonificación extraordinaria, vacaciones, fraccionamiento, asignación familiar y vigencia de la RMV.
* **RF-06.4 Identificación del Alcance:** La aplicación debe identificar los resultados como importes brutos del beneficio. Debe indicar que no liquida el impuesto a la renta de quinta categoría, retenciones ni el neto final de planilla y que otros regímenes laborales requieren reglas propias.
