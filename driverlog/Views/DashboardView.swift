import SwiftUI
import sharedKit

struct EventoJornada: Identifiable {
    let id = UUID()
    let titulo: String
    let detalle: String
    let hora: String
    let esViaje: Bool
}

struct DashboardView: View {
    @State private var jornadaColgada: Bool = false
    @State private var eventoEnCurso: String? = "Viaje"
    // Totales de la jornada: salen de `LaudoCalculator` de `sharedKit`, no se calculan ni se
    // hardcodean en Swift. La jornada de entrada todavía es fija (`jornadaDeMuestra`) porque el
    // Dashboard no lee SwiftData/Supabase -- cuando lea, solo cambia el argumento de `calcular`.
    @State private var totales = DashboardView.calcularTotales(de: DashboardView.jornadaDeMuestra)
    
    // Lista de eventos de la jornada
    @State private var eventos: [EventoJornada] = [
        EventoJornada(titulo: "Viaje MVD - COL", detalle: "Coche 104 • 42.5 km tome/cese incl.", hora: "08:00 Hs", esViaje: true)
    ]
    
    @State private var mostrarNuevoViaje = false
    @State private var mostrarNuevaGuardia = false
    @State private var mostrarCierreJornada = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // 1. ALERTA DE BLOQUEO POR JORNADA ANTERIOR ABIERTA
                    if jornadaColgada {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("Jornada Anterior Colgada")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                            Text("Tenés una jornada abierta de una fecha anterior. Debés cerrarla usando la hora de llegada del último viaje para poder operar hoy.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                jornadaColgada = false
                            }) {
                                Text("Cerrar Jornada Anterior")
                                    .font(.subheadline)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }

                    // 2. BANNER DE ACCIÓN EN CURSO (TOAST VIVO EN MAIN SCREEN)
                    if let tipoEvento = eventoEnCurso {
                        HStack(spacing: 12) {
                            Image(systemName: tipoEvento == "Viaje" ? "bus.fill" : "clock.badge.checkmark.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(tipoEvento.uppercased()) EN CURSO")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.blue)
                                
                                Text(tipoEvento == "Viaje" ? "Montevideo ➔ Colonia" : "Guardia Retén - Base MVD")
                                    .font(.subheadline)
                                    .bold()
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Acumulado")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("$\(totales.monto, specifier: "%.2f")")
                                    .font(.callout)
                                    .bold()
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                    }

                    // 3. TARJETA RESUMEN DE LA JORNADA
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen del Día")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        Divider()

                        HStack {
                            VStack(alignment: .leading) {
                                Text("KM Totales")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(totales.kmTotal, specifier: "%.1f") km")
                                    .font(.title2)
                                    .bold()
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Monto Est.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("$\(totales.monto, specifier: "%.2f")")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)

                    // 4. ACCIONES RÁPIDAS
                    HStack(spacing: 12) {
                        Button(action: { mostrarNuevoViaje = true }) {
                            Label("Viaje / Contrato", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(jornadaColgada ? Color.gray.opacity(0.3) : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(jornadaColgada)

                        Button(action: { mostrarNuevaGuardia = true }) {
                            Label("Guardia", systemImage: "clock.fill")
                                .font(.subheadline)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(jornadaColgada ? Color.gray.opacity(0.3) : Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(jornadaColgada)
                    }

                    // 5. HISTORIAL DE LA JORNADA ACTUAL
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Detalle de la Jornada")
                            .font(.headline)
                            .padding(.top, 8)

                        ForEach(eventos) { item in
                            HStack {
                                Image(systemName: item.esViaje ? "bus" : "clock")
                                    .foregroundColor(.secondary)
                                VStack(alignment: .leading) {
                                    Text(item.titulo)
                                        .font(.subheadline)
                                        .bold()
                                    Text(item.detalle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(item.hora)
                                    .font(.caption)
                                    .bold()
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                    }

                    // 6. BOTÓN FINALIZAR JORNADA
                    Button(action: { mostrarCierreJornada = true }) {
                        Label("Finalizar Jornada", systemImage: "checkmark.seal.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)
                    .disabled(jornadaColgada)

                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
                        .navigationTitle("COT Driver")
                        .sheet(isPresented: $mostrarNuevoViaje) {
                            NuevoViajeView()
                        }
                        .sheet(isPresented: $mostrarNuevaGuardia) {
                            NuevaGuardiaView()
                        }
                        .alert("Finalizar Jornada", isPresented: $mostrarCierreJornada) {
                            Button("Cancelar", role: .cancel) { }
                            Button("Confirmar Cierre", role: .destructive) {
                                print("Jornada cerrada correctamente.")
                            }
                        } message: {
                            Text("¿Deseás registrar el último regreso a la punta y cerrar el turno de hoy?")
                        }
                    }
                }
            }

// MARK: - Puente a LaudoCalculator (sharedKit)

extension DashboardView {
    // `calcular` tiene defaults en Kotlin (`LAUDO_KM`, `MONTO_VIATICO`), pero el header ObjC de
    // `sharedKit` no los exporta y las constantes son `private` -- hay que pasarlos. Mismos
    // valores que usa la prueba de `ContentView`.
    static func calcularTotales(de jornada: sharedKit.JornadaCompleta) -> sharedKit.LaudoCalculator.Totales {
        sharedKit.LaudoCalculator.shared.calcular(jornada: jornada, laudoKm: 8.0122, montoViatico: 455.26)
    }

    // Misma jornada que muestran el banner y el detalle de arriba: un viaje MVD -> COL en curso,
    // coche 104, 08:00 (2026-07-30T08:00:00Z, mismo timestamp que la prueba de `ContentView`).
    // `tipoServicio: "SEMI"` es como el panel guarda el semidirecto -- `LaudoCalculator` lo
    // resuelve a SEMIDIRECTO y suma el tome y cese.
    static var jornadaDeMuestra: sharedKit.JornadaCompleta {
        let inicio: Int64 = 1785398400000
        let viaje = sharedKit.Viaje(
            id: "MUESTRA-001",
            orderNumber: "MUESTRA-20260730",
            origen: "Montevideo",
            destino: "Colonia",
            departureTime: "08:00",
            arrivalTime: "",
            status: "en_curso",
            inicioProgramado: inicio,
            inicioReal: KotlinLong(value: inicio),
            finReal: nil,
            kmEmpresa: 220,
            kmAuto: 0,
            turno: "",
            tipoServicio: "SEMI",
            acoplado: false,
            acopladoKm: 0,
            coche: "104",
            tomeCese: false,
            syncStatus: "local",
            asignadoPorAdmin: false,
            notificado: false,
            duracionMinutos: nil,
            llegadaReal: nil,
            llegadaEstimada: nil,
            origenCreacion: "app",
            cierreAutomatico: nil
        )
        return sharedKit.JornadaCompleta(
            orderNumber: "MUESTRA-20260730",
            fecha: "2026-07-30",
            legajo: "",
            baseInicio: "Montevideo",
            travels: [viaje],
            guards: [],
            closed: false,
            tomeCeseGenerado: false,
            createdAt: inicio,
            closedAt: nil,
            totalsSnapshot: nil
        )
    }
}

            #Preview {
                DashboardView()
            }
