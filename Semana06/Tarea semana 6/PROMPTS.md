# Prompt usado

## Contexto

Estoy haciendo el ejercicio 4 de la Semana 6 en una aplicación de iOS con Swift, UIKit y Storyboard. La aplicación es una calculadora para vender un electrodoméstico a plazos.

Tengo dos pantallas: una pantalla llamada **Nueva Venta**, donde se colocan los datos, y otra pantalla llamada **Resultado**, donde se muestran los cálculos.

## Tarea

Ayúdame a completar este ejercicio siguiendo el mismo estilo de los ejercicios anteriores.

En la pantalla **Nueva Venta** necesito campos para:

- Electrodoméstico.
- Precio unitario.
- Cantidad.
- Meses.
- Interés mensual.

También necesito un botón **Calcular** que haga estas operaciones:

```text
subtotal  = precioUnitario * cantidad
igv       = subtotal * 0.18
base      = subtotal + igv
intereses = base * (tasaInteresMensual / 100) * meses
total     = base + intereses
cuota     = total / meses
```

Para pasar los resultados a la segunda pantalla, crea una clase `VentaModel` que herede de `NSObject`. El modelo debe tener las propiedades `subtotal`, `igv`, `base`, `intereses`, `total` y `cuota`, todas de tipo `Double`.

En la pantalla **Resultado** muestra los seis valores usando este formato:

```swift
String(format: "S/. %.2f", valor)
```

El botón **Calcular** debe usar un segue `Show` con el identificador `showResultado`. Pasa el objeto `VentaModel` usando `prepare(for:sender:)`.

## Restricciones

Usa solamente lo que hemos visto hasta la Semana 6: clases, `UINavigationController`, `IBOutlet`, `IBAction` y `prepare(for:sender:)`.

No uses Combine, Codable, bases de datos ni persistencia. No agregues cosas demasiado avanzadas porque la idea es practicar el paso de datos entre pantallas.

También explícame brevemente por qué conviene usar una `class` para `VentaModel` en vez de un `struct`, relacionándolo con lo visto en el PREDICT del ejercicio anterior.

## Formato de la respuesta

Dame el código separado por archivos y dime qué conexiones tengo que hacer en el Storyboard. También explícame de forma corta cómo se pasa el modelo desde **Nueva Venta** hasta **Resultado**.

## Ejemplo para probar

Si ingreso estos datos:

```text
Electrodoméstico: Secadora
Precio unitario: 80
Cantidad: 3
Meses: 4
Interés mensual: 10
```

Debería obtener aproximadamente:

```text
Subtotal: S/. 240.00
IGV: S/. 43.20
Base: S/. 283.20
Intereses: S/. 113.28
Total: S/. 396.48
Cuota mensual: S/. 99.12
```

## Reflexión

La IA siguió el patrón de la clase para enviar los datos con `prepare(for:sender:)`. Además, agregó una validación sencilla para no calcular si faltaban datos o si los meses eran cero. Eso fue algo adicional que no estaba explicado paso por paso en el enunciado.
