# Requerimientos funcionales

## RF-01. Registro de la venta

| Requerimiento funcional |
|---|
| La aplicación debe mostrar la pantalla **Nueva Venta**. El usuario debe poder ingresar el nombre del electrodoméstico, el precio unitario, la cantidad, el número de meses y la tasa de interés mensual. La pantalla también debe incluir el botón **Calcular** para procesar la venta. |

## RF-02. Validación de los datos

| Requerimiento funcional |
|---|
| Al presionar **Calcular**, la aplicación debe revisar que los campos necesarios tengan información. El precio, la cantidad y los meses deben ser valores válidos mayores que cero. Si falta un dato o es incorrecto, la aplicación debe informar al usuario y no debe mostrar un resultado incompleto. |

## RF-03. Cálculo de los importes

| Requerimiento funcional |
|---|
| La aplicación debe calcular el subtotal, el IGV y la base de la venta. El subtotal se obtiene multiplicando el precio unitario por la cantidad, el IGV corresponde al 18 % del subtotal y la base es la suma del subtotal más el IGV. |

```text
subtotal = precioUnitario × cantidad
igv      = subtotal × 0.18
base     = subtotal + igv
```

## RF-04. Cálculo del financiamiento

| Requerimiento funcional |
|---|
| La aplicación debe calcular los intereses totales, el total a pagar y la cuota mensual. Para ello debe utilizar la tasa de interés mensual y el número de meses ingresados por el usuario. |

```text
intereses = base × (tasaInteresMensual / 100) × meses
total     = base + intereses
cuota     = total / meses
```

## RF-05. Mostrar los resultados

| Requerimiento funcional |
|---|
| Después de un cálculo correcto, la aplicación debe mostrar la pantalla **Resultado**. Esta pantalla debe presentar el subtotal, el IGV, la base, los intereses, el total a pagar y la cuota mensual de la venta. |

## RF-06. Formato de los importes

| Requerimiento funcional |
|---|
| Todos los importes calculados deben mostrarse en soles y con dos decimales. El formato esperado es `S/. 0.00`; además, el **Total** y la **Cuota mensual** deben resaltarse para que sean fáciles de identificar. |

## RF-07. Navegación entre pantallas

| Requerimiento funcional |
|---|
| Al presionar **Calcular** con datos válidos, el usuario debe pasar de **Nueva Venta** a **Resultado**. Desde **Resultado**, el usuario debe poder regresar a **Nueva Venta** para ingresar una nueva venta. |
