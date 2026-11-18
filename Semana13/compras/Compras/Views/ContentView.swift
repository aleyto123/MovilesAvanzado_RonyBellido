import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var sesion: Usuario?

    var body: some View {
        if let usuario = sesion {
            InicioCompras(usuario: usuario) { sesion = nil }
                .id(usuario.persistentModelID)
        } else {
            AccesoView { sesion = $0 }
        }
    }
}

private enum Pestana: String, Identifiable {
    case resumen = "Resumen"
    case aprobar = "Aprobar"
    case porPagar = "Por pagar"
    case productos = "Productos"
    case proveedores = "Proveedores"
    case compra = "Compra"
    case misCompras = "Mis compras"

    var id: Self { self }

    var icono: String {
        switch self {
        case .resumen: "chart.bar.fill"
        case .aprobar: "checkmark.seal.fill"
        case .porPagar: "creditcard.fill"
        case .productos: "shippingbox.fill"
        case .proveedores: "building.2.fill"
        case .compra: "cart.fill.badge.plus"
        case .misCompras: "list.clipboard.fill"
        }
    }
}

struct InicioCompras: View {
    let usuario: Usuario
    let cerrarSesion: () -> Void
    @State private var seleccion: Pestana
    @State private var tecladoVisible = false

    init(usuario: Usuario, cerrarSesion: @escaping () -> Void) {
        self.usuario = usuario
        self.cerrarSesion = cerrarSesion
        let inicial: Pestana = usuario.esSupervisor ? .resumen : .productos
        _seleccion = State(initialValue: inicial)
    }

    private var pestanas: [Pestana] {
        usuario.esSupervisor ? [.resumen, .aprobar, .porPagar, .productos, .proveedores]
            : [.productos, .proveedores, .compra, .misCompras]
    }

    var body: some View {
        TabView(selection: $seleccion) {
            ForEach(pestanas) { pestana in
                pantalla(pestana)
                    .tabItem { Label(pestana.rawValue, systemImage: pestana.icono) }
                    .toolbar(.hidden, for: .tabBar)
                    .tag(pestana)
            }
        }
        .background(Color.fondoCompras)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !tecladoVisible { barra }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            tecladoVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            tecladoVisible = false
        }
    }

    @ViewBuilder
    private func pantalla(_ pestana: Pestana) -> some View {
        switch pestana {
        case .resumen: ResumenView(usuario: usuario, cerrarSesion: cerrarSesion)
        case .aprobar: AprobacionesView(usuario: usuario, cerrarSesion: cerrarSesion)
        case .porPagar: PorPagarView(usuario: usuario, cerrarSesion: cerrarSesion)
        case .productos: ProductosView(usuario: usuario, cerrarSesion: cerrarSesion)
        case .proveedores: ProveedoresView(usuario: usuario, cerrarSesion: cerrarSesion)
        case .compra: NuevaCompraView(usuario: usuario, cerrarSesion: cerrarSesion)
        case .misCompras: MisComprasView(usuario: usuario, cerrarSesion: cerrarSesion)
        }
    }

    private var barra: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.bordeCompras).frame(height: 1)
            HStack(spacing: 2) {
                ForEach(pestanas) { pestana in
                    let activa = seleccion == pestana
                    Button {
                        seleccion = pestana
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: pestana.icono)
                                .font(.system(size: 15, weight: .medium))
                                .frame(width: 40, height: 25)
                                .background(activa ? Color.accentColor.opacity(0.13) : .clear, in: Capsule())
                            Text(pestana.rawValue)
                                .font(.caption2.weight(activa ? .bold : .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .foregroundStyle(activa ? Color.accentColor : Color.secondary)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(activa ? .isSelected : [])
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
        }
        .background(Color.fondoTarjeta.ignoresSafeArea(edges: .bottom))
    }
}

private struct AccesoView: View {
    @Environment(\.modelContext) private var contexto
    @State private var vm = AccesoViewModel()
    let ingresar: (Usuario) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    portada
                        .padding(.vertical, 10)

                    CampoCuenta(titulo: "Usuario") {
                        TextField("Ingresa tu usuario", text: $vm.usuario)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    CampoCuenta(titulo: "Clave") {
                        SecureField("Ingresa tu clave", text: $vm.clave)
                            .textContentType(.password)
                            .onSubmit(validar)
                    }
                    if !vm.error.isEmpty { ErrorCuenta(texto: vm.error) }
                    Button("Ingresar", action: validar)
                        .buttonStyle(BotonCompras())
                    HStack(spacing: 4) {
                        Text("¿Primera vez?").foregroundStyle(.secondary)
                        NavigationLink("Crear cuenta") { RegistroView(ingresar: ingresar) }
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.fondoCompras)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func validar() {
        if let cuenta = vm.validar(en: ComprasStore(contexto: contexto)) { ingresar(cuenta) }
    }

    private var portada: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: "shippingbox.and.arrow.backward.fill")
                .font(.system(size: 27, weight: .medium))
                .frame(width: 54, height: 54)
                .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.23))
                }
                .accessibilityHidden(true)
                .padding(.bottom, 18)
            Text("Compras Tecsup")
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)
            Text("Inicia sesión para continuar")
                .font(.subheadline)
                .foregroundStyle(Color.mentaCompras)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(23)
        .panelAlmacen()
    }

}

struct RegistroView: View {
    @Environment(\.dismiss) private var volver
    @Environment(\.modelContext) private var contexto
    @State private var vm = RegistroViewModel()
    let ingresar: (Usuario) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                CampoCuenta(titulo: "Nombre completo") {
                    TextField("Nombres y apellidos", text: $vm.nombre).textContentType(.name)
                }
                CampoCuenta(titulo: "Usuario") {
                    HStack {
                        TextField("Elige tu usuario", text: $vm.usuario)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        if let disponible = vm.disponible {
                            Label(disponible ? "Disponible" : "Ya existe", systemImage: disponible ? "checkmark" : "xmark")
                                .font(.caption)
                                .foregroundStyle(disponible ? .green : .red)
                        }
                    }
                }
                CampoCuenta(titulo: "Clave (mínimo 6 caracteres)") {
                    SecureField("Ingresa tu clave", text: $vm.clave)
                }
                CampoCuenta(titulo: "Confirmar clave") {
                    SecureField("Repite tu clave", text: $vm.confirmacion)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("TU ROL").font(.caption).foregroundStyle(.secondary)
                    Picker("Rol", selection: $vm.rol) {
                        ForEach(Rol.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                if !vm.error.isEmpty { ErrorCuenta(texto: vm.error) }
                Button("Registrarme", action: registrar)
                    .buttonStyle(BotonCompras())
                Text("Al registrarte entrarás directamente a la app con las pestañas de tu rol.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.fondoCompras)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .top, spacing: 0) {
            ZStack(alignment: .leading) {
                Text("Crear cuenta").font(.headline).frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)
                Button { volver() } label: {
                    Label("Ingresar", systemImage: "chevron.left")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 18)
            .frame(minHeight: 38)
            .background(Color.fondoCompras)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: vm.usuario) { _, _ in vm.comprobarDisponibilidad(en: ComprasStore(contexto: contexto)) }
    }

    private func registrar() {
        if let cuenta = vm.registrar(en: ComprasStore(contexto: contexto)) { ingresar(cuenta) }
    }
}

private struct CampoCuenta<Campo: View>: View {
    let titulo: String
    @ViewBuilder let campo: () -> Campo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titulo.uppercased())
                .font(.system(.caption2, design: .monospaced, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            campo().accessibilityLabel(titulo)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .tarjetaCompras()
    }
}

private struct ErrorCuenta: View {
    let texto: String

    var body: some View {
        Label(texto, systemImage: "exclamationmark.triangle.fill")
            .font(.footnote)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AvatarIniciales: View {
    let nombre: String
    var color: Color? = nil
    var circular = false
    @ScaledMetric(relativeTo: .body) private var lado: CGFloat = 37

    private var fondo: Color {
        let colores: [Color] = [
            .pinoCompras, Color(red: 0.27, green: 0.33, blue: 0.44),
            Color(red: 0.39, green: 0.27, blue: 0.35), Color(red: 0.33, green: 0.37, blue: 0.23)
        ]
        let indice = nombre.unicodeScalars.reduce(0) { ($0 + Int($1.value)) % colores.count }
        return color ?? colores[indice]
    }

    var body: some View {
        Text(nombre.iniciales)
            .font(.system(.caption, design: .monospaced, weight: .bold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(.white)
            .frame(width: lado, height: lado)
            .background(fondo, in: RoundedRectangle(cornerRadius: circular ? lado / 2 : 10))
            .accessibilityHidden(true)
    }
}

struct BotonCompras: ButtonStyle {
    @Environment(\.isEnabled) private var habilitado
    var contorno = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundStyle(contorno ? Color.rechazoCompras : Color.white)
            .background(contorno ? Color.rechazoCompras.opacity(0.07) : Color.pinoCompras,
                        in: RoundedRectangle(cornerRadius: 13))
            .overlay {
                if contorno { RoundedRectangle(cornerRadius: 13).strokeBorder(Color.rechazoCompras.opacity(0.32)) }
            }
            .opacity(habilitado ? (configuration.isPressed ? 0.75 : 1) : 0.55)
    }
}

extension Color {
    static var pinoCompras: Color { Color(red: 0.06, green: 0.28, blue: 0.23) }
    static var mentaCompras: Color { Color(red: 0.68, green: 0.88, blue: 0.76) }
    static var fondoCompras: Color { paletaCompras((0.95, 0.95, 0.92), (0.07, 0.10, 0.09)) }
    static var fondoTarjeta: Color { paletaCompras((1, 0.995, 0.975), (0.11, 0.15, 0.14)) }
    static var bordeCompras: Color { paletaCompras((0.87, 0.89, 0.84), (0.23, 0.29, 0.26)) }
    static var pendienteCompras: Color { paletaCompras((0.52, 0.29, 0.08), (0.99, 0.70, 0.41)) }
    static var rechazoCompras: Color { paletaCompras((0.60, 0.19, 0.16), (0.98, 0.58, 0.53)) }

    private static func paletaCompras(_ claro: (CGFloat, CGFloat, CGFloat),
                                      _ oscuro: (CGFloat, CGFloat, CGFloat)) -> Color {
        Color(uiColor: UIColor { rasgos in
            let (r, g, b) = rasgos.userInterfaceStyle == .dark ? oscuro : claro
            return UIColor(red: r, green: g, blue: b, alpha: 1)
        })
    }
}

private struct LineasAlmacen: View {
    var body: some View {
        Canvas { contexto, tamano in
            let lado = min(tamano.width * 0.42, tamano.height * 0.92)
            let origen = CGPoint(x: tamano.width - lado * 0.19, y: tamano.height * 0.42)
            let tonos: [(CGFloat, Double)] = [(1, 0.28), (1.28, 0.19), (1.56, 0.11)]
            for (escala, opacidad) in tonos {
                let radio = lado * escala * 0.50
                let alto = radio * 0.55
                let superior = CGPoint(x: origen.x, y: origen.y - alto)
                let izquierda = CGPoint(x: origen.x - radio, y: origen.y)
                let derecha = CGPoint(x: origen.x + radio, y: origen.y)
                let frente = CGPoint(x: origen.x, y: origen.y + alto)
                let inferior = CGPoint(x: frente.x, y: frente.y + radio)
                let trazo = Path { ruta in
                    ruta.move(to: superior)
                    ruta.addLines([derecha, frente, izquierda, superior])
                    ruta.move(to: izquierda)
                    ruta.addLines([CGPoint(x: izquierda.x, y: izquierda.y + radio), inferior,
                                   CGPoint(x: derecha.x, y: derecha.y + radio), derecha])
                    ruta.move(to: frente)
                    ruta.addLine(to: inferior)
                }
                contexto.stroke(trazo, with: .color(.mentaCompras.opacity(opacidad)), lineWidth: 1)
            }
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

extension View {
    func tarjetaCompras() -> some View {
        background(Color.fondoTarjeta, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.bordeCompras, lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }

    func panelAlmacen() -> some View {
        background {
            ZStack {
                Color.pinoCompras
                LineasAlmacen()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    func encabezadoCompras(_ titulo: String, usuario: Usuario, cerrarSesion: @escaping () -> Void) -> some View {
        encabezadoCompras(titulo, usuario: usuario, cerrarSesion: cerrarSesion) { EmptyView() }
    }

    func encabezadoCompras<Acciones: View>(_ titulo: String, usuario: Usuario, cerrarSesion: @escaping () -> Void,
                                           @ViewBuilder acciones: () -> Acciones) -> some View {
        let botones = acciones()
        return safeAreaInset(edge: .top, spacing: 0) {
            HStack(spacing: 10) {
                Text(titulo)
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .minimumScaleFactor(0.68)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                botones
                Menu {
                    Section {
                        Text(usuario.nombre)
                        Text(usuario.rol)
                    }
                    Button("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right",
                           role: .destructive, action: cerrarSesion)
                } label: {
                    AvatarIniciales(nombre: usuario.nombre, color: .pinoCompras, circular: true)
                        .padding(4)
                        .overlay { Circle().strokeBorder(Color.bordeCompras) }
                }
                .accessibilityLabel("Cuenta")
            }
            .padding(.horizontal, 17)
            .padding(.top, 6)
            .padding(.bottom, 9)
            .background(Color.fondoCompras)
        }
    }

    func listaCompras() -> some View {
        listStyle(.insetGrouped)
            .listSectionSpacing(12)
            .contentMargins(.top, 5, for: .scrollContent)
            .contentMargins(.bottom, 12, for: .scrollContent)
            .scrollContentBackground(.hidden)
            .background(Color.fondoCompras)
    }

    func alertaCompras(_ mensaje: Binding<String>) -> some View {
        alert("Compras", isPresented: Binding(
            get: { !mensaje.wrappedValue.isEmpty },
            set: { if !$0 { mensaje.wrappedValue = "" } }
        )) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(mensaje.wrappedValue)
        }
    }
}

#Preview("Inicio de sesión") {
    ContentView()
        .modelContainer(for: [Usuario.self, Proveedor.self, Producto.self, Compra.self], inMemory: true)
}
