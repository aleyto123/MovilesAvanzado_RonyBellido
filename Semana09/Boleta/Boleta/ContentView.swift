//
//  ContentView.swift
//  Boleta
//
//  Created by Tecsup on 27/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var calculadora = BoletaCalculadora()

    // Todos los campos vacíos por defecto con placeholders de guía
    @State private var sueldoBasicoInput: String = ""
    @State private var diasLaboradosInput: String = ""
    @State private var tieneHijosToggle: Bool = false
    @State private var esSistemaONP: Bool = true
    @State private var horas25Input: String = ""
    @State private var horas35Input: String = ""
    @State private var adelantosInput: String = ""

    @State private var mostrado: Bool = false
    @State private var mostrarAlerta: Bool = false
    @State private var mensajeAlerta: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Encabezado
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cálculo Laboral Perú")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Boleta de Pago")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // Formulario de Entradas
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Parámetros del Mes")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)

                        HStack {
                            Text("Sueldo Básico (S/):")
                            Spacer()
                            TextField("Ej. 2500", text: $sueldoBasicoInput)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }

                        HStack {
                            Text("Días Laborados (1-30):")
                            Spacer()
                            TextField("Ej. 30", text: $diasLaboradosInput)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }

                        Picker("¿Tiene hijos?", selection: $tieneHijosToggle) {
                            Text("No").tag(false)
                            Text("Sí").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Picker("Sistema de Pensiones", selection: $esSistemaONP) {
                            Text("ONP (13%)").tag(true)
                            Text("AFP Ejemplo").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Divider()

                        HStack {
                            Text("Horas Extras 25% (Cant):")
                            Spacer()
                            TextField("Ej. 0", text: $horas25Input)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }

                        HStack {
                            Text("Horas Extras 35% (Cant):")
                            Spacer()
                            TextField("Ej. 0", text: $horas35Input)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }

                        HStack {
                            Text("Adelantos (S/):")
                            Spacer()
                            TextField("Ej. 0.00", text: $adelantosInput)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }

                        Button(action: {
                            // Validaciones estrictas de campos obligatorios o vacíos
                            guard let basico = Double(sueldoBasicoInput), basico > 0 else {
                                mensajeAlerta = "Faltan datos solicitados: Ingrese un sueldo básico válido."
                                mostrarAlerta = true
                                mostrado = false
                                return
                            }

                            guard let dias = Int(diasLaboradosInput), dias > 0, dias <= 30 else {
                                mensajeAlerta = "Faltan datos solicitados: Los días laborados deben ser entre 1 y 30."
                                mostrarAlerta = true
                                mostrado = false
                                return
                            }

                            let h25 = Double(horas25Input) ?? 0.0
                            let h35 = Double(horas35Input) ?? 0.0
                            let adelanto = Double(adelantosInput) ?? 0.0

                            calculadora.calcular(
                                sueldoBasico: basico,
                                diasLaborados: dias,
                                tieneHijos: tieneHijosToggle,
                                esONP: esSistemaONP,
                                horas25: h25,
                                horas35: h35,
                                adelantos: adelanto
                            )
                            mostrado = true
                        }) {
                            Text("Calcular Boleta")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .alert(isPresented: $mostrarAlerta) {
                        Alert(title: Text("Aviso"), message: Text(mensajeAlerta), dismissButton: .default(Text("OK")))
                    }

                    // Resultados
                    if mostrado {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Resultado de la Boleta")
                                .font(.headline)
                                .foregroundColor(.primary)

                            // Bloque 1: Remuneraciones
                            VStack(alignment: .leading, spacing: 8) {
                                Text("REMUNERACIONES").font(.subheadline).bold().foregroundColor(.blue)
                                FilaBoleta(concepto: "Sueldo computable", monto: calculadora.sueldoComputable)
                                FilaBoleta(concepto: "Asignación familiar", monto: calculadora.asignacionFamiliar)
                                FilaBoleta(concepto: "Horas extras 25%", monto: calculadora.montoHE25)
                                FilaBoleta(concepto: "Horas extras 35%", monto: calculadora.montoHE35)
                                Divider()
                                FilaBoleta(concepto: "Total remuneraciones", monto: calculadora.totalRemuneraciones, isBold: true)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 1)

                            // Bloque 2: Retenciones / Descuentos
                            VStack(alignment: .leading, spacing: 8) {
                                Text("RETENCIONES / DESCUENTOS").font(.subheadline).bold().foregroundColor(.red)
                                if esSistemaONP {
                                    FilaBoleta(concepto: "ONP (13%)", monto: calculadora.montoONP)
                                    FilaBoleta(concepto: "AFP fondo", monto: 0.0)
                                    FilaBoleta(concepto: "AFP comisión", monto: 0.0)
                                    FilaBoleta(concepto: "AFP seguro", monto: 0.0)
                                } else {
                                    FilaBoleta(concepto: "ONP", monto: 0.0)
                                    FilaBoleta(concepto: "AFP fondo", monto: calculadora.montoAFPFondo)
                                    FilaBoleta(concepto: "AFP comisión", monto: calculadora.montoAFPComision)
                                    FilaBoleta(concepto: "AFP seguro", monto: calculadora.montoAFPSeguro)
                                }
                                FilaBoleta(concepto: "Adelantos", monto: calculadora.montoAdelantos)
                                Divider()
                                FilaBoleta(concepto: "Total descuentos", monto: calculadora.totalDescuentos, isBold: true)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 1)

                            // Bloque 3: Aportaciones del Empleador
                            VStack(alignment: .leading, spacing: 8) {
                                Text("APORTACIONES DEL EMPLEADOR").font(.subheadline).bold().foregroundColor(.green)
                                FilaBoleta(concepto: "EsSalud (9%)", monto: calculadora.esSaludEmpleador)
                                Divider()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 1)

                            // Neto a Pagar
                            HStack {
                                Text("NETO A PAGAR:")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                                Text("S/ \(String(format: "%.2f", calculadora.netoAPagar))")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
    }
}

struct FilaBoleta: View {
    let concepto: String
    let monto: Double
    var isBold: Bool = false

    var body: some View {
        HStack {
            Text(concepto)
                .font(isBold ? .subheadline : .footnote)
                .fontWeight(isBold ? .bold : .regular)
            Spacer()
            Text(String(format: "%.2f", monto))
                .font(isBold ? .subheadline : .footnote)
                .fontWeight(isBold ? .bold : .regular)
        }
    }
}
