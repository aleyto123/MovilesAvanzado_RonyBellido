import SwiftUI
import SwiftData

struct NuevaCompraView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]
    @Query(sort: \Producto.nombre) private var productos: [Producto]
    @State private var vm = NuevaCompraViewModel()
    @FocusState private var campoActivo: Campo?
    let usuario: Usuario
    let cerrarSesion: () -> Void

    private enum Campo { case cantidad, costo }

    private var proveedor: Proveedor? { proveedores.first { $0.persistentModelID == vm.proveedorID } }
    private var producto: Producto? { productos.first { $0.persistentModelID == vm.productoID } }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                VStack(spacing: 0) {
                    selector("Proveedor", valor: proveedor?.nombre) {
                        ForEach(proveedores) { opcion in
                            Button(opcion.nombre) { vm.proveedorID = opcion.persistentModelID }
                        }
                    }
                    Divider()
                    selector("Producto", valor: producto?.nombre) {
                        ForEach(productos) { opcion in
                            Button(opcion.nombre) { vm.productoID = opcion.persistentModelID }
                        }
                    }
                    Divider()
                    entrada("Cantidad", texto: $vm.textoCantidad, marcador: "1", campo: .cantidad)
                    Divider()
                    entrada("Costo unitario", texto: $vm.textoCosto, marcador: "0.00", campo: .costo)
                    if campoActivo != nil {
                        Divider()
                        Button("Listo") { campoActivo = nil }
                            .padding(.vertical, 8)
                    }
                }
                .tarjetaCompras()

                if proveedores.isEmpty || productos.isEmpty {
                    Text("Pide al supervisor que registre proveedores y productos.")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                Picker("Forma de pago", selection: $vm.alCredito) {
                    Text("Contado").tag(false)
                    Text("Crédito 30 días").tag(true)
                }
                .pickerStyle(.segmented)

                VStack(spacing: 0) {
                    total("Subtotal", valor: vm.importe?.subtotal)
                    Divider()
                    total("IGV 18 %", valor: vm.importe?.igv)
                }
                .tarjetaCompras()
                totalCompra

                if vm.importe?.requiereAprobacion == true {
                    Label {
                        Text("Desde S/ 5.000, la compra queda **pendiente de aprobación**. El inventario se actualiza al aprobarla.")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    .font(.footnote)
                    .foregroundStyle(Color.pendienteCompras)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(13)
                    .background(Color.pendienteCompras.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
                }

                Button(vm.importe?.requiereAprobacion == true ? "Enviar a aprobación" : "Registrar compra",
                       action: registrar)
                    .buttonStyle(BotonCompras())
                    .disabled(proveedor == nil || producto == nil || vm.importe == nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
        .background(Color.fondoCompras)
        .scrollDismissesKeyboard(.interactively)
        .encabezadoCompras("Nueva compra", usuario: usuario, cerrarSesion: cerrarSesion)
        .alertaCompras($vm.mensaje)
    }

    private func registrar() {
        campoActivo = nil
        vm.registrar(proveedor: proveedor, producto: producto, comprador: usuario, en: ComprasStore(contexto: contexto))
    }

    private func selector<Opciones: View>(_ titulo: String, valor: String?,
                                          @ViewBuilder opciones: () -> Opciones) -> some View {
        Menu(content: opciones) {
            HStack {
                Text(titulo).foregroundStyle(.primary)
                Spacer(minLength: 12)
                Text(valor ?? "Seleccionar").lineLimit(1)
                Image(systemName: "chevron.right").font(.caption.weight(.semibold))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .frame(minHeight: 46)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(titulo)
        .accessibilityValue(valor ?? "Sin seleccionar")
    }

    private func entrada(_ titulo: String, texto: Binding<String>, marcador: String, campo: Campo) -> some View {
        HStack {
            Text(titulo)
            Spacer()
            TextField(marcador, text: texto)
                .keyboardType(campo == .cantidad ? .numberPad : .decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($campoActivo, equals: campo)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .frame(width: 87)
                .monospacedDigit()
                .background(Color.fondoCompras, in: RoundedRectangle(cornerRadius: 7))
                .overlay { RoundedRectangle(cornerRadius: 7).strokeBorder(Color.bordeCompras) }
                .accessibilityLabel(titulo)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 50)
    }

    private func total(_ titulo: String, valor: Decimal?) -> some View {
        HStack {
            Text(titulo)
            Spacer()
            Text(valor?.soles ?? "—").monospacedDigit().foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .padding(.horizontal, 15)
        .frame(minHeight: 37)
    }

    private var totalCompra: some View {
        HStack {
            Text("Total de la compra")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.mentaCompras)
            Spacer(minLength: 8)
            Text(vm.importe?.total.soles ?? "—")
                .font(.system(.title2, design: .serif, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(16)
        .background(Color.pinoCompras, in: RoundedRectangle(cornerRadius: 15))
        .accessibilityElement(children: .combine)
    }

}
