import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var sesion: Usuario?

    var body: some View {
        if let usuario = sesion {
            TabView {
                ProductosView(usuario: usuario)
                    .tabItem { Label("Productos", systemImage: "shippingbox") }
                ClientesView(usuario: usuario)
                    .tabItem { Label("Clientes", systemImage: "person.2") }
                if !usuario.esSupervisor {
                    NuevaVentaView(usuario: usuario)
                        .tabItem { Label("Venta", systemImage: "cart.badge.plus") }
                    HistorialView(usuario: usuario)
                        .tabItem { Label("Mis ventas", systemImage: "list.bullet.clipboard") }
                }
                NavigationStack {
                    Form {
                        LabeledContent("Nombre", value: usuario.nombre)
                        LabeledContent("Usuario", value: usuario.usuario)
                        LabeledContent("Rol", value: usuario.rol)
                        Button("Cerrar sesión", role: .destructive) { sesion = nil }
                    }
                    .navigationTitle("Cuenta")
                }
                .tabItem { Label("Cuenta", systemImage: "person.crop.circle") }
            }
            .id(usuario.persistentModelID)
        } else {
            AccesoView { sesion = $0 }
        }
    }
}

private struct AccesoView: View {
    @Environment(\.modelContext) private var contexto
    @State private var usuario = ""
    @State private var clave = ""
    @State private var error = ""
    let ingresar: (Usuario) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "cart.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .padding(18)
                            .background(.blue, in: RoundedRectangle(cornerRadius: 18))
                        Text("Ventas Tecsup").font(.title.bold())
                        Text("Inicia sesión para continuar").foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .listRowBackground(Color.clear)
                }
                Section {
                    TextField("Usuario", text: $usuario)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Clave", text: $clave)
                        .onSubmit(validar)
                }
                if !error.isEmpty { Text(error).foregroundStyle(.red) }
                Button("Ingresar", action: validar)
                    .frame(maxWidth: .infinity)
                NavigationLink("Crear cuenta") { RegistroView(ingresar: ingresar) }
            }
        }
    }

    private func validar() {
        let identificador = usuario.recortado.lowercased()
        let consulta = FetchDescriptor<Usuario>(predicate: #Predicate { $0.usuario == identificador })
        do {
            guard let cuenta = try contexto.fetch(consulta).first, cuenta.clave == clave else {
                error = "Usuario o clave incorrectos"
                return
            }
            ingresar(cuenta)
        } catch {
            self.error = "No se pudo consultar la cuenta."
        }
    }
}

private struct RegistroView: View {
    @Environment(\.modelContext) private var contexto
    @State private var nombre = ""
    @State private var usuario = ""
    @State private var clave = ""
    @State private var confirmacion = ""
    @State private var rol = Rol.vendedor
    @State private var error = ""
    let ingresar: (Usuario) -> Void

    var body: some View {
        Form {
            Section("Datos de la cuenta") {
                TextField("Nombre completo", text: $nombre)
                TextField("Usuario", text: $usuario)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Clave (mínimo 6 caracteres)", text: $clave)
                SecureField("Confirmar clave", text: $confirmacion)
            }
            Section("Tu rol") {
                Picker("Rol", selection: $rol) {
                    ForEach(Rol.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            if !error.isEmpty { Text(error).foregroundStyle(.red) }
            Button("Registrarme", action: registrar)
                .frame(maxWidth: .infinity)
        }
        .navigationTitle("Crear cuenta")
    }

    private func registrar() {
        let identificador = usuario.recortado.lowercased()
        guard !nombre.recortado.isEmpty, !identificador.isEmpty else {
            error = "Completa tu nombre y usuario."
            return
        }
        guard clave.count >= 6, clave == confirmacion else {
            error = "La clave debe tener al menos seis caracteres y coincidir con su confirmación."
            return
        }
        let consulta = FetchDescriptor<Usuario>(predicate: #Predicate { $0.usuario == identificador })
        do {
            guard try contexto.fetchCount(consulta) == 0 else {
                error = "Ese usuario ya existe."
                return
            }
            let cuenta = Usuario(nombre: nombre.recortado, usuario: identificador, clave: clave, rol: rol)
            contexto.insert(cuenta)
            try contexto.guardarCambios()
            ingresar(cuenta)
        } catch {
            self.error = "No se pudo crear la cuenta."
        }
    }
}

extension View {
    func alertaVentas(_ mensaje: Binding<String>) -> some View {
        alert("Ventas", isPresented: Binding(
            get: { !mensaje.wrappedValue.isEmpty },
            set: { if !$0 { mensaje.wrappedValue = "" } }
        )) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(mensaje.wrappedValue)
        }
    }
}
