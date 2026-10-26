import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Workbook, SpreadsheetFile } from '@oai/artifact-tool';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const swiftResults = JSON.parse(await fs.readFile(path.join(root,'tools','verification.json'),'utf8'));
const out = path.join(root, 'outputs', 'semana09');
await fs.mkdir(out, { recursive: true });
const wb = Workbook.create();
const [p,b,c,e] = ['Parámetros','Boleta','Casos','Explicación'].map(n=>wb.worksheets.add(n));
const value = (s,cell,v)=>s.getRange(cell).values=[[v]];
const formula = (s,cell,v)=>s.getRange(cell).formulas=[[v]];
const row = (s,r,values)=>s.getRangeByIndexes(r-1,0,1,values.length).values=[values];
const header = (s,r,text,last='D')=>{
  s.getRange(`A${r}:${last}${r}`).merge(); value(s,`A${r}`,text);
  s.getRange(`A${r}:${last}${r}`).format={fill:'#12344B',font:{bold:true,color:'#FFFFFF'},rowHeight:30};
};
for(const s of [p,b,c,e]) {
 s.showGridLines=false;
 s.getRange('A1:H70').format.font={name:'Calibri',size:11,color:'#172F40'};
 s.getRange('A1:A70').format.columnWidth=34;
 s.getRange('B1:H70').format.columnWidth=20;
 s.getRange('A1:H70').format.rowHeight=24;
 s.freezePanes.freezeRows(4);
}
header(p,1,'Parámetros y fuentes de la boleta','E');
row(p,3,['Parámetro','Valor','Fuente o ámbito','Consulta','Enlace']);
const sourceSBS='https://www.sbs.gob.pe/app/spp/empleadores/comisiones_spp/paginas/comision_prima.aspx';
const sources=[
 ['RMV',1230,'Actividad Grupo B; supuesto académico','26/10/2026','Actividad_Grupo_B.docx, sección 4'],
 ['Asignación familiar',0.1,'Ley 25129; guía MTPE','26/10/2026','https://cdn.www.gob.pe/uploads/document/file/2899623/guia_asignacion_familiar.pdf'],
 ['ONP',0.13,'D.L. 19990; SUNAT','26/10/2026','https://www.gob.pe/8076-declarar-y-pagar-aportes-de-trabajadores-del-hogar'],
 ['EsSalud',0.09,'Ley 26790; SUNAT','26/10/2026','https://www.gob.pe/8076-declarar-y-pagar-aportes-de-trabajadores-del-hogar'],
 ['Días del mes',30,'Convención de la actividad','26/10/2026','Actividad_Grupo_B.docx, sección 4'],
 ['Horas de jornada',8,'Convención de la actividad','26/10/2026','Actividad_Grupo_B.docx, sección 4'],
 ['Factor HE 25%',1.25,'Actividad; guía MTPE','26/10/2026','https://cdn.www.gob.pe/uploads/document/file/7176672/6152361-como-calcular-horas-extras.pdf'],
 ['Factor HE 35%',1.35,'Actividad; guía MTPE','26/10/2026','https://cdn.www.gob.pe/uploads/document/file/7176672/6152361-como-calcular-horas-extras.pdf']
];
sources.forEach((x,i)=>row(p,i+4,x));
p.getRange('B5:B7').setNumberFormat('0.00%');
header(p,14,'AFP · comisión sobre flujo · devengue octubre 2026','E');
row(p,15,['AFP','Fondo','Comisión','Seguro','Fuente']);
const rates=[['AFP Ejemplo',.1,.016,.0135,'Actividad: tasas de prueba'],['Habitat (flujo)',.1,.0147,.0137,sourceSBS],['Integra (flujo)',.1,.0155,.0137,sourceSBS],['Prima (flujo)',.1,.016,.0137,sourceSBS],['Profuturo (flujo)',.1,.0169,.0137,sourceSBS]];
rates.forEach((x,i)=>row(p,i+16,x)); p.getRange('B16:D20').setNumberFormat('0.00%');
row(p,23,['Nota','Las AFP reales usan comisión sobre flujo. Se mantienen las bases simplificadas de la actividad.']);
p.getRange('B23:E24').merge(); p.getRange('B23:E24').format.wrapText=true;
row(p,26,['Oferta real',2300,'Asistente administrativo; publicada 14/10/2026','26/10/2026','https://portalalumni.usilcorp.com/trabajar-en-transportes-pajuelo-y-cia-s-r-l/trabajos/asistente-administrativo/967724']);
row(p,28,['RMV oficial','Por verificar','No se afirma vigencia legal a partir del enunciado.','26/10/2026','https://www.gob.pe/mtpe']);
p.getRange('C1:C28').format.columnWidth=48;p.getRange('D1:D28').format.columnWidth=18;p.getRange('E1:E28').format.columnWidth=65;
p.getRange('C4:E28').format.wrapText=true; p.getRange('A26:E28').format.rowHeight=64;
p.getRange('A17:E20').format.rowHeight=44;

header(c,1,'Casos y control cruzado al centavo','H');
row(c,3,['Concepto','Caso 1','Caso 2','Caso 3','Caso 4','Oferta real','Compañero 1','Compañero 2']);
const labels={4:'Sueldo básico',5:'Días laborados',6:'Hijos (1 sí / 0 no)',7:'Sistema',8:'AFP',9:'Horas al 25%',10:'Horas al 35%',11:'Adelantos',13:'Sueldo computable',14:'Asignación familiar',15:'Horas extras 25%',16:'Horas extras 35%',17:'Total remuneraciones',19:'ONP',20:'AFP fondo',21:'AFP comisión',22:'AFP seguro',23:'Adelantos',24:'Total descuentos',26:'Neto a pagar',27:'EsSalud empleador',28:'Costo empleador',29:'Neto / remuneraciones',31:'Neto esperado Swift',32:'Diferencia con Swift',33:'Control cruzado'};
for(const [r,l] of Object.entries(labels))value(c,`A${r}`,l);
const inputs=[[2500,30,0,'ONP','AFP Ejemplo',0,0,0],[1800,27,1,'ONP','AFP Ejemplo',0,0,0],[3000,30,1,'AFP','AFP Ejemplo',4,4,200],[4200,24,1,'AFP','AFP Ejemplo',2,2,100],[2300,30,0,'AFP','Prima (flujo)',0,0,0]];
inputs.forEach((input,i)=>input.forEach((v,j)=>value(c,`${String.fromCharCode(66+i)}${4+j}`,v)));
for(const col of ['G','H']) {value(c,`${col}4`,null);value(c,`${col}5`,30);value(c,`${col}6`,0);value(c,`${col}7`,'ONP');value(c,`${col}8`,'AFP Ejemplo');for(const r of [9,10,11])value(c,`${col}${r}`,0);}
const par=r=>`'Parámetros'!$B$${r}`;
function expressions(col) { const x=r=>`${col}${r}`;const lookup=k=>`VLOOKUP(${x(8)},'Parámetros'!$A$16:$D$20,${k},FALSE)`;return {
 13:`ROUND(${x(4)}/${par(8)}*${x(5)},2)`,14:`IF(${x(6)}=1,ROUND(${par(4)}*${par(5)},2),0)`,
 15:`ROUND(${x(4)}/${par(8)}/${par(9)}*${par(10)}*${x(9)},2)`,16:`ROUND(${x(4)}/${par(8)}/${par(9)}*${par(11)}*${x(10)},2)`,17:`SUM(${x(13)}:${x(16)})`,
 19:`IF(${x(7)}="ONP",ROUND(${x(17)}*${par(6)},2),0)`,20:`IF(${x(7)}="AFP",ROUND(${x(17)}*${lookup(2)},2),0)`,21:`IF(${x(7)}="AFP",ROUND(${x(17)}*${lookup(3)},2),0)`,22:`IF(${x(7)}="AFP",ROUND(${x(17)}*${lookup(4)},2),0)`,23:`ROUND(${x(11)},2)`,24:`SUM(${x(19)}:${x(23)})`,26:`${x(17)}-${x(24)}`,27:`ROUND(${x(17)}*${par(7)},2)`,28:`SUM(${x(17)},${x(27)})`,29:`${x(26)}/${x(17)}`};}
for(const col of ['B','C','D','E','F','G','H']) {
 for(const [r,exp] of Object.entries(expressions(col)))formula(c,`${col}${r}`,`=IF(${col}4="","",${exp})`);
 c.getRange(`${col}7`).dataValidation={rule:{type:'list',values:['ONP','AFP']}};
 c.getRange(`${col}8`).dataValidation={rule:{type:'list',formula1:"'Parámetros'!$A$16:$A$20"}};
 c.dataValidations.add({range:`${col}5`,rule:{type:'whole',operator:'between',formula1:1,formula2:30}});
 c.dataValidations.add({range:`${col}6`,rule:{type:'whole',operator:'between',formula1:0,formula2:1}});
}
const expected=[2175,1516.41,2631.73,3011.17];
expected.forEach((v,i)=>{const col=String.fromCharCode(66+i);value(c,`${col}31`,v);formula(c,`${col}32`,`=ROUND(${col}26-${col}31,2)`);formula(c,`${col}33`,`=IF(${col}32=0,"Coincide","Revisar")`);});
value(c,'F31',Number(swiftResults[4]['26']));formula(c,'F32','=ROUND(F26-F31,2)');formula(c,'F33','=IF(F32=0,"Coincide","Revisar")');value(c,'G31','Pendiente');value(c,'H31','Pendiente');
c.getRange('B4:H11').format.font.color='#1565C0';c.getRange('B13:H32').setNumberFormat('#,##0.00;[Red]-#,##0.00');c.getRange('B29:H29').setNumberFormat('0.00%');
c.getRange('B8:H8').format.wrapText=true;c.getRange('A8:H8').format.rowHeight=42;
value(c,'A35','Oferta: ver Parámetros, fila 26. Compañeros: completar sueldos reales y fuentes antes de comparar.');c.getRange('A35:H36').merge();c.getRange('A35:H36').format.wrapText=true;

header(b,1,'Boleta de ejemplo','D');
row(b,3,['Caso seleccionado',1,'Selecciona del 1 al 5']);
b.dataValidations.add({range:'B3',rule:{type:'whole',operator:'between',formula1:1,formula2:5}});
value(b,'A4','Alex Ejemplo · Horizonte Académico S.A.C. · datos ficticios');b.getRange('A4:D4').merge();
for(let r=6;r<=13;r++) {value(b,`A${r}`,labels[r-2]);formula(b,`B${r}`,`=INDEX(Casos!$B$${r-2}:$F$${r-2},1,$B$3)`);}
header(b,15,'REMUNERACIONES','D');
const mapping={16:13,17:14,18:15,19:16,20:17,23:19,24:20,25:21,26:22,27:23,28:24,31:27,34:26,36:28};
header(b,22,'RETENCIONES / DESCUENTOS','D');header(b,30,'APORTACIONES DEL EMPLEADOR','D');
for(const [r,origin] of Object.entries(mapping)) {
 value(b,`A${r}`,labels[origin]);formula(b,`B${r}`,`=INDEX(Casos!$B$${origin}:$F$${origin},1,$B$3)`);
 b.getRange(`C${r}:D${r}`).merge();value(b,`C${r}`,`'=INDEX(Casos!B${origin}:F${origin},1,B3)`);
}
b.getRange('C6:D36').format.columnWidth=27;
value(b,'A38','EsSalud no se descuenta del neto. Para modificar entradas, edita las celdas azules de Casos.');b.getRange('A38:D40').merge();b.getRange('A38:D40').format.wrapText=true;
b.getRange('B16:B36').setNumberFormat('#,##0.00;[Red]-#,##0.00');
b.getRange('A34:D34').format={fill:'#D9F0E8',font:{bold:true,color:'#075841'},rowHeight:36};

header(e,1,'Explicación de fórmulas y análisis','D');
row(e,3,['Concepto','En palabras','Fórmula de ejemplo','Resultado']);
const explanations=[
 ['Sueldo computable','Divide el sueldo básico entre 30 y multiplica por los días trabajados.',"'=1800/30*27",'=Casos!C13'],
 ['Asignación familiar','Si tiene hijos, toma 10% de la RMV completa, sin prorratear.',"'=1230*10%",'=Casos!C14'],
 ['Valor hora','Divide el sueldo básico entre 30 y luego entre 8. No redondees esta base.',"'=3000/30/8",'=Casos!D4/\'Parámetros\'!B8/\'Parámetros\'!B9'],
 ['Horas extras 25%','Multiplica el valor hora por 1.25 y por sus horas, y redondea.',"'=ROUND(12.5*1.25*4,2)",'=Casos!D15'],
 ['Horas extras 35%','Multiplica el valor hora por 1.35 y por sus horas, y redondea.',"'=ROUND(12.5*1.35*4,2)",'=Casos!D16'],
 ['Total remuneraciones','Suma sueldo computable, asignación y ambas horas extras.',"'=SUM(3000,123,62.5,67.5)",'=Casos!D17'],
 ['ONP','Retiene 13% del total de remuneraciones, si eligió ONP.',"'=ROUND(2500*13%,2)",'=Casos!B19'],
 ['AFP fondo','Multiplica el total por el porcentaje del fondo.',"'=ROUND(3253*10%,2)",'=Casos!D20'],
 ['AFP comisión','Calcula y redondea la comisión por separado.',"'=ROUND(3253*1.6%,2)",'=Casos!D21'],
 ['AFP seguro','Calcula y redondea el seguro por separado.',"'=ROUND(3253*1.35%,2)",'=Casos!D22'],
 ['Adelanto','Resta el monto ingresado. El dinero ya fue recibido antes.',"'=200",'=Casos!D23'],
 ['Total descuentos','Suma ONP o los tres conceptos AFP y el adelanto.',"'=SUM(325.30,52.05,43.92,200)",'=Casos!D24'],
 ['Neto a pagar','Resta los descuentos del total remunerado.',"'=3253-621.27",'=Casos!D26'],
 ['EsSalud','El empleador aporta 9% del total, sin restarlo al trabajador.',"'=ROUND(3253*9%,2)",'=Casos!D27'],
 ['Costo empleador','Suma remuneraciones y EsSalud.',"'=3253+292.77",'=Casos!D28']
];
explanations.forEach((x,i)=>{row(e,i+4,x.slice(0,3));formula(e,`D${i+4}`,x[3]);});
header(e,21,'Preguntas de análisis','D');
const analysis=[
 ['1. Neto con ONP','Caso 3: total menos ONP y adelanto.','',"=Casos!D17-ROUND(Casos!D17*'Parámetros'!B6,2)-Casos!D11"],
 ['1. Neto con AFP Ejemplo','AFP deja S/ 1.62 más este mes. La decisión también depende de cobertura, reglas de jubilación y comisiones.','','=Casos!D26'],
 ['2. Costo real','Remuneraciones más EsSalud. No incluye otros costos fuera del ejercicio.','','=Casos!D28'],
 ['2. Neto / costo','La proporción del costo que llega como neto es aproximadamente 74.22%.','','=Casos!D26/Casos!D28'],
 ['3. Neto con 30 días','El sueldo sube S/ 180 y ONP sube S/ 23.40. Neto sube S/ 156.60. La asignación se mantiene completa.','',"=Casos!C4+'Parámetros'!B4*'Parámetros'!B5-ROUND((Casos!C4+'Parámetros'!B4*'Parámetros'!B5)*'Parámetros'!B6,2)"],
 ['4. Horas extras / total','S/ 130 de horas extras dividido entre S/ 3,253 de remuneraciones: aproximadamente 4%.','','=SUM(Casos!D15:D16)/Casos!D17'],
 ['5. Oferta laboral','Sueldo S/ 2,300, mes completo sin hijos, sin extras, AFP Prima sobre flujo. Se usa solo el sueldo publicado.','','=Casos!F26'],
 ['5. Neto / bruto','El neto equivale a 87.03% del bruto con las hipótesis indicadas.','','=Casos!F29']
];
analysis.forEach((x,i)=>{row(e,i+23,x.slice(0,3));formula(e,`D${i+23}`,x[3]);});
value(e,'A33','Comparación con compañeros');value(e,'B33','Completar G y H de Casos con sus sueldos y registrar sus enlaces. No se han recibido sus datos.');e.getRange('B33:D34').merge();e.getRange('B33:D34').format.wrapText=true;
e.getRange('B1:B34').format.columnWidth=65;e.getRange('C1:C34').format.columnWidth=42;e.getRange('D1:D34').format.columnWidth=21;
e.getRange('A4:D30').format.wrapText=true;e.getRange('A4:D30').format.rowHeight=58;e.getRange('D4:D30').setNumberFormat('#,##0.00');for(const r of [26,28,30])e.getRange(`D${r}`).setNumberFormat('0.00%');

await wb.recalculate();
let verifiedConcepts=0;
for(let i=0;i<swiftResults.length;i++) {
 const col=String.fromCharCode(66+i);
 for(const [r,amount] of Object.entries(swiftResults[i])) {
  const actual=c.getRange(`${col}${r}`).values[0][0];
  if(typeof actual!=='number'||Math.abs(actual-Number(amount))>0.000001)throw Error(`Swift / Excel: caso ${i+1}, ${col}${r}: ${actual} != ${amount}`);
  verifiedConcepts++;
 }
}
const amounts=[2500,1743,3253,3574]; const discounts=[325,226.59,621.27,562.83];const health=[225,156.87,292.77,321.66];
for(let i=0;i<4;i++) { const col=String.fromCharCode(66+i);for(const [r,expectedValue]of [[17,amounts[i]],[24,discounts[i]],[26,expected[i]],[27,health[i]]]) {
 const actual=c.getRange(`${col}${r}`).values[0][0];if(Math.abs(actual-expectedValue)>.000001)throw Error(`Caso ${i+1}, fila ${r}: ${actual} != ${expectedValue}`);
}}
for(let i=1;i<=5;i++){value(b,'B3',i);await wb.recalculate();const n=b.getRange('B34').values[0][0];const wanted=c.getRange(`${String.fromCharCode(65+i)}26`).values[0][0];if(Math.abs(n-wanted)>.000001)throw Error('Selector no recalcula');}
value(b,'B3',1);await wb.recalculate();
const original=c.getRange('B4').values[0][0];value(c,'B4',2600);await wb.recalculate();if(c.getRange('B26').values[0][0]!==2262)throw Error('Entrada no recalcula');value(c,'B4',original);await wb.recalculate();
const errors=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:30},summary:'Errores de fórmulas'});console.log(errors.ndjson);
await fs.mkdir(path.join(root,'tools','previews'),{recursive:true});
for(const [sheetName,range]of [['Parámetros','A1:E28'],['Boleta','A1:D40'],['Casos','A1:H36'],['Explicación','A1:D34']]){
 const image=await wb.render({sheetName,range,scale:1,format:'png'});await fs.writeFile(path.join(root,'tools','previews',`${sheetName}.png`),new Uint8Array(await image.arrayBuffer()));
}
await (await SpreadsheetFile.exportXlsx(wb)).save(path.join(out,'Boleta_Grupo_B.xlsx'));
await fs.writeFile(path.join(out,'control-cruzado.json'),JSON.stringify({fecha:'2026-10-26',conceptosVerificados:verifiedConcepts,casos:swiftResults,selectorVerificado:true,cambioDeEntradaVerificado:true},null,2));
console.log(`Excel exportado. ${verifiedConcepts} importes coinciden con Swift. Selector e input recalculados correctamente.`);
