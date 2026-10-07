## 📋 Requerimientos Funcionales

### RF-01: Catálogo de Productos
* **RF-01.1 Visualización de Productos:** La aplicación debe mostrar una lista de productos disponibles (ej. Refrigeradora, Licuadora, Laptop, Cocina) con sus respectivos precios unitarios.
* **RF-01.2 Contador en Tiempo Real:** La pantalla del catálogo debe incluir un botón de acceso rápido al carrito que muestre la cantidad actual de productos agregados (ej. `Ver carrito (3)`).

### RF-02: Detalle y Selección de Productos
* **RF-02.1 Información Detallada:** Al seleccionar un producto del catálogo, la app debe transferir los datos y desplegar el nombre, precio unitario y stock disponible en la pantalla de detalle.
* **RF-02.2 Control de Stock y Cantidad:** El usuario podrá especificar la cantidad deseada. El sistema debe validar que la cantidad ingresada sea un número entero mayor a cero y que no supere el stock disponible.
* **RF-02.3 Agregar al Carrito:** Al confirmar la selección, el producto y la cantidad elegida se registrarán en la estructura global del carrito de compras.

### RF-03: Gestión del Carrito y Cálculos
* **RF-03.1 Resumen de Ítems:** La pantalla del carrito debe mostrar una lista textual estructurada con el desglose de productos agregados y sus cantidades.
* **RF-03.2 Cálculo del Subtotal:** Suma total del costo de los productos en el carrito.
* **RF-03.3 Aplicación de Descuentos:** Cálculo automático del porcentaje o monto de descuento según las reglas del negocio.
* **RF-03.4 Cálculo del IGV:** Aplicación del 18% de IGV sobre el monto resultante después del descuento: $(Subtotal - Descuento) \times 0.18$.
* **RF-03.5 Monto Total:** Cálculo final del importe total a pagar: $(Subtotal - Descuento) + IGV$.

### RF-04: Datos del Cliente y Validaciones
* **RF-04.1 Captura de Información:** Formulario para registrar el nombre completo y el DNI del comprador.
* **RF-04.2 Validación de Campos:** El sistema no permitirá continuar si los campos están vacíos.
* **RF-04.3 Validación de DNI:** Debe verificar estrictamente que el campo de DNI contenga exactamente 8 dígitos numéricos.

### RF-05: Emisión de Boleta y Finalización de Compra
* **RF-05.1 Generación de Comprobante:** Presentación de una pantalla modal (`BoletaViewController`) con el detalle final formateado (datos de la tienda, cliente, DNI, lista de ítems, subtotal, IGV y total).
* **RF-05.2 Restablecimiento y Retorno (Reto 1):** Al presionar el botón "Cerrar" en la boleta, la aplicación debe limpiar los datos del carrito activo y regresar automáticamente a la pantalla raíz del catálogo (`popToRootViewController`), quedando lista para un nuevo proceso de venta.