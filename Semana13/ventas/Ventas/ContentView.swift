import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var sesion: Usuario?

    var body: some View {
        NavigationStack {
            if let sesion {
                Form {
                    LabeledContent("Usuario", value: sesion.usuario)
                    LabeledContent("Rol", value: sesion.rol)
                    Button("Volver al registro") { self.sesion = nil }
                }
                .navigationTitle("Cuenta creada")
            } else {
                RegistroView { sesion = $0 }
            }
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
