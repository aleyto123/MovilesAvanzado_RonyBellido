import SwiftUI

struct BoletaView: View {
    let resultado: ResultadoBoleta
    let comparacion: ResultadoBoleta
    let sistema: SistemaPension
    let afp: String
    let resumen: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Resultado de la boleta").font(.headline)
            Text(resumen).font(.caption).foregroundColor(.secondary)

            bloque("REMUNERACIONES", conceptos: resultado.remuneraciones,
                   total: resultado.totalRemuneraciones, nombreTotal: "Total remuneraciones")
            bloque("RETENCIONES / DESCUENTOS", conceptos: resultado.descuentos,
                   total: resultado.totalDescuentos, nombreTotal: "Total descuentos")
            bloque("APORTACIONES DEL EMPLEADOR", conceptos: resultado.aportaciones)
            Text("EsSalud lo paga el empleador. No se descuenta del neto del trabajador.")
                .font(.caption).foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text("NETO A PAGAR").font(.subheadline.bold())
                Text(resultado.neto.soles).font(.title.bold()).minimumScaleFactor(0.6)
                    .accessibilityIdentifier("netoPagar")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.10))
            .cornerRadius(10)

            if resultado.neto < 0 {
                Text("Los descuentos superan las remuneraciones. El neto negativo indica un saldo pendiente.")
                    .font(.footnote).foregroundColor(.red)
            }
            FilaBoleta(concepto: "Costo para el empleador", monto: resultado.costoEmpleador)
            comparacionPensiones
        }
    }

    private func bloque(_ titulo: String, conceptos: [Concepto], total: Decimal? = nil, nombreTotal: String = "") -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titulo).font(.subheadline.bold()).foregroundColor(.blue)
            ForEach(conceptos) { concepto in
                FilaBoleta(concepto: concepto.nombre, monto: concepto.monto)
            }
            if let total = total {
                FilaBoleta(concepto: nombreTotal, monto: total, destacado: true)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }

    private var comparacionPensiones: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Comparación del neto este mes").font(.subheadline.bold())
            HStack(alignment: .top, spacing: 16) {
                columna("ONP", monto: sistema == .onp ? resultado.neto : comparacion.neto)
                columna(afp, monto: sistema == .afp ? resultado.neto : comparacion.neto)
            }
        }
    }

    private func columna(_ nombre: String, monto: Decimal) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(nombre).font(.caption).foregroundColor(.secondary)
            Text(monto.soles).font(.subheadline.bold()).monospacedDigit()
                .accessibilityIdentifier("comparacion.\(nombre)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FilaBoleta: View {
    let concepto: String
    let monto: Decimal
    var destacado = false

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(concepto)
            Spacer(minLength: 12)
            Text(monto.soles).monospacedDigit().multilineTextAlignment(.trailing)
                .accessibilityIdentifier("importe.\(concepto)")
        }
        .font(.subheadline)
        .fontWeight(destacado ? .bold : .regular)
    }
}
