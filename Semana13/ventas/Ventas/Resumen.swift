import Charts
import SwiftData
import SwiftUI

struct ResumenView: View {
    @Query(filter: #Predicate<Venta> { !$0.anulada }) private var ventas: [Venta]
    @Query(sort: \Producto.stock) private var productos: [Producto]
    @State private var productoParaReponer: Producto?
    let usuario: Usuario

    var body: some View {
        let calendario = Calendar.current
        let hoy = calendario.startOfDay(for: .now)
        let dias = (0...6).reversed().compactMap { calendario.date(byAdding: .day, value: -$0, to: hoy) }
        let ventasMes = ventas.filter { calendario.isDate($0.fecha, equalTo: hoy, toGranularity: .month) }
        let totalHoy = total(delDia: hoy, calendario: calendario)
        let totalAyer = dias.dropLast().last.map { total(delDia: $0, calendario: calendario) } ?? 0
        let igvMes = ventasMes.reduce(Decimal.zero) { $0 + Decimal($1.igv) }
        let ranking = Dictionary(grouping: ventasMes, by: { $0.vendedor.persistentModelID })
            .values.compactMap { operaciones -> Puesto? in
                guard let vendedor = operaciones.first?.vendedor else { return nil }
                let importe = operaciones.reduce(Decimal.zero) { $0 + Decimal($1.total) }
                return Puesto(id: vendedor.persistentModelID, nombre: vendedor.nombre, total: importe)
            }
            .sorted {
                if $0.total == $1.total { return $0.nombre < $1.nombre }
                return $0.total > $1.total
            }
        let stockBajo = productos.filter { $0.stock <= 5 }

        NavigationStack {
            List {
                Section {
                    Text("Hola, \(usuario.nombre)").font(.title2.bold())
                    Label(usuario.rol, systemImage: "person.badge.shield.checkmark")
                        .foregroundStyle(.blue)
                    LabeledContent("Vendido hoy", value: totalHoy.soles)
                    LabeledContent("Vendido ayer", value: totalAyer.soles)
                    if totalAyer > 0 {
                        let variacion = (totalHoy - totalAyer) / totalAyer
                        LabeledContent("Variación", value: variacion.formatted(.percent.precision(.fractionLength(1))))
                    }
                    LabeledContent("IGV del mes", value: igvMes.soles)
                }
                Section("Ventas de los últimos 7 días") {
                    Chart(dias, id: \.self) { dia in
                        BarMark(
                            x: .value("Día", dia, unit: .day),
                            y: .value("Ventas (S/)", NSDecimalNumber(decimal: total(delDia: dia, calendario: calendario)).doubleValue)
                        )
                        .foregroundStyle(.blue)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) {
                            AxisValueLabel(format: .dateTime.weekday(.narrow))
                        }
                    }
                    .frame(height: 165)
                }
                Section("Ranking de vendedores del mes") {
                    if ranking.isEmpty { Text("Todavía no hay ventas vigentes.").foregroundStyle(.secondary) }
                    ForEach(ranking) { puesto in
                        LabeledContent(puesto.nombre, value: puesto.total.soles)
                    }
                }
                Section("Stock bajo (5 unidades o menos)") {
                    if stockBajo.isEmpty { Text("No hay productos con stock bajo.").foregroundStyle(.secondary) }
                    ForEach(stockBajo) { producto in
                        HStack {
                            LabeledContent(producto.nombre, value: "\(producto.stock) u.")
                            Button("Reponer") { productoParaReponer = producto }
                                .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .navigationTitle("Resumen")
            .sheet(item: $productoParaReponer) { EditorProducto(producto: $0) }
        }
    }

    private func total(delDia fecha: Date, calendario: Calendar) -> Decimal {
        ventas.filter { calendario.isDate($0.fecha, inSameDayAs: fecha) }
            .reduce(Decimal.zero) { $0 + Decimal($1.total) }
    }
}

private struct Puesto: Identifiable {
    let id: PersistentIdentifier
    let nombre: String
    let total: Decimal
}
