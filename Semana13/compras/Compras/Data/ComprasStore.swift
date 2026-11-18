import Foundation
import SwiftData

struct ComprasStore {
    let contexto: ModelContext

    func buscarUsuario(_ identificador: String) throws -> Usuario? {
        var consulta = FetchDescriptor<Usuario>(predicate: #Predicate { $0.usuario == identificador })
        consulta.fetchLimit = 1
        return try contexto.fetch(consulta).first
    }

    func existeProveedor(ruc: String) throws -> Bool {
        let consulta = FetchDescriptor<Proveedor>(predicate: #Predicate { $0.ruc == ruc })
        return try contexto.fetchCount(consulta) > 0
    }

    func insertar(_ modelo: some PersistentModel) throws {
        contexto.insert(modelo)
        try guardarCambios()
    }

    func borrar<Modelo: PersistentModel>(_ modelos: [Modelo]) throws {
        for modelo in modelos { contexto.delete(modelo) }
        try guardarCambios()
    }

    @discardableResult
    func registrarCompra(comprador: Usuario, proveedor: Proveedor, producto: Producto,
                         cantidad: Int, costo: Decimal, alCredito: Bool, fecha: Date = .now) throws -> Compra {
        guard comprador.rol == Rol.comprador.rawValue else { throw ProblemaCompra.permiso }
        guard cantidad > 0, costo > 0, costo == costo.redondeadoAMoneda else { throw ProblemaCompra.datos }
        let importe = ImporteCompra(costo: costo, cantidad: cantidad)
        let compra = Compra(comprador: comprador, proveedor: proveedor, producto: producto, cantidad: cantidad,
                            costoUnitario: costo, importe: importe, alCredito: alCredito, fecha: fecha)
        if !importe.requiereAprobacion {
            try aplicarAprobacion(compra)
        }
        contexto.insert(compra)
        try guardarCambios()
        return compra
    }

    func aprobar(_ compra: Compra, por usuario: Usuario) throws {
        guard usuario.esSupervisor else { throw ProblemaCompra.permiso }
        guard compra.estado == EstadoCompra.pendiente.rawValue else { throw ProblemaCompra.estado }
        try aplicarAprobacion(compra)
        try guardarCambios()
    }

    func rechazar(_ compra: Compra, por usuario: Usuario, motivo: String) throws {
        guard usuario.esSupervisor else { throw ProblemaCompra.permiso }
        guard compra.estado == EstadoCompra.pendiente.rawValue else { throw ProblemaCompra.estado }
        guard !motivo.recortado.isEmpty else { throw ProblemaCompra.motivo }
        compra.motivoRechazo = motivo.recortado
        compra.estado = EstadoCompra.rechazada.rawValue
        try guardarCambios()
    }

    func pagar(_ compra: Compra, por usuario: Usuario) throws {
        guard usuario.esSupervisor else { throw ProblemaCompra.permiso }
        guard compra.porPagar else { throw ProblemaCompra.estado }
        compra.pagada = true
        try guardarCambios()
    }

    private func aplicarAprobacion(_ compra: Compra) throws {
        guard let producto = compra.producto, let efecto = compra.efectoEnInventario else {
            throw ProblemaCompra.inventario
        }
        producto.stock = efecto.stock
        producto.costoPromedio = NSDecimalNumber(decimal: efecto.costoPromedio).doubleValue
        compra.estado = EstadoCompra.aprobada.rawValue
        compra.pagada = !compra.alCredito
    }

    func guardarCambios() throws {
        do {
            try contexto.save()
        } catch {
            contexto.rollback()
            throw error
        }
    }
}
