//
//  ViewController.swift
//  Ejercicio1
//
//  Created by Tecsup on 16/09/26.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var TxtPeso: UITextField!
    @IBOutlet weak var TxtAltura: UITextField!
    @IBOutlet weak var LabResultado: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        LabResultado.text = "Introduce tu Peso y Altura"
        // Do any additional setup after loading the view.
    }

    @IBAction func CalcularResultado(_ sender: Any) {
            let weight = Double(TxtPeso.text ?? "") ?? 0
            let height = Double(TxtAltura.text ?? "") ?? 0

            // Verificar si los valores de entrada son válidos
            if weight == 0 || height == 0 {
                LabResultado.text = "Por favor, ingresa valores válidos."
                return
            }

            // Calcular el IMC (usamos la fórmula estándar)
            let bmi = weight / (height * height)

            // Determinar si el peso es adecuado según el IMC
            var status = ""
            if bmi < 18.5 {
                status = "Bajo peso"
            } else if bmi < 24.9 {
                status = "Peso normal"
            } else if bmi < 29.9 {
                status = "Sobrepeso"
            } else {
                status = "Obesidad"
            }

            // Mostrar el resultado
            LabResultado.text = "IMC: \(String(format: "%.2f", bmi)) - \(status)"
        }
    
}

