import UIKit
import CoreData

extension ViewController {
    
    // MARK: Predicate simple - Buscar por texto en el nombre
    func buscarContactos(texto: String) -> [Contacto] {
        let request: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        request.predicate = NSPredicate(format: "nombre CONTAINS[cd] %@", texto)
        request.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        return (try? conexion().fetch(request)) ?? []
    }

    // MARK: Probar relación 1 a Muchos (Grupo -> Contactos)
    func probarRelacion() {
        let contexto = conexion()
        let grupo = NSEntityDescription.insertNewObject(forEntityName: "Grupo", into: contexto) as! Grupo
        grupo.nombre = "Amigos"

        if let primero = contactos.first {
            do {
                primero.grupo = grupo
                try contexto.save()
                print("El grupo \(grupo.nombre ?? "") tiene \(grupo.contactos?.count ?? 0) contacto(s)")
            } catch {
                print("Error al guardar la relación: \(error)")
            }
        }
    }

    // MARK: Fetch request con predicate navegando la relación
    func contactosDelGrupo(nombreGrupo: String) -> [Contacto] {
        let request: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        request.predicate = NSPredicate(format: "grupo.nombre == %@", nombreGrupo)
        return (try? conexion().fetch(request)) ?? []
    }
}