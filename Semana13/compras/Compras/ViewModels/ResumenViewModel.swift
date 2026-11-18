import Foundation

struct ResumenViewModel {
    let productos: [Producto]
    let proveedores: [Proveedor]
    let compras: [Compra]

    private var aprobadas: [Compra] { compras.filter { $0.estado == EstadoCompra.aprobada.rawValue } }
    private var pendientes: [Compra] { compras.filter { $0.estado == EstadoCompra.pendiente.rawValue } }
    private var porPagar: [Compra] { compras.filter(\.porPagar) }

    var ranking: [(proveedor: Proveedor, total: Decimal)] {
        proveedores.map { (proveedor: $0, total: $0.totalComprado) }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
    }

    var valorInventario: Decimal { productos.reduce(0) { $0 + $1.valorInventario } }
    var creditoFiscal: Decimal { aprobadas.reduce(0) { $0 + Decimal($1.igv) } }
    var saldoPorPagar: Decimal { porPagar.reduce(0) { $0 + Decimal($1.total) } }
    var importePorAprobar: Decimal { pendientes.reduce(0) { $0 + Decimal($1.total) } }
    var cantidadPorAprobar: Int { pendientes.count }
    var cantidadPorPagar: Int { porPagar.count }
}
