# Fuentes y parámetros

Fecha de consulta: **26 de octubre de 2026**. Las tasas se almacenan en `Parametros` y en la hoja `Parámetros`. Cambiar las tasas exige revisar ambos y regenerar el control cruzado.

| Dato | Valor usado | Fuente y alcance |
| --- | --- | --- |
| RMV | S/ 1,230.00 desde 01/10/2026 | [D.S. 015-2026-TR, artículo 1.2, El Peruano](https://busquedas.elperuano.pe/dispositivo/EX/2559163-1), coincidente con la actividad. |
| Días y horas de jornada | 30 y 8 | Convenciones de la actividad. |
| Asignación familiar | 10% de RMV | [Guía MTPE, Ley 25129](https://cdn.www.gob.pe/uploads/document/file/2899623/guia_asignacion_familiar.pdf). El ejercicio representa el requisito mediante el campo Tiene hijos. |
| ONP | 13% | [SUNAT](https://www.gob.pe/8076-declarar-y-pagar-aportes-de-trabajadores-del-hogar), D.L. 19990. |
| EsSalud | 9% | [SUNAT](https://www.gob.pe/8076-declarar-y-pagar-aportes-de-trabajadores-del-hogar), Ley 26790. Se usa sin base mínima por exigencia de la actividad. |
| Horas extras | Factores 1.25 y 1.35 | [Guía MTPE](https://cdn.www.gob.pe/uploads/document/file/7176672/6152361-como-calcular-horas-extras.pdf). Las horas se ingresan separadas. |
| AFP Ejemplo | 10% / 1.60% / 1.35% | Valores de prueba del enunciado. No corresponde a una AFP real. |
| Habitat, flujo | 10% / 1.47% / 1.37% | [SBS, devengue 2026-10](https://www.sbs.gob.pe/app/spp/empleadores/comisiones_spp/paginas/comision_prima.aspx). |
| Integra, flujo | 10% / 1.55% / 1.37% | Misma tabla SBS. |
| Prima, flujo | 10% / 1.60% / 1.37% | Misma tabla SBS. |
| Profuturo, flujo | 10% / 1.69% / 1.37% | Misma tabla SBS. |
| Oferta real | S/ 2,300 bruto | [USIL, asistente administrativo, 14/10/2026](https://portalalumni.usilcorp.com/trabajar-en-transportes-pajuelo-y-cia-s-r-l/trabajos/asistente-administrativo/967724). Salario y fecha consultados mediante el índice del buscador; acceso directo 403. |

La tabla SBS consultada informa un límite de remuneración máxima asegurable de S/ 12,732.70 para octubre de 2026. El ejercicio pide aplicar los porcentajes al total de remuneraciones; por ello no se implementa ese tope ni la comisión anual sobre saldo. El caso propio de S/ 2,300 está debajo del tope. Para comisión mixta o sobre saldo se necesita otro modelo, no usar las tasas de flujo como si fueran intercambiables.

La RMV se contrastó con el artículo 1.2 del D.S. 015-2026-TR, publicado el 28/09/2026: el primer tramo establece S/ 1,230 desde el 01/10/2026. Los resultados reproducen el parámetro indicado en clase.

No se calcula renta de quinta categoría: la sección 4 la excluye de las reglas y la sección 6 la propone como reto opcional. Se implementan los niveles 1 y 2 completos, además del encabezado ficticio y la comparación ONP/AFP del nivel 3.
