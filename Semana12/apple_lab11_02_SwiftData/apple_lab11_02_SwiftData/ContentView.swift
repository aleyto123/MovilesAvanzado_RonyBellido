import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Carga la lista de alumnos ordenados por Apellido
    @Query(sort: \Alumno.apellido, order: .forward) private var alumnos: [Alumno]

    @State private var mostrarNuevoAlumno = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(alumnos) { alumno in
                    // Navegación hacia la vista de Detalle
                    NavigationLink(destination: DetalleAlumnoView(alumno: alumno)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(alumno.apellido), \(alumno.nombre)")
                                .font(.headline)
                            Text("DNI: \(alumno.dni)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: eliminarAlumno)
            }
            .navigationTitle("📋 Alumnos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { mostrarNuevoAlumno = true }) {
                            Image(systemName: "plus")
                        }
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $mostrarNuevoAlumno) {
                NuevoAlumnoView()
            }
        }
    }

    private func eliminarAlumno(offsets: IndexSet) {
        for index in offsets {
            let alumno = alumnos[index]
            modelContext.delete(alumno)
        }
        try? modelContext.save() // Guarda la eliminación permanentemente
    }
}

// MARK: - Vista Modal: Nuevo Alumno
struct NuevoAlumnoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var apellido = ""
    @State private var nombre = ""
    @State private var dni = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("DATOS DEL ALUMNO")) {
                    TextField("Apellido", text: $apellido)
                    TextField("Nombre", text: $nombre)
                    TextField("DNI", text: $dni)
                }

                Section {
                    Button(action: guardar) {
                        HStack {
                            Spacer()
                            Text("Guardar Alumno")
                                .foregroundColor(apellido.isEmpty || nombre.isEmpty ? .gray : .blue)
                            Spacer()
                        }
                    }
                    .disabled(apellido.isEmpty || nombre.isEmpty)
                }
            }
            .navigationTitle("Nuevo Alumno")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func guardar() {
        let nuevo = Alumno(apellido: apellido, nombre: nombre, dni: dni)
        modelContext.insert(nuevo)
        
        // FORZAR GUARDADO EN DISCO
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error al guardar en SwiftData: \(error)")
        }
    }
}

// MARK: - Vista: Detalles del Alumno
struct DetalleAlumnoView: View {
    let alumno: Alumno

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.fill")
                    .font(.title)
                Text("Detalles del Alumno")
                    .font(.title2)
                    .bold()
            }
            .padding(.bottom, 10)

            Text("Nombre: \(alumno.nombre)")
            Text("Apellido: \(alumno.apellido)")
            Text("DNI: \(alumno.dni)")

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Alumno.self, inMemory: true)
}