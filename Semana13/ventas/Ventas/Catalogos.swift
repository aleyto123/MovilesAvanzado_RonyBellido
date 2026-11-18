import SwiftUI
import SwiftData

struct ProductosView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Producto.nombre) private var productos: [Producto]
    @State private var busqueda = ""
    @State private var categoria: String?
    @State private var seleccionado: Producto?
    @State private var editando = false
    @State private var productoParaReponer: Producto?
    @State private var error = ""
    let usuario: Usuario

    private var categorias: [String] { Set(productos.map(\.categoria)).sorted() }

    private var visibles: [Producto] {
        productos.filter {
            (categoria == nil || $0.categoria == categoria)
                && (busqueda.recortado.isEmpty || $0.nombre.localizedCaseInsensitiveContains(busqueda.recortado))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !categorias.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            filtro("Todos", valor: nil)
                            ForEach(categorias, id: \.self) { filtro($0, valor: $0) }
                        }
                    }
                }
                if visibles.isEmpty {
                    ContentUnavailableView("Sin productos", systemImage: "shippingbox",
                                           description: Text("No hay productos que coincidan."))
                }
                ForEach(visibles) { producto in
                    HStack {
                        AvatarIniciales(nombre: producto.nombre)
                        VStack(alignment: .leading) {
                            Text(producto.nombre).font(.headline)
                            Text(producto.categoria).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(producto.precio.soles)
                        Text("\(producto.stock) u.")
                            .font(.caption.bold())
                            .padding(6)
                            .background(colorStock(producto.stock).opacity(0.15), in: Capsule())
                            .foregroundStyle(colorStock(producto.stock))
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if usuario.esSupervisor { abrir(producto) }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if usuario.esSupervisor {
                            Button("Borrar", role: .destructive) { borrar(producto) }
                            Button("Editar") { abrir(producto) }.tint(.blue)
                            Button("Reponer") { productoParaReponer = producto }.tint(.green)
                        }
                    }
                }
            }
            .navigationTitle("Productos")
            .searchable(text: $busqueda, prompt: "Buscar producto")
            .toolbar {
                if usuario.esSupervisor {
                    Button("Nuevo producto", systemImage: "plus") { abrir(nil) }
                }
            }
            .sheet(isPresented: $editando) { EditorProducto(producto: seleccionado) }
            .sheet(item: $productoParaReponer) { ReponerStockView(producto: $0, usuario: usuario) }
            .onChange(of: categorias) { _, nuevas in
                if let categoria, !nuevas.contains(categoria) { self.categoria = nil }
            }
            .alertaVentas($error)
        }
    }

    private func filtro(_ titulo: String, valor: String?) -> some View {
        Button { categoria = valor } label: {
            Text(titulo)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(categoria == valor ? Color.blue : Color.secondary.opacity(0.12), in: Capsule())
                .foregroundStyle(categoria == valor ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }

    private func colorStock(_ stock: Int) -> Color {
        if stock <= 5 { return .red }
        if stock <= 10 { return .orange }
        return .green
    }

    private func abrir(_ producto: Producto?) {
        seleccionado = producto
        editando = true
    }

    private func borrar(_ producto: Producto) {
        guard producto.ventas.isEmpty else {
            error = "No se puede borrar un producto con ventas asociadas."
            return
        }
        contexto.delete(producto)
        do { try contexto.guardarCambios() }
        catch { self.error = "No se pudo borrar el producto." }
    }
}

struct ReponerStockView: View {
    @Environment(\.modelContext) private var contexto
    @Environment(\.dismiss) private var cerrar
    @State private var textoUnidades = ""
    @State private var error = ""
    @FocusState private var editandoUnidades: Bool
    let producto: Producto
    let usuario: Usuario

    private var stockResultante: Int? {
        guard let unidades = textoUnidades.unidadesPositivas else { return nil }
        let (total, desborda) = producto.stock.addingReportingOverflow(unidades)
        return desborda ? nil : total
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Producto") {
                    Text(producto.nombre).font(.headline)
                    LabeledContent("Stock actual", value: "\(producto.stock) u.")
                }
                Section("Ingreso de mercadería") {
                    TextField("Unidades recibidas", text: $textoUnidades)
                        .keyboardType(.numberPad)
                        .focused($editandoUnidades)
                    if let stockResultante {
                        LabeledContent("Stock después del ingreso", value: "\(stockResultante) u.")
                    } else if !textoUnidades.isEmpty {
                        Text("Ingresa un número entero positivo que no exceda el límite de stock.")
                            .foregroundStyle(.red)
                    }
                }
                Button("Confirmar ingreso", action: guardar)
                    .disabled(stockResultante == nil || !usuario.esSupervisor)
            }
            .navigationTitle("Reponer stock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") { editandoUnidades = false }
                }
            }
            .alertaVentas($error)
        }
    }

    private func guardar() {
        guard usuario.esSupervisor, let stockResultante else { return }
        editandoUnidades = false
        producto.stock = stockResultante
        do {
            try contexto.guardarCambios()
            cerrar()
        } catch {
            self.error = "No se pudo registrar el ingreso. El stock se conservó."
        }
    }
}

struct EditorProducto: View {
    @Environment(\.modelContext) private var contexto
    @Environment(\.dismiss) private var cerrar
    @State private var nombre: String
    @State private var categoria: String
    @State private var precio: String
    @State private var stock: String
    @State private var error = ""
    let producto: Producto?

    init(producto: Producto?) {
        self.producto = producto
        _nombre = State(initialValue: producto?.nombre ?? "")
        _categoria = State(initialValue: producto?.categoria ?? "")
        _precio = State(initialValue: producto.map { String($0.precio) } ?? "")
        _stock = State(initialValue: producto.map { String($0.stock) } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $nombre)
                TextField("Categoría", text: $categoria)
                TextField("Precio unitario (S/)", text: $precio).keyboardType(.decimalPad)
                TextField("Stock", text: $stock).keyboardType(.numberPad)
            }
            .navigationTitle(producto == nil ? "Nuevo producto" : "Editar producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } }
                ToolbarItem(placement: .confirmationAction) { Button("Guardar", action: guardar) }
            }
            .alertaVentas($error)
        }
    }

    private func guardar() {
        let textoPrecio = precio.recortado.replacingOccurrences(of: ",", with: ".")
        guard !nombre.recortado.isEmpty, !categoria.recortado.isEmpty,
              textoPrecio.range(of: #"^[0-9]+(\.[0-9]{1,2})?$"#, options: .regularExpression) != nil,
              let importe = Double(textoPrecio), importe > 0, importe <= 999_999_999.99,
              let unidades = Int(stock.recortado), unidades >= 0 else {
            error = "Indica nombre, categoría, un precio positivo de hasta dos decimales y un stock entero no negativo."
            return
        }
        if let producto {
            producto.nombre = nombre.recortado
            producto.categoria = categoria.recortado
            producto.precio = importe
            producto.stock = unidades
        } else {
            contexto.insert(Producto(nombre: nombre.recortado, categoria: categoria.recortado, precio: importe, stock: unidades))
        }
        do {
            try contexto.guardarCambios()
            cerrar()
        } catch {
            self.error = "No se pudo guardar el producto."
        }
    }
}

struct ClientesView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Cliente.nombre) private var clientes: [Cliente]
    @State private var busqueda = ""
    @State private var seleccionado: Cliente?
    @State private var editando = false
    @State private var error = ""
    let usuario: Usuario

    private var visibles: [Cliente] {
        clientes.filter {
            busqueda.recortado.isEmpty || $0.nombre.localizedCaseInsensitiveContains(busqueda.recortado)
                || $0.documento.localizedCaseInsensitiveContains(busqueda.recortado)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if visibles.isEmpty {
                    ContentUnavailableView("Sin clientes", systemImage: "person.2",
                                           description: Text("No hay clientes que coincidan."))
                }
                ForEach(visibles) { cliente in
                    Button {
                        abrir(cliente)
                    } label: {
                        HStack {
                            AvatarIniciales(nombre: cliente.nombre, color: colorCategoria(cliente.categoria))
                            VStack(alignment: .leading) {
                                Text(cliente.nombre).font(.headline).lineLimit(1)
                                Text("\(cliente.tipoIdentificacion?.rawValue ?? "Documento") · \(cliente.documento)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(cliente.totalComprado.soles)
                                Text("comprado").font(.caption2).foregroundStyle(.secondary)
                                Text(cliente.categoria.rawValue)
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .foregroundStyle(.white)
                                    .background(colorCategoria(cliente.categoria), in: Capsule())
                            }
                        }
                        .foregroundStyle(Color.primary)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if usuario.esSupervisor {
                            Button("Borrar", role: .destructive) { borrar(cliente) }
                        }
                    }
                }
            }
            .navigationTitle("Clientes")
            .searchable(text: $busqueda, prompt: "Buscar por nombre o documento")
            .toolbar {
                Button("Nuevo cliente", systemImage: "plus") { abrir(nil) }
            }
            .sheet(isPresented: $editando) { EditorCliente(cliente: seleccionado) }
            .alertaVentas($error)
        }
    }

    private func colorCategoria(_ categoria: CategoriaCliente) -> Color {
        switch categoria {
        case .vip: .purple
        case .frecuente: .blue
        case .regular: .gray
        }
    }

    private func abrir(_ cliente: Cliente?) {
        seleccionado = cliente
        editando = true
    }

    private func borrar(_ cliente: Cliente) {
        guard cliente.ventas.isEmpty else {
            error = "No se puede borrar un cliente con ventas asociadas."
            return
        }
        contexto.delete(cliente)
        do { try contexto.guardarCambios() }
        catch { self.error = "No se pudo borrar el cliente." }
    }
}

struct EditorCliente: View {
    @Environment(\.modelContext) private var contexto
    @Environment(\.dismiss) private var cerrar
    @Query(sort: \Cliente.nombre) private var clientes: [Cliente]
    @State private var nombre: String
    @State private var documento: String
    @State private var tipoDocumento: TipoDocumento
    @State private var error = ""
    let cliente: Cliente?
    let alGuardar: ((Cliente) -> Void)?

    init(cliente: Cliente?, documentoInicial: String = "", alGuardar: ((Cliente) -> Void)? = nil) {
        self.cliente = cliente
        self.alGuardar = alGuardar
        _nombre = State(initialValue: cliente?.nombre ?? "")
        _documento = State(initialValue: cliente?.documento ?? documentoInicial)
        _tipoDocumento = State(initialValue: cliente?.tipoIdentificacion ?? TipoDocumento.inferir(documentoInicial) ?? .dni)
    }

    private var existente: Cliente? {
        guard !documento.documentoNormalizado.isEmpty else { return nil }
        return clientes.first {
            $0.documento.documentoNormalizado == documento.documentoNormalizado
                && ($0.tipoIdentificacion == tipoDocumento || $0.tipoIdentificacion == nil)
                && $0.persistentModelID != cliente?.persistentModelID
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(tipoDocumento == .ruc ? "Nombre o razón social" : "Apellidos y nombres", text: $nombre)
                Picker("Tipo de documento", selection: $tipoDocumento) {
                    ForEach(TipoDocumento.allCases) { Text($0.rawValue).tag($0) }
                }
                TextField("Número de documento", text: $documento)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                Text(tipoDocumento.indicacion).font(.caption).foregroundStyle(.secondary)
                if let cliente, !cliente.identificacionCompleta {
                    Text("Revisa la identificación de este cliente antes de registrar nuevas ventas.")
                        .foregroundStyle(.orange)
                }
                if let existente {
                    Text("El documento ya pertenece a \(existente.nombre).")
                        .foregroundStyle(.orange)
                    if cliente == nil, let alGuardar {
                        Button("Usar cliente existente") {
                            alGuardar(existente)
                            cerrar()
                        }
                    }
                }
            }
            .navigationTitle(cliente == nil ? "Nuevo cliente" : "Editar cliente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } }
                ToolbarItem(placement: .confirmationAction) { Button("Guardar", action: guardar) }
            }
            .alertaVentas($error)
        }
    }

    private func guardar() {
        guard !nombre.recortado.isEmpty, !documento.recortado.isEmpty else {
            error = "Completa el nombre y el documento."
            return
        }
        guard tipoDocumento.admite(documento) else {
            error = tipoDocumento.indicacion
            return
        }
        do {
            // Consultar también al guardar evita duplicados aunque la lista visual aún no se actualice.
            let registrados = try contexto.fetch(FetchDescriptor<Cliente>())
            guard !registrados.contains(where: {
                $0.documento.documentoNormalizado == documento.documentoNormalizado
                    && ($0.tipoIdentificacion == tipoDocumento || $0.tipoIdentificacion == nil)
                    && $0.persistentModelID != cliente?.persistentModelID
            }) else {
                error = "Ya existe un cliente con ese documento. Busca su registro para conservar su historial."
                return
            }
            let guardado: Cliente
            if let cliente {
                cliente.nombre = nombre.recortado
                cliente.documento = documento.documentoNormalizado
                cliente.tipoDocumento = tipoDocumento.rawValue
                guardado = cliente
            } else {
                guardado = Cliente(nombre: nombre.recortado, documento: documento.documentoNormalizado,
                                   tipoDocumento: tipoDocumento)
                contexto.insert(guardado)
            }
            try contexto.guardarCambios()
            alGuardar?(guardado)
            cerrar()
        } catch {
            self.error = "No se pudo guardar el cliente."
        }
    }
}
