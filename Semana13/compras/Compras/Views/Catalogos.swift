import SwiftUI
import SwiftData

struct ProductosView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Producto.nombre) private var productos: [Producto]
    @State private var seleccionado: Producto?
    @State private var creando = false
    @State private var vm = CatalogoViewModel()
    let usuario: Usuario
    let cerrarSesion: () -> Void

    private var visibles: [Producto] { vm.filtrar(productos) }

    var body: some View {
        List {
            Section {
                if visibles.isEmpty {
                    ContentUnavailableView("Sin productos", systemImage: "shippingbox",
                                           description: Text("No hay productos que coincidan."))
                }
                ForEach(visibles) { producto in
                    if usuario.esSupervisor {
                        Button { seleccionado = producto } label: { fila(producto) }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.fondoTarjeta)
                    } else {
                        fila(producto).listRowBackground(Color.fondoTarjeta)
                    }
                }
                .onDelete(perform: usuario.esSupervisor ? borrar : nil)
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Valor del inventario", systemImage: "shippingbox")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                    Text(productos.reduce(Decimal.zero) { $0 + $1.valorInventario }.soles)
                        .font(.system(.title2, design: .serif, weight: .bold))
                        .monospacedDigit()
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.fondoTarjeta)
            } footer: {
                if usuario.esSupervisor {
                    Text("Desliza para borrar. Los productos con compras asociadas se conservan.")
                }
            }
        }
        .listaCompras()
        .safeAreaInset(edge: .top, spacing: 0) {
            BuscadorCompras(texto: $vm.busqueda, marcador: "Buscar")
        }
        .encabezadoCompras("Productos", usuario: usuario, cerrarSesion: cerrarSesion) {
            if usuario.esSupervisor {
                Button("Nuevo producto", systemImage: "plus") { creando = true }
                    .labelStyle(.iconOnly)
                    .font(.title3.weight(.semibold))
            }
        }
        .sheet(isPresented: $creando) { EditorProducto(producto: nil) }
        .sheet(item: $seleccionado) { EditorProducto(producto: $0) }
        .alertaCompras($vm.mensaje)
    }

    private func fila(_ producto: Producto) -> some View {
        HStack(spacing: 8) {
            AvatarIniciales(nombre: producto.nombre)
            VStack(alignment: .leading) {
                Text(producto.nombre).font(.subheadline.bold()).lineLimit(2)
                Text(producto.categoria).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(producto.costoPromedio.soles).font(.subheadline.bold()).monospacedDigit().lineLimit(1).minimumScaleFactor(0.75)
                Text("Costo prom.").font(.caption2).foregroundStyle(.secondary)
            }
            Insignia(texto: "\(producto.stock) u.", color: colorStock(producto.stock))
        }
    }

    private func colorStock(_ stock: Int) -> Color {
        if stock <= 5 { return .rechazoCompras }
        if stock <= 10 { return .pendienteCompras }
        return .accentColor
    }

    private func borrar(_ indices: IndexSet) {
        let filas = visibles
        vm.borrar(indices.map { filas[$0] }, por: usuario, en: ComprasStore(contexto: contexto))
    }
}

private struct EditorProducto: View {
    @Environment(\.dismiss) private var cerrar
    @Environment(\.modelContext) private var contexto
    @State private var vm: EditorProductoViewModel

    init(producto: Producto?) {
        _vm = State(initialValue: EditorProductoViewModel(producto: producto))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $vm.nombre)
                TextField("Categoría", text: $vm.categoria)
                TextField("Stock", text: $vm.stock).keyboardType(.numberPad)
                TextField("Costo promedio", text: $vm.costo).keyboardType(.decimalPad)
            }
            .navigationTitle(vm.producto == nil ? "Nuevo producto" : "Editar producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } }
                ToolbarItem(placement: .confirmationAction) { Button("Guardar", action: guardar) }
            }
            .alertaCompras($vm.mensaje)
        }
    }

    private func guardar() {
        if vm.guardar(en: ComprasStore(contexto: contexto)) { cerrar() }
    }
}

struct ProveedoresView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]
    @State private var buscando = false
    @State private var seleccionado: Proveedor?
    @State private var creando = false
    @State private var vm = CatalogoViewModel()
    let usuario: Usuario
    let cerrarSesion: () -> Void

    private var visibles: [Proveedor] { vm.filtrar(proveedores) }

    var body: some View {
        List {
            Section {
                if visibles.isEmpty {
                    ContentUnavailableView("Sin proveedores", systemImage: "building.2",
                                           description: Text("No hay proveedores que coincidan."))
                }
                ForEach(visibles) { proveedor in
                    if usuario.esSupervisor {
                        Button { seleccionado = proveedor } label: { fila(proveedor) }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.fondoTarjeta)
                    } else {
                        fila(proveedor).listRowBackground(Color.fondoTarjeta)
                    }
                }
                .onDelete(perform: usuario.esSupervisor ? borrar : nil)
            } footer: {
                Text("El total comprado y las compras por pagar se calculan con las compras aprobadas de cada proveedor.")
            }
        }
        .listaCompras()
        .safeAreaInset(edge: .top, spacing: 0) {
            if buscando { BuscadorCompras(texto: $vm.busqueda, marcador: "Nombre o RUC") }
        }
        .encabezadoCompras("Proveedores", usuario: usuario, cerrarSesion: cerrarSesion) {
            Button("Buscar proveedor", systemImage: buscando ? "xmark" : "magnifyingglass") {
                buscando.toggle()
                if !buscando { vm.busqueda = "" }
            }
            .labelStyle(.iconOnly)
            if usuario.esSupervisor {
                Button("Nuevo proveedor", systemImage: "plus") { creando = true }
                    .labelStyle(.iconOnly)
                    .font(.title3.weight(.semibold))
            }
        }
        .sheet(isPresented: $creando) { EditorProveedor(proveedor: nil) }
        .sheet(item: $seleccionado) { EditorProveedor(proveedor: $0) }
        .alertaCompras($vm.mensaje)
    }

    private func fila(_ proveedor: Proveedor) -> some View {
        let porPagar = proveedor.compras.filter(\.porPagar).count
        return HStack(spacing: 8) {
            AvatarIniciales(nombre: proveedor.nombre)
            VStack(alignment: .leading, spacing: 2) {
                Text(proveedor.nombre).font(.subheadline.bold()).lineLimit(2)
                Text("RUC …\(proveedor.ruc.suffix(4))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("RUC \(proveedor.ruc)")
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 2) {
                Text(proveedor.totalComprado.soles).font(.subheadline.bold()).monospacedDigit()
                    .lineLimit(1).minimumScaleFactor(0.75)
                Text("comprado").font(.caption2).foregroundStyle(.secondary)
            }
            Insignia(texto: porPagar == 0 ? "Al día" : "\(porPagar) por pagar",
                     color: porPagar == 0 ? .accentColor : .pendienteCompras)
        }
    }

    private func borrar(_ indices: IndexSet) {
        let filas = visibles
        vm.borrar(indices.map { filas[$0] }, por: usuario, en: ComprasStore(contexto: contexto))
    }
}

private struct EditorProveedor: View {
    @Environment(\.dismiss) private var cerrar
    @Environment(\.modelContext) private var contexto
    @State private var vm: EditorProveedorViewModel

    init(proveedor: Proveedor?) {
        _vm = State(initialValue: EditorProveedorViewModel(proveedor: proveedor))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Razón social", text: $vm.nombre)
                TextField("RUC", text: $vm.ruc).keyboardType(.numberPad)
            }
            .navigationTitle(vm.proveedor == nil ? "Nuevo proveedor" : "Editar proveedor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } }
                ToolbarItem(placement: .confirmationAction) { Button("Guardar", action: guardar) }
            }
            .alertaCompras($vm.mensaje)
        }
    }

    private func guardar() {
        if vm.guardar(en: ComprasStore(contexto: contexto)) { cerrar() }
    }
}

struct Insignia: View {
    let texto: String
    let color: Color

    var body: some View {
        Text(texto)
            .font(.caption2.bold())
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(color)
            .background(color.opacity(0.11), in: Capsule())
    }
}

struct BuscadorCompras: View {
    @Binding var texto: String
    let marcador: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField(marcador, text: $texto)
                .autocorrectionDisabled()
            if !texto.isEmpty {
                Button("Limpiar búsqueda", systemImage: "xmark.circle.fill") { texto = "" }
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
        .padding(.horizontal, 11)
        .frame(minHeight: 39)
        .background(Color.fondoTarjeta, in: RoundedRectangle(cornerRadius: 10))
        .overlay { RoundedRectangle(cornerRadius: 10).strokeBorder(Color.bordeCompras).allowsHitTesting(false) }
        .padding(.horizontal, 16)
        .padding(.bottom, 5)
        .background(Color.fondoCompras)
    }
}
