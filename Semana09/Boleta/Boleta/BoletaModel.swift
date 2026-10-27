//
//  BoletaModel.swift
//  Boleta
//
//  Created by Tecsup on 27/10/26.
//

import Foundation

class BoletaCalculadora {
    // Parámetros fijos centralizados (según la guía)
    let rmv: Double = 1230.00
    let tasaEsSalud: Double = 0.09
    let tasaONP: Double = 0.13

    let afpFondoTasa: Double = 0.10
    let afpComisionTasa: Double = 0.0160
    let afpSeguroTasa: Double = 0.0135

    // Resultados
    var sueldoComputable: Double = 0.0
    var asignacionFamiliar: Double = 0.0
    var montoHE25: Double = 0.0
    var montoHE35: Double = 0.0
    var totalRemuneraciones: Double = 0.0

    var montoONP: Double = 0.0
    var montoAFPFondo: Double = 0.0
    var montoAFPComision: Double = 0.0
    var montoAFPSeguro: Double = 0.0
    var montoAdelantos: Double = 0.0
    var totalDescuentos: Double = 0.0

    var netoAPagar: Double = 0.0
    var esSaludEmpleador: Double = 0.0

    func calcular(sueldoBasico: Double, diasLaborados: Int, tieneHijos: Bool, esONP: Bool, horas25: Double, horas35: Double, adelantos: Double) {

        let scRaw = (sueldoBasico / 30.0) * Double(diasLaborados)
        sueldoComputable = redondear(scRaw)

        asignacionFamiliar = tieneHijos ? redondear(rmv * 0.10) : 0.0

        let valorHora = (sueldoBasico / 30.0) / 8.0
        montoHE25 = redondear(valorHora * 1.25 * horas25)
        montoHE35 = redondear(valorHora * 1.35 * horas35)

        totalRemuneraciones = redondear(sueldoComputable + asignacionFamiliar + montoHE25 + montoHE35)

        if esONP {
            montoONP = redondear(totalRemuneraciones * tasaONP)
            montoAFPFondo = 0.0
            montoAFPComision = 0.0
            montoAFPSeguro = 0.0
        } else {
            montoONP = 0.0
            montoAFPFondo = redondear(totalRemuneraciones * afpFondoTasa)
            montoAFPComision = redondear(totalRemuneraciones * afpComisionTasa)
            montoAFPSeguro = redondear(totalRemuneraciones * afpSeguroTasa)
        }

        montoAdelantos = redondear(adelantos)

        let pensionTotal = esONP ? montoONP : (montoAFPFondo + montoAFPComision + montoAFPSeguro)
        totalDescuentos = redondear(pensionTotal + montoAdelantos)

        netoAPagar = redondear(totalRemuneraciones - totalDescuentos)
        esSaludEmpleador = redondear(totalRemuneraciones * tasaEsSalud)
    }

    private func redondear(_ valor: Double) -> Double {
        return (valor * 100).rounded() / 100
    }
}
