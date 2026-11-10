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

private enum Periodo: String, CaseIterable, Identifiable {
    case todas = "Todas"
    case hoy = "Hoy"
    case mes = "Mes"

    var id: String { rawValue }

    func intervalo(en fecha: Date, calendario: Calendar) -> DateInterval? {
        switch self {
        case .todas: nil
        case .hoy: calendario.dateInterval(of: .day, for: fecha)
        case .mes: calendario.dateInterval(of: .month, for: fecha)
        }
    }
}

struct HistorialView: View {
    @Query(sort: \Venta.fecha, order: .reverse) private var ventas: [Venta]
    @State private var periodo = Periodo.todas
    @State private var busqueda = ""
    let usuario: Usuario

    private var propias: [Venta] {
        ventas.filter { $0.vendedor.persistentModelID == usuario.persistentModelID }
    }

    var body: some View {
        let ahora = Date.now
        let calendario = Calendar.current
        let intervalo = periodo.intervalo(en: ahora, calendario: calendario)
        let visibles = propias.filter { venta in
            (intervalo.map { venta.fecha >= $0.start && venta.fecha < $0.end } ?? true)
                && (busqueda.recortado.isEmpty || venta.cliente.nombre.localizedCaseInsensitiveContains(busqueda.recortado))
        }

        NavigationStack {
            List {
                Section {
                    indicador(.hoy, ahora: ahora, calendario: calendario)
                    indicador(.mes, ahora: ahora, calendario: calendario)
                }
                Section {
                    Picker("Período", selection: $periodo) {
                        ForEach(Periodo.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    if visibles.isEmpty {
                        ContentUnavailableView("Sin ventas", systemImage: "cart",
                                               description: Text("No hay operaciones que coincidan."))
                    }
                    ForEach(visibles) { venta in
                        fila(venta)
                    }
                }
            }
            .navigationTitle("Mis ventas")
            .searchable(text: $busqueda, prompt: "Buscar por cliente")
        }
    }

    private func indicador(_ periodo: Periodo, ahora: Date, calendario: Calendar) -> some View {
        let intervalo = periodo.intervalo(en: ahora, calendario: calendario)
        let vigentes = propias.filter { venta in
            !venta.anulada && (intervalo.map { venta.fecha >= $0.start && venta.fecha < $0.end } ?? false)
        }
        let importe = vigentes.reduce(Decimal.zero) { $0 + Decimal($1.total) }
        return LabeledContent("\(periodo.rawValue) · \(vigentes.count) ventas", value: importe.soles)
    }

    private func fila(_ venta: Venta) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(venta.cliente.nombre).font(.headline)
                Text("\(venta.fecha.formatted(date: .numeric, time: .omitted)) · \(venta.producto.nombre) × \(venta.cantidad)")
                    .font(.caption).foregroundStyle(.secondary)
                if venta.anulada {
                    Label("Anulada", systemImage: "xmark.circle.fill").font(.caption).foregroundStyle(.red)
                    if let motivo = venta.motivoAnulacion {
                        Text(motivo).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            Text(venta.total.soles)
                .font(.subheadline.bold())
                .strikethrough(venta.anulada)
        }
    }
}
