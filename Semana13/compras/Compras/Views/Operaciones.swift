import SwiftUI
import SwiftData

struct MisComprasView: View {
    @Query(sort: \Compra.fecha, order: .reverse) private var compras: [Compra]
    @State private var filtro: EstadoCompra?
    let usuario: Usuario
    let cerrarSesion: () -> Void

    private var visibles: [Compra] {
        compras.filter {
            $0.comprador?.persistentModelID == usuario.persistentModelID
                && (filtro == nil || $0.estado == filtro?.rawValue)
        }
    }

    var body: some View {
        List {
            Section {
                if visibles.isEmpty {
                    ContentUnavailableView("Sin compras", systemImage: "cart")
                }
                ForEach(visibles) { FilaCompra(compra: $0).listRowBackground(Color.fondoTarjeta) }
            } footer: {
                Text("Aquí solo aparecen las compras que registraste.")
            }
        }
        .listaCompras()
        .safeAreaInset(edge: .top, spacing: 0) {
            Picker("Estado", selection: $filtro) {
                Text("Todas").tag(nil as EstadoCompra?)
                Text("Pendientes").tag(Optional(EstadoCompra.pendiente))
                Text("Rechazadas").tag(Optional(EstadoCompra.rechazada))
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background(Color.fondoCompras)
        }
        .encabezadoCompras("Mis compras", usuario: usuario, cerrarSesion: cerrarSesion)
    }
}

struct AprobacionesView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Compra.fecha, order: .reverse) private var compras: [Compra]
    @State private var viendoHistorial = false
    @State private var porRechazar: Compra?
    @State private var vm = SupervisionViewModel()
    let usuario: Usuario
    let cerrarSesion: () -> Void

    private var pendientes: [Compra] { compras.filter { $0.estado == EstadoCompra.pendiente.rawValue } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if pendientes.isEmpty {
                    ContentUnavailableView("Sin compras pendientes", systemImage: "checkmark.seal")
                        .tarjetaCompras()
                }
                ForEach(pendientes) { compra in
                    tarjeta(compra)
                }
                if !pendientes.isEmpty {
                    Text("Al rechazar se pide un motivo. El comprador lo verá en «Mis compras».")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 3)
                }
                Button("Ver todas las compras", systemImage: "list.bullet") { viendoHistorial = true }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
        }
        .background(Color.fondoCompras)
        .encabezadoCompras("Aprobar", usuario: usuario, cerrarSesion: cerrarSesion)
        .sheet(item: $porRechazar) { RechazoView(compra: $0, usuario: usuario) }
        .sheet(isPresented: $viendoHistorial) {
            NavigationStack {
                List {
                    if compras.isEmpty { ContentUnavailableView("Sin compras", systemImage: "cart") }
                    ForEach(compras) { FilaCompra(compra: $0, mostrarComprador: true) }
                }
                .listaCompras()
                .navigationTitle("Todas las compras")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Cerrar") { viendoHistorial = false }
                    }
                }
            }
        }
        .alertaCompras($vm.mensaje)
    }

    private func tarjeta(_ compra: Compra) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(compra.proveedor?.nombre ?? "Proveedor") · \(compra.producto?.nombre ?? "Producto")")
                        .font(.subheadline.bold())
                    Text("Solicitó: \(compra.comprador?.nombre ?? "Comprador") · \(compra.fecha.diaYMes)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Insignia(texto: "Pendiente", color: .pendienteCompras)
            }

            HStack(alignment: .firstTextBaseline) {
                Text(compra.total.soles)
                    .font(.system(.title, design: .serif, weight: .bold))
                    .monospacedDigit()
                Spacer()
                Text(compra.alCredito ? "Crédito · vence \(compra.vence.diaYMes)" : "Contado")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text("\(compra.cantidad) u. × \(compra.costoUnitario.soles) · IGV \(compra.igv.soles)")
                .font(.footnote)
                .monospacedDigit()
                .foregroundStyle(.secondary)

            if let producto = compra.producto, let efecto = compra.efectoEnInventario {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Cambios al aprobar", systemImage: "arrow.up.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                    LabeledContent("Stock", value: "\(producto.stock) → \(efecto.stock)")
                    LabeledContent("Costo promedio", value: "\(producto.costoPromedio.soles) → \(efecto.costoPromedio.soles)")
                }
                .font(.footnote)
                .monospacedDigit()
                .padding(11)
                .background(Color.accentColor.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 10) {
                Button("Rechazar") { porRechazar = compra }
                    .buttonStyle(BotonCompras(contorno: true))
                Button("Aprobar") { vm.aprobar(compra, por: usuario, en: ComprasStore(contexto: contexto)) }
                    .buttonStyle(BotonCompras())
                    .disabled(compra.efectoEnInventario == nil)
            }
        }
        .padding(16)
        .tarjetaCompras()
    }

}

private struct RechazoView: View {
    @Environment(\.dismiss) private var cerrar
    @Environment(\.modelContext) private var contexto
    @State private var motivo = ""
    @State private var vm = SupervisionViewModel()
    let compra: Compra
    let usuario: Usuario

    var body: some View {
        NavigationStack {
            Form {
                FilaCompra(compra: compra, mostrarComprador: true)
                TextField("Motivo del rechazo", text: $motivo, axis: .vertical)
            }
            .navigationTitle("Rechazar compra")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { cerrar() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Rechazar", role: .destructive, action: rechazar)
                        .disabled(motivo.recortado.isEmpty)
                }
            }
            .alertaCompras($vm.mensaje)
        }
    }

    private func rechazar() {
        if vm.rechazar(compra, por: usuario, motivo: motivo, en: ComprasStore(contexto: contexto)) { cerrar() }
    }
}

private enum FiltroPago: String, CaseIterable, Identifiable {
    case pendientes = "Pendientes"
    case vencidas = "Vencidas"
    case pagadas = "Pagadas"

    var id: Self { self }
}

struct PorPagarView: View {
    @State private var filtro = FiltroPago.pendientes
    @State private var busqueda = ""
    @State private var buscando = false
    let usuario: Usuario
    let cerrarSesion: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { tiempo in
            ListaPagos(filtro: $filtro, fecha: tiempo.date, busqueda: busqueda, usuario: usuario)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if buscando { BuscadorCompras(texto: $busqueda, marcador: "Buscar proveedor") }
        }
        .encabezadoCompras("Por pagar", usuario: usuario, cerrarSesion: cerrarSesion) {
            Button("Buscar proveedor", systemImage: buscando ? "xmark" : "magnifyingglass") {
                buscando.toggle()
                if !buscando { busqueda = "" }
            }
            .labelStyle(.iconOnly)
        }
    }
}

private struct ListaPagos: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Compra.vence) private var compras: [Compra]
    @Query private var impagas: [Compra]
    @State private var porPagar: Compra?
    @State private var vm = SupervisionViewModel()
    let fecha: Date
    let busqueda: String
    let usuario: Usuario
    @Binding var filtro: FiltroPago

    init(filtro: Binding<FiltroPago>, fecha: Date, busqueda: String, usuario: Usuario) {
        self.fecha = fecha
        self.busqueda = busqueda
        self.usuario = usuario
        _filtro = filtro

        let aprobada = EstadoCompra.aprobada.rawValue
        let sinPagar = #Predicate<Compra> { $0.estado == aprobada && $0.alCredito && !$0.pagada }
        _impagas = Query(filter: sinPagar)
        let predicado: Predicate<Compra>
        switch filtro.wrappedValue {
        case .pendientes:
            predicado = sinPagar
        case .vencidas:
            predicado = #Predicate { $0.estado == aprobada && $0.alCredito && !$0.pagada && $0.vence < fecha }
        case .pagadas:
            predicado = #Predicate { $0.estado == aprobada && $0.alCredito && $0.pagada }
        }
        _compras = Query(filter: predicado, sort: \Compra.vence)
    }

    private var visibles: [Compra] {
        let texto = busqueda.recortado
        return compras.filter {
            texto.isEmpty || $0.proveedor?.nombre.localizedStandardContains(texto) == true
                || $0.proveedor?.ruc.contains(texto) == true
        }
    }

    var body: some View {
        List {
            Section {
                if visibles.isEmpty {
                    ContentUnavailableView("Sin créditos", systemImage: "creditcard")
                }
                ForEach(visibles) { compra in
                    fila(compra)
                        .listRowBackground(Color.fondoTarjeta)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if compra.porPagar && usuario.esSupervisor {
                                Button("Pagar", systemImage: "checkmark") { porPagar = compra }
                                    .tint(.green)
                            }
                        }
                }
            }
            Section {
                VStack(alignment: .leading, spacing: 3) {
                    Label("Total por pagar", systemImage: "creditcard")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                    Text(impagas.reduce(Decimal.zero) { $0 + Decimal($1.total) }.soles)
                        .font(.system(.title2, design: .serif, weight: .bold))
                        .monospacedDigit()
                }
                .padding(.vertical, 4)
            } footer: {
                Text("Solo cuentan las compras aprobadas a crédito que siguen sin pagar.")
            }
        }
        .listaCompras()
        .safeAreaInset(edge: .top, spacing: 0) {
            Picker("Pago", selection: $filtro) {
                ForEach(FiltroPago.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background(Color.fondoCompras)
        }
        .alert("Marcar compra como pagada", isPresented: Binding(
            get: { porPagar != nil },
            set: { if !$0 { porPagar = nil } }
        ), presenting: porPagar) { compra in
            Button("Cancelar", role: .cancel) {}
            Button("Pagar") { vm.pagar(compra, por: usuario, en: ComprasStore(contexto: contexto)) }
        } message: { compra in
            Text("\(compra.proveedor?.nombre ?? "Proveedor") · \(compra.total.soles)")
        }
        .alertaCompras($vm.mensaje)
    }

    private func fila(_ compra: Compra) -> some View {
        HStack {
            AvatarIniciales(nombre: compra.proveedor?.nombre ?? "")
            VStack(alignment: .leading) {
                Text(compra.proveedor?.nombre ?? "Proveedor").font(.headline)
                Text("\(compra.producto?.nombre ?? "Producto") × \(compra.cantidad) · vence \(compra.vence.diaYMes)")
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
            Spacer()
            VStack(alignment: .trailing) {
                Text(compra.total.soles).font(.subheadline.bold()).monospacedDigit()
                if compra.pagada {
                    Insignia(texto: "Pagada", color: .accentColor)
                } else if compra.vence < fecha {
                    Insignia(texto: "Vencida", color: .rechazoCompras)
                }
            }
        }
    }

}

private struct FilaCompra: View {
    let compra: Compra
    var mostrarComprador = false

    private var colorEstado: Color {
        switch EstadoCompra(rawValue: compra.estado) {
        case .aprobada: .accentColor
        case .rechazada: .rechazoCompras
        default: .pendienteCompras
        }
    }

    private var icono: String {
        switch EstadoCompra(rawValue: compra.estado) {
        case .aprobada: "checkmark"
        case .rechazada: "xmark"
        default: "hourglass"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icono)
                .font(.subheadline.bold())
                .foregroundStyle(colorEstado)
                .frame(width: 36, height: 36)
                .background(colorEstado.opacity(0.11), in: RoundedRectangle(cornerRadius: 9))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(compra.proveedor?.nombre ?? "Proveedor").font(.subheadline.bold())
                Text("\(compra.producto?.nombre ?? "Producto") × \(compra.cantidad) · \(compra.fecha.diaYMes)")
                    .font(.caption).foregroundStyle(.secondary)
                if mostrarComprador {
                    Text("Solicitó \(compra.comprador?.nombre ?? "Comprador")")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if let motivo = compra.motivoRechazo {
                    Text("Motivo: \(motivo)").font(.caption).foregroundStyle(.red)
                }
            }
            Spacer(minLength: 0)
            Text(compra.total.soles).font(.subheadline.bold()).monospacedDigit().lineLimit(1).minimumScaleFactor(0.7)
            Insignia(texto: compra.estado, color: colorEstado)
        }
        .padding(.vertical, 3)
    }
}

private extension Date {
    var diaYMes: String {
        formatted(.dateTime.day(.twoDigits).month(.twoDigits).locale(Locale(identifier: "es_PE")))
    }
}
