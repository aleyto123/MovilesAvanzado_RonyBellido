import SwiftUI
import SwiftData

struct ProductosView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Producto.nombre) private var productos: [Producto]
    @State private var busqueda = ""
    @State private var categoria: String?
    @State private var seleccionado: Producto?
    @State private var editando = false
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
