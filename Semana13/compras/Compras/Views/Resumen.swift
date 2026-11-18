import SwiftUI
import SwiftData

struct ResumenView: View {
    @Query private var productos: [Producto]
    @Query private var proveedores: [Proveedor]
    @Query private var compras: [Compra]
    let usuario: Usuario
    let cerrarSesion: () -> Void

    private var vm: ResumenViewModel {
        ResumenViewModel(productos: productos, proveedores: proveedores, compras: compras)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                inventario
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        creditoFiscal
                        saldoPorPagar
                    }
                    VStack(spacing: 10) {
                        creditoFiscal
                        saldoPorPagar
                    }
                }
                indicador("Por aprobar", valor: vm.importePorAprobar.soles, icono: "hourglass",
                          detalle: vm.cantidadPorAprobar == 1 ? "1 compra pendiente" : "\(vm.cantidadPorAprobar) compras pendientes",
                          color: .pendienteCompras)
                comprasPorProveedor
            }
            .padding(.horizontal, 17)
            .padding(.top, 4)
            .padding(.bottom, 18)
        }
        .background(Color.fondoCompras)
        .encabezadoCompras("Resumen", usuario: usuario, cerrarSesion: cerrarSesion)
    }

    private var inventario: some View {
        let valor = vm.valorInventario
        return VStack(alignment: .leading, spacing: 9) {
            Label("Valor del inventario", systemImage: "shippingbox")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.mentaCompras)
            Text(valor.soles)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text(productos.count == 1 ? "1 producto en el catálogo" : "\(productos.count) productos en el catálogo")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .panelAlmacen()
        .accessibilityElement(children: .combine)
    }

    private var creditoFiscal: some View {
        indicador("Crédito fiscal", valor: vm.creditoFiscal.soles,
                  icono: "percent", detalle: "IGV de compras aprobadas")
    }

    private var saldoPorPagar: some View {
        indicador("Por pagar", valor: vm.saldoPorPagar.soles,
                  icono: "creditcard", detalle: vm.cantidadPorPagar == 1 ? "1 crédito sin pagar" : "\(vm.cantidadPorPagar) créditos sin pagar")
    }

    private func indicador(_ titulo: String, valor: String, icono: String,
                           detalle: String, color: Color = .accentColor) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(titulo, systemImage: icono)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(color)
            Text(valor)
                .font(.system(.title3, design: .serif, weight: .bold))
                .monospacedDigit()
            Text(detalle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .tarjetaCompras()
        .accessibilityElement(children: .combine)
    }

    private var comprasPorProveedor: some View {
        let filas = vm.ranking
        let maximo = filas.first?.total ?? 1

        return VStack(alignment: .leading, spacing: 13) {
            Text("Compras por proveedor")
                .font(.system(.headline, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)
            if filas.isEmpty {
                Text("Todavía no hay compras aprobadas.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(filas.indices, id: \.self) { indice in
                let fila = filas[indice]
                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(fila.proveedor.nombre).font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(fila.total.soles)
                            .font(.footnote.weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    GeometryReader { geometria in
                        let fraccion = NSDecimalNumber(decimal: fila.total / maximo).doubleValue
                        Capsule()
                            .fill(Color.accentColor.opacity(0.13))
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(Color.accentColor)
                                    .frame(width: geometria.size.width * fraccion)
                            }
                    }
                    .frame(height: 6)
                    .accessibilityHidden(true)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .tarjetaCompras()
    }
}
