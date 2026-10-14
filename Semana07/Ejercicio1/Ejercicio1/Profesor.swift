//
//  Profesor.swift
//  Ejercicio1
//
//  Created by Tecsup on 14/10/26.
//
import UIKit

class Profesor: NSObject {

    var nombre: String = ""
    var cargo: String = ""
    var foto: UIImage!

    init(nombre: String, cargo: String, foto: UIImage!) {
        self.nombre = nombre
        self.cargo = cargo
        self.foto = foto
    }
}
