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
    @State private var kmTotales: Double = 220.0
    @State private var montoTotal: Double = 1762.68
    
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
                                Text("$\(montoTotal, specifier: "%.2f")")
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
                                Text("\(kmTotales, specifier: "%.1f") km")
                                    .font(.title2)
                                    .bold()
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Monto Est.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("$\(montoTotal, specifier: "%.2f")")
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

            #Preview {
                DashboardView()
            }
