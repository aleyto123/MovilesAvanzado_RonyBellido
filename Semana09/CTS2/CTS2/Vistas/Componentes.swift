import SwiftUI

struct CampoNumero: View {
    let titulo: String
    @Binding var texto: String
    let id: String
    var entero = false
    let foco: FocusState<String?>.Binding

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(titulo)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            TextField("0", text: $texto)
                .keyboardType(entero ? .numberPad : .decimalPad)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
                .frame(minWidth: 70, maxWidth: 125)
                .focused(foco, equals: id)
                .accessibilityLabel(titulo)
                .accessibilityIdentifier(id)
        }
    }
}

struct CamposRemuneracion: View {
    @Binding var datos: FormularioRemuneracion
    let prefijo: String
    let foco: FocusState<String?>.Binding

    var body: some View {
        Group {
            CampoNumero(titulo: "Sueldo básico S/", texto: $datos.sueldo, id: prefijo + ".sueldo", foco: foco)
            Toggle("Asignación familiar acreditada", isOn: $datos.asignacion)
                .accessibilityIdentifier(prefijo + ".asignacion")
            CampoNumero(titulo: "Otros fijos computables S/", texto: $datos.fijos, id: prefijo + ".fijos", foco: foco)
            CampoNumero(titulo: "Jornada diaria en horas", texto: $datos.jornada, id: prefijo + ".jornada", foco: foco)
        }
    }
}

struct CamposVariables: View {
    @Binding var datos: FormularioVariables
    let meses: [FechaLaboral]
    let prefijo: String
    let foco: FocusState<String?>.Binding

    var body: some View {
        DisclosureGroup("Complementos variables del semestre") {
            Text("Importes percibidos, no cantidad de horas. Cada concepto requiere percepción en tres meses; se suma y divide entre seis. Usa cero cuando no corresponda.")
                .font(.footnote).foregroundColor(.secondary)
            ForEach(Array(meses.enumerated()), id: \.offset) { indice, mes in
                VStack(alignment: .leading, spacing: 8) {
                    Text(mes.nombreMes).font(.subheadline.bold())
                    CampoNumero(titulo: "Horas extras S/", texto: $datos.extras[indice],
                                id: "\(prefijo).extras.\(indice)", foco: foco)
                    CampoNumero(titulo: "Comisiones complementarias S/", texto: $datos.comisiones[indice],
                                id: "\(prefijo).comisiones.\(indice)", foco: foco)
                }
                .padding(.vertical, 4)
            }
        }
        .accessibilityIdentifier(prefijo + ".variables")
    }
}

struct FilaImporte: View {
    let titulo: String
    let valor: Decimal
    var destacado = false
    var id = ""

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(titulo).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Text(Dinero.mostrar(valor))
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .accessibilityIdentifier(id)
        }
        .font(destacado ? .headline : .body)
        .accessibilityElement(children: .contain)
    }
}

struct AlcanceCalculo: View {
    var body: some View {
        Section {
            Label("Sección A · Beneficios laborales", systemImage: "building.2")
                .font(.subheadline.weight(.semibold))
        } footer: {
            Text("Régimen general privado. Año 2026. Remuneración principal fija, jornada de 4 a 8 horas y semana habitual de 5 o 6 días. Resultados brutos; no liquidan el neto de planilla ni regímenes especiales.")
        }
    }
}

struct BasesLegales: View {
    let fuentes: [FuenteLegal]

    var body: some View {
        Section {
            DisclosureGroup("Base legal") {
                ForEach(fuentes) { fuente in
                    Link(fuente.titulo, destination: fuente.url)
                }
                Text("Parámetros consultados al 27/10/2026. Las fechas posteriores son proyecciones con estas normas. La asignación supone acreditar los requisitos de la Ley 25129/31600.")
                    .font(.footnote).foregroundColor(.secondary)
            }
        }
    }
}

struct MensajeError: View {
    let texto: String
    let id: String
    var body: some View {
        Section("Revisa los datos") {
            Label(texto, systemImage: "exclamationmark.circle")
                .foregroundColor(.red)
                .accessibilityIdentifier(id)
        }
    }
}

enum FechasFormulario {
    static let anio2026 = FechaLaboral(2026, 1, 1).fecha...FechaLaboral(2026, 12, 31).fecha
    static let ingreso = FechaLaboral(1900, 1, 1).fecha...FechaLaboral(2026, 12, 31).fecha
}
