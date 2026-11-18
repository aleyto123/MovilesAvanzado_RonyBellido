import SwiftUI
import SwiftData

struct NuevaVentaView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Cliente.nombre) private var clientes: [Cliente]
    @Query(sort: \Producto.nombre) private var productos: [Producto]
    @State private var clienteID: PersistentIdentifier?
    @State private var productoID: PersistentIdentifier?
    @State private var textoCantidad = "1"
    @FocusState private var editandoCantidad: Bool
    @State private var mensaje = ""
    @State private var creandoCliente = false
    @State private var documentoBuscado = ""
    @State private var clientePorEditar: Cliente?
    let usuario: Usuario

    private var cliente: Cliente? { clientes.first { $0.persistentModelID == clienteID } }
    private var producto: Producto? { productos.first { $0.persistentModelID == productoID } }
    private var cantidad: Int? { textoCantidad.unidadesPositivas }

    private var problemaCantidad: String? {
        guard let producto else { return nil }
        guard producto.stock > 0 else { return "Producto agotado. Selecciona otro producto." }
        guard let cantidad else { return "Ingresa una cantidad entera mayor que cero." }
        guard cantidad <= producto.stock else {
            return "Stock insuficiente. Hay \(producto.stock) unidades disponibles."
        }
        return nil
    }

    private var importe: ImporteVenta? {
        guard let cliente, let producto, let cantidad, problemaCantidad == nil else { return nil }
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
                    TextField("Buscar cliente por documento", text: $documentoBuscado)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .onSubmit(buscarCliente)
                    Button("Buscar cliente", action: buscarCliente)
                        .disabled(documentoBuscado.documentoNormalizado.isEmpty)
                    Picker("Cliente", selection: $clienteID) {
                        Text("Seleccionar").tag(nil as PersistentIdentifier?)
                        ForEach(clientes) { cliente in
                            Text(cliente.nombre).tag(Optional(cliente.persistentModelID))
                        }
                    }
                    Button("Nuevo cliente", systemImage: "person.badge.plus") {
                        creandoCliente = true
                    }
                    if let cliente {
                        Text("\(cliente.tipoIdentificacion?.rawValue ?? "Documento por revisar") · \(cliente.documento)")
                            .font(.caption).foregroundStyle(.secondary)
                        if !cliente.identificacionCompleta {
                            Text("Completa el tipo y número de documento del cliente para registrar la venta.")
                                .foregroundStyle(.red)
                            Button("Completar identificación") { clientePorEditar = cliente }
                        }
                    }
                    Picker("Producto", selection: $productoID) {
                        Text("Seleccionar").tag(nil as PersistentIdentifier?)
                        ForEach(productos) { producto in
                            Text(producto.stock > 0 ? producto.nombre : "\(producto.nombre) · Agotado")
                                .tag(Optional(producto.persistentModelID))
                                .disabled(producto.stock <= 0)
                        }
                    }
                    if let producto {
                        Text("Precio unitario: \(producto.precio.soles)")
                        Text("Stock disponible: \(producto.stock)")
                            .foregroundStyle(producto.stock > 0 ? Color.secondary : Color.red)
                        HStack {
                            Text("Cantidad")
                            TextField("Unidades", text: $textoCantidad)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .focused($editandoCantidad)
                            Stepper("Ajustar cantidad", value: Binding(
                                get: { min(max(1, cantidad ?? 1), max(1, producto.stock)) },
                                set: { textoCantidad = String($0) }
                            ), in: 1...max(1, producto.stock))
                            .labelsHidden()
                            .fixedSize()
                            .disabled(producto.stock <= 0)
                        }
                        if let problemaCantidad {
                            Text(problemaCantidad).foregroundStyle(.red)
                        }
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
                        if importe.total > 700 {
                            Text("El total supera S/ 700. Revisa los nombres y el documento del cliente.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                Button("Registrar venta", action: registrar)
                    .frame(maxWidth: .infinity)
                    .disabled(importe == nil || cliente?.identificacionCompleta != true)
            }
            .navigationTitle("Nueva venta")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") { editandoCantidad = false }
                }
            }
            .onChange(of: productoID) { _, _ in textoCantidad = "1" }
            .sheet(isPresented: $creandoCliente) {
                EditorCliente(cliente: nil, documentoInicial: documentoBuscado) { guardado in
                    clienteID = guardado.persistentModelID
                    documentoBuscado = guardado.documento
                }
            }
            .sheet(item: $clientePorEditar) { seleccionado in
                EditorCliente(cliente: seleccionado)
            }
            .alertaVentas($mensaje)
        }
    }

    private func buscarCliente() {
        let numero = documentoBuscado.documentoNormalizado
        guard !numero.isEmpty else { return }
        let coincidencias = clientes.filter { $0.documento.documentoNormalizado == numero }
        guard coincidencias.count <= 1 else {
            mensaje = "Hay varios registros con ese número. Selecciona al cliente y revisa su tipo de documento."
            return
        }
        guard let encontrado = coincidencias.first else {
            clienteID = nil
            creandoCliente = true
            return
        }
        clienteID = encontrado.persistentModelID
    }

    private func registrar() {
        editandoCantidad = false
        guard !usuario.esSupervisor, let cliente, let producto else { return }
        guard cliente.identificacionCompleta else {
            mensaje = "Revisa los nombres, el tipo y el número de documento del cliente."
            return
        }
        if let problemaCantidad {
            mensaje = problemaCantidad
            return
        }
        guard let cantidad, let importe else { return }
        let venta = Venta(vendedor: usuario, producto: producto, cliente: cliente, cantidad: cantidad, importe: importe)
        contexto.insert(venta)
        producto.stock -= cantidad
        do {
            try contexto.guardarCambios()
            textoCantidad = "1"
            productoID = nil
            clienteID = nil
            documentoBuscado = ""
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
    @Query(sort: \Usuario.nombre) private var cuentas: [Usuario]
    @State private var periodo = Periodo.todas
    @State private var vendedorID: PersistentIdentifier?
    @State private var busqueda = ""
    @State private var porAnular: Venta?
    let usuario: Usuario

    private var propias: [Venta] {
        ventas.filter { $0.vendedor.persistentModelID == usuario.persistentModelID }
    }

    var body: some View {
        let ahora = Date.now
        let calendario = Calendar.current
        let intervalo = periodo.intervalo(en: ahora, calendario: calendario)
        let visibles = (usuario.esSupervisor ? ventas : propias).filter { venta in
            (intervalo.map { venta.fecha >= $0.start && venta.fecha < $0.end } ?? true)
                && (vendedorID == nil || venta.vendedor.persistentModelID == vendedorID)
                && (busqueda.recortado.isEmpty || venta.cliente.nombre.localizedCaseInsensitiveContains(busqueda.recortado))
        }

        NavigationStack {
            List {
                if !usuario.esSupervisor {
                    Section {
                        indicador(.hoy, ahora: ahora, calendario: calendario)
                        indicador(.mes, ahora: ahora, calendario: calendario)
                    }
                }
                Section {
                    Picker("Período", selection: $periodo) {
                        ForEach(Periodo.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    if usuario.esSupervisor {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                chip("Todos", id: nil)
                                ForEach(cuentas.filter { !$0.esSupervisor }) { cuenta in
                                    chip(cuenta.nombre, id: cuenta.persistentModelID)
                                }
                            }
                        }
                    }
                }
                Section {
                    if visibles.isEmpty {
                        ContentUnavailableView("Sin ventas", systemImage: "cart",
                                               description: Text("No hay operaciones que coincidan."))
                    }
                    ForEach(visibles) { venta in
                        NavigationLink {
                            DetalleVentaView(venta: venta, usuario: usuario)
                        } label: {
                            fila(venta)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if usuario.esSupervisor && !venta.anulada {
                                Button("Anular", role: .destructive) { porAnular = venta }
                            }
                        }
                    }
                }
            }
            .navigationTitle(usuario.esSupervisor ? "Ventas del equipo" : "Mis ventas")
            .searchable(text: $busqueda, prompt: "Buscar por cliente")
            .sheet(item: $porAnular) { AnularVentaView(venta: $0, usuario: usuario) }
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

    private func chip(_ titulo: String, id: PersistentIdentifier?) -> some View {
        Button { vendedorID = id } label: {
            Text(titulo)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(vendedorID == id ? Color.blue : Color.secondary.opacity(0.12), in: Capsule())
                .foregroundStyle(vendedorID == id ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }

    private func fila(_ venta: Venta) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(venta.cliente.nombre).font(.headline)
                Text("\(venta.fecha.formatted(date: .numeric, time: .omitted)) · \(venta.producto.nombre) × \(venta.cantidad)")
                    .font(.caption).foregroundStyle(.secondary)
                if usuario.esSupervisor {
                    Text(venta.vendedor.nombre).font(.caption).foregroundStyle(.secondary)
                }
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

private struct DetalleVentaView: View {
    let venta: Venta
    let usuario: Usuario

    private var subtotal: Decimal {
        ImporteVenta.redondear(Decimal(venta.precioUnitario) * Decimal(venta.cantidad))
    }

    var body: some View {
        Form {
            Section("Operación") {
                LabeledContent("Fecha", value: venta.fecha.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Vendedor", value: venta.vendedor.nombre)
                LabeledContent("Cliente", value: venta.cliente.nombre)
                LabeledContent(venta.cliente.tipoIdentificacion?.rawValue ?? "Documento", value: venta.cliente.documento)
                LabeledContent("Estado", value: venta.anulada ? "Anulada" : "Vigente")
            }
            Section("Producto vendido") {
                Text(venta.producto.nombre).font(.headline)
                LabeledContent("Cantidad", value: "\(venta.cantidad) u.")
                LabeledContent("Precio unitario aplicado", value: venta.precioUnitario.soles)
            }
            Section("Importes de la venta") {
                LabeledContent("Subtotal", value: subtotal.soles)
                LabeledContent("Descuento aplicado", value: venta.descuento.soles)
                LabeledContent("IGV (18 %)", value: venta.igv.soles)
                LabeledContent("Total", value: venta.total.soles).font(.headline)
            }
            Section("Comprobante académico") {
                NavigationLink(venta.comprobanteDemo == nil ? "Preparar comprobante" : "Ver comprobante") {
                    ComprobanteDemoView(venta: venta, usuario: usuario)
                }
                Text("Demostración local sin valor tributario.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if venta.anulada {
                Section("Anulación") {
                    Text(venta.motivoAnulacion ?? "Sin motivo registrado")
                    Text("Esta venta está excluida de los reportes y sus unidades fueron devueltas al stock.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Detalle de venta")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ComprobanteDemoView: View {
    @Environment(\.modelContext) private var contexto
    @State private var error = ""
    let venta: Venta
    let usuario: Usuario

    private var guardado: ComprobanteDemostracion? {
        guard let datos = venta.comprobanteDemo else { return nil }
        return try? JSONDecoder().decode(ComprobanteDemostracion.self, from: datos)
    }

    var body: some View {
        Form {
            Section {
                Label("Modo demostración", systemImage: "graduationcap.fill")
                    .font(.headline)
                Text("Documento académico sin valor tributario. La validación se realiza en esta app, sin envío a SUNAT.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            if let guardado {
                Section("Boleta de demostración") {
                    LabeledContent("Número", value: guardado.identificador)
                    LabeledContent("Generación", value: guardado.fechaEmision.formatted(date: .numeric, time: .shortened))
                    LabeledContent("Estado", value: venta.anulada ? "Anulada" : "Generada localmente")
                    Label("Validación local completada", systemImage: "checkmark.circle")
                }
                Section("Detalle del comprobante") {
                    Text(guardado.textoCompartido(anulada: venta.anulada, motivo: venta.motivoAnulacion))
                        .font(.callout)
                        .textSelection(.enabled)
                }
                Section {
                    ShareLink(item: guardado.textoCompartido(anulada: venta.anulada, motivo: venta.motivoAnulacion)) {
                        Label("Compartir comprobante", systemImage: "square.and.arrow.up")
                    }
                }
            } else if venta.comprobanteDemo != nil || venta.numeroComprobanteDemo != 0 {
                Text("No se pudo leer el comprobante guardado. Conserva el registro y revisa sus datos antes de continuar.")
                    .foregroundStyle(.red)
            } else {
                Section("Vista previa") {
                    LabeledContent("Cliente", value: venta.cliente.nombre)
                    LabeledContent(venta.cliente.tipoIdentificacion?.rawValue ?? "Documento por revisar",
                                   value: venta.cliente.documento)
                    LabeledContent("Producto", value: venta.producto.nombre)
                    LabeledContent("Cantidad", value: "\(venta.cantidad) u.")
                    LabeledContent("Precio unitario", value: venta.precioUnitario.soles)
                    LabeledContent("Subtotal", value: ImporteVenta.redondear(Decimal(venta.precioUnitario) * Decimal(venta.cantidad)).soles)
                    LabeledContent("Descuento", value: venta.descuento.soles)
                    LabeledContent("IGV (18 %)", value: venta.igv.soles)
                    LabeledContent("Total", value: venta.total.soles)
                    Text("Se asignará un número de demostración al confirmar. La venta y su stock ya están registrados.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if venta.anulada {
                    Text("La venta está anulada. Solo puedes consultar comprobantes generados antes de su anulación.")
                        .foregroundStyle(.red)
                } else if !venta.cliente.identificacionCompleta {
                    Text("Completa la identificación del cliente desde Clientes antes de generar el comprobante.")
                        .foregroundStyle(.red)
                }
                Button("Validar y generar demostración", action: generar)
                    .disabled(venta.anulada || !venta.cliente.identificacionCompleta)
            }
        }
        .navigationTitle("Comprobante")
        .navigationBarTitleDisplayMode(.inline)
        .alertaVentas($error)
    }

    private func generar() {
        guard usuario.esSupervisor || venta.vendedor.persistentModelID == usuario.persistentModelID,
              !venta.anulada, venta.comprobanteDemo == nil, venta.numeroComprobanteDemo == 0,
              let tipo = venta.cliente.tipoIdentificacion else { return }
        do {
            // Se asigna y guarda el número junto con el comprobante en la misma operación local.
            var consulta = FetchDescriptor<Venta>(sortBy: [SortDescriptor(\Venta.numeroComprobanteDemo, order: .reverse)])
            consulta.fetchLimit = 1
            let ultimo = try contexto.fetch(consulta).first?.numeroComprobanteDemo ?? 0
            let (numero, desborda) = ultimo.addingReportingOverflow(1)
            guard !desborda else {
                error = "No se pudo asignar otro número de demostración."
                return
            }
            let comprobante = ComprobanteDemostracion(
                numero: numero, fechaEmision: .now, fechaVenta: venta.fecha,
                cliente: venta.cliente.nombre, tipoDocumento: tipo,
                documento: venta.cliente.documento.documentoNormalizado,
                vendedor: venta.vendedor.nombre, producto: venta.producto.nombre,
                cantidad: venta.cantidad, precioUnitario: Decimal(venta.precioUnitario),
                descuento: ImporteVenta.redondear(Decimal(venta.descuento)),
                igv: ImporteVenta.redondear(Decimal(venta.igv)),
                total: ImporteVenta.redondear(Decimal(venta.total))
            )
            if let problema = comprobante.problemaValidacion {
                error = problema
                return
            }
            let datos = try JSONEncoder().encode(comprobante)
            venta.numeroComprobanteDemo = numero
            venta.comprobanteDemo = datos
            try contexto.guardarCambios()
        } catch {
            self.error = "No se pudo guardar el comprobante. Intenta nuevamente."
        }
    }
}

private struct AnularVentaView: View {
    @Environment(\.modelContext) private var contexto
    @Environment(\.dismiss) private var cerrar
    @State private var motivo = ""
    @State private var error = ""
    let venta: Venta
    let usuario: Usuario

    var body: some View {
        NavigationStack {
            Form {
                Section("Operación") {
                    LabeledContent("Cliente", value: venta.cliente.nombre)
                    LabeledContent("Producto", value: venta.producto.nombre)
                    LabeledContent("Total", value: venta.total.soles)
                    Text("Se devolverán \(venta.cantidad) unidades al stock.")
                }
                Section("Motivo obligatorio") {
                    TextField("Motivo de anulación", text: $motivo, axis: .vertical)
                }
                Button("Anular venta", role: .destructive, action: anular)
                    .disabled(motivo.recortado.isEmpty || venta.anulada)
            }
            .navigationTitle("Anular venta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } }
            }
            .alertaVentas($error)
        }
    }

    private func anular() {
        guard usuario.esSupervisor, !venta.anulada, !motivo.recortado.isEmpty else { return }
        let (stock, desborda) = venta.producto.stock.addingReportingOverflow(venta.cantidad)
        guard !desborda else {
            error = "No se pudo reponer el stock porque supera el límite permitido."
            return
        }
        venta.anulada = true
        venta.motivoAnulacion = motivo.recortado
        venta.producto.stock = stock
        do {
            try contexto.guardarCambios()
            cerrar()
        } catch {
            self.error = "No se pudo anular la venta. El stock se conservó."
        }
    }
}
