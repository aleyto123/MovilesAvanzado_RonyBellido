import SwiftUI
import SwiftData

struct NuevaVentaView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Cliente.nombre) private var clientes: [Cliente]
    @Query(sort: \Producto.nombre) private var productos: [Producto]
    @State private var clienteID: PersistentIdentifier?
    @State private var productoID: PersistentIdentifier?
    @State private var cantidad = 1
    @State private var mensaje = ""
    let usuario: Usuario

    private var cliente: Cliente? { clientes.first { $0.persistentModelID == clienteID } }
    private var producto: Producto? { productos.first { $0.persistentModelID == productoID } }

    private var importe: ImporteVenta? {
        guard let cliente, let producto else { return nil }
        return ImporteVenta(precio: Decimal(producto.precio), cantidad: cantidad, categoria: cliente.categoria)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label(usuario.nombre, systemImage: "person.crop.circle.fill").font(.headline)
                    Text("La venta se registra a tu nombre.").foregroundStyle(.secondary)
                }
                Section("Operación") {
                    Picker("Cliente", selection: $clienteID) {
                        Text("Seleccionar").tag(nil as PersistentIdentifier?)
                        ForEach(clientes) { cliente in
                            Text(cliente.nombre).tag(Optional(cliente.persistentModelID))
                        }
                    }
                    Picker("Producto", selection: $productoID) {
                        Text("Seleccionar").tag(nil as PersistentIdentifier?)
                        ForEach(productos) { producto in
                            Text(producto.nombre).tag(Optional(producto.persistentModelID))
                        }
                    }
                    Stepper("Cantidad: \(cantidad)", value: $cantidad, in: 1...Int.max)
                    if let producto {
                        Text("Stock disponible: \(producto.stock)").foregroundStyle(.secondary)
                    }
                    if productos.isEmpty || clientes.isEmpty {
                        Text("Agrega un cliente y pide al supervisor que registre productos para empezar.")
                            .foregroundStyle(.secondary)
                    }
                }
                if let importe, let cliente {
                    Section("Resumen calculado") {
                        LabeledContent("Subtotal", value: importe.subtotal.soles)
                        LabeledContent("Descuento · \(cliente.categoria.rawValue)", value: importe.descuento.soles)
                        LabeledContent("IGV (18 %)", value: importe.igv.soles)
                        LabeledContent("Total", value: importe.total.soles).font(.headline)
                    }
                }
                Button("Registrar venta", action: registrar)
                    .frame(maxWidth: .infinity)
                    .disabled(importe == nil)
            }
            .navigationTitle("Nueva venta")
            .alertaVentas($mensaje)
        }
    }

    private func registrar() {
        guard !usuario.esSupervisor, let cliente, let producto, let importe else { return }
        guard cantidad > 0, cantidad <= producto.stock else {
            mensaje = "Stock insuficiente. Hay \(producto.stock) unidades disponibles."
            return
        }
        let venta = Venta(vendedor: usuario, producto: producto, cliente: cliente, cantidad: cantidad, importe: importe)
        contexto.insert(venta)
        producto.stock -= cantidad
        do {
            try contexto.guardarCambios()
            cantidad = 1
            productoID = nil
            clienteID = nil
            mensaje = "Venta registrada por \(venta.total.soles)."
        } catch {
            mensaje = "No se pudo guardar la venta. El stock se conservó."
        }
    }
}
