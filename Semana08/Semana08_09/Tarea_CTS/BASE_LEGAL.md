# Base legal inicial del proyecto

Consulta inicial: 21 de octubre de 2026. Este archivo fija las distinciones para el plan. La matriz completa de artículos, vigencia aplicable y casos del Excel se elaborará en el commit 2 antes de implementar las reglas.

## CTS

El [TUO de la Ley de CTS aprobado por D.S. 001-97-TR](https://trabajoarequipa.gob.pe/uploads/documentos/3/5d5ff5a188bd5.pdf), publicado por la autoridad regional de trabajo, permite ubicar estas reglas:

| Artículos | Regla a implementar |
| --- | --- |
| 2 y 4 | Requisitos de tiempo de servicios y jornada para el beneficio |
| 8 | Identificar tiempo computable y excepciones; la suspensión con remuneración no se trata como falta injustificada |
| 9, 10, 19 y 20 | Construir la base con conceptos computables y excluir los que no lo son |
| 16 y 17 | Distinguir complementos variables de remuneración principal imprecisa; no aplicar un único promedio a ambos |
| 18 | Incorporar un sexto de la gratificación semestral pertinente |
| 21 y 22 | Calcular meses y fracciones, depósito semestral y oportunidad de pago |

Para el alcance mensual fijo, una vez validada la remuneración computable y el tiempo:

`CTS = RC × meses / 12 + RC × días / 360`

El [MTPE recuerda los periodos de depósito](https://www.gob.pe/institucion/mtpe/noticias/1383535-mtpe-trabajadores-del-regimen-privado-que-laboren-4-horas-diarias-en-promedio-tienen-derecho-a-cts): noviembre-abril para mayo y mayo-octubre para noviembre. El historial debe conservar qué gratificación se percibió en el semestre correspondiente.

## Gratificación

La [Ley 27735](https://www2.congreso.gob.pe/sicr/cendocbib/con4_uibd.nsf/94A2515BEBFE3D7905257DFE00575204/%24FILE/ley_27735_de_gratificaciones.pdf) regula el beneficio. El [D.S. 005-2002-TR](https://www.trabajoarequipa.gob.pe/uploads/documentos/3/5d5ff900bcdae.pdf), artículos 2 y 3, trata vacaciones, base remunerativa y tiempo de servicios. Su numeral 3.4 fue modificado por el D.S. 017-2002-TR, modificación también recogida en el [resumen legal de SUNAT](https://www.sunat.gob.pe/legislacion/resumen/2002/diciembre/dic05.htm).

La gratificación usa meses calendario completos y ajustes por días no considerados laborados. Su periodo y su tratamiento del tiempo no se copiarán del cálculo de CTS. Las vacaciones remuneradas son un supuesto reconocido para gratificación; no corresponde restarlas automáticamente.

La [Ley 30334, artículo 3](https://www2.congreso.gob.pe/sicr/cendocbib/con4_uibd.nsf/655742D28BB4292C05257EF400058AC6/%24FILE/30334.pdf) define la bonificación extraordinaria como no remunerativa ni pensionable. La [orientación de Sunafil](https://www.gob.pe/institucion/sunafil/noticias/878960-sunafil-mas-de-98-mil-trabajadores-usaron-la-calculadora-laboral-para-conocer-la-gratificacion-que-les-corresponde) explica el 9 % para EsSalud y 6.75 % para EPS.

Se mostrarán por separado la gratificación legal y esa bonificación. El sexto de CTS no se obtendrá sumando ambas ni sumando indiscriminadamente las dos gratificaciones del año.

## Vacaciones remuneradas

Se revisarán el D. Leg. 713 y sus modificaciones junto con su [reglamento D.S. 012-92-TR](https://www.trabajoarequipa.gob.pe/uploads/documentos/3/5d5ffb2557d30.pdf). Los artículos 11 y 16 a 19 del reglamento permiten distinguir requisitos, remuneración habitual y pago del descanso.

Para el caso admitido, la remuneración vacacional se explicará con su propia base. No se reutilizará sin revisión la RC de CTS, porque el artículo 16 del reglamento excluye remuneraciones periódicas de esa base vacacional.

La conclusión para el diseño, al relacionar esas reglas con el artículo 8 del TUO de CTS y el artículo 2 del reglamento de gratificaciones, es registrar las vacaciones gozadas con remuneración como evento computable. Tampoco se añadirá otro sueldo mensual al calcular CTS por el solo hecho de tomar vacaciones.

## Comprobación antes de programar

En el commit 2 cada regla debe tener su artículo, supuesto de aplicación y ejemplo. Las normas publicadas en repositorios históricos se contrastarán con sus modificaciones aplicables al periodo. Los supuestos no cubiertos se identificarán expresamente en Excel y en la aplicación.
