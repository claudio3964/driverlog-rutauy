import SwiftUI
import sharedKit

struct NuevoViajeView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Campos del Formulario
    @State private var nroCoche: String = ""
    @State private var origen: String = "Montevideo"
    @State private var destino: String = "Colonia"
    @State private var horaSalida: Date = Date()
    
    // Estado de Hora de Llegada (Deshabilitado por regla de negocio)
    @State private var horaLlegada: Date = Date()
    @State private var esViajeDirecto: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // 1. DATOS DEL UNIDAD Y RUTA
                Section(header: Text("Datos del Servicio")) {
                    HStack {
                        Image(systemName: "bus.fill")
                            .foregroundColor(.blue)
                        TextField("Nº de Coche (ej: 104)", text: $nroCoche)
                            .keyboardType(.numberPad)
                    }

                    Picker("Origen", selection: $origen) {
                        Text("Montevideo").tag("Montevideo")
                        Text("Colonia").tag("Colonia")
                        Text("Punta del Este").tag("Punta del Este")
                        Text("Chuy").tag("Chuy")
                    }

                    Picker("Destino", selection: $destino) {
                        Text("Colonia").tag("Colonia")
                        Text("Montevideo").tag("Montevideo")
                        Text("Punta del Este").tag("Punta del Este")
                        Text("Chuy").tag("Chuy")
                    }
                }

                // 2. HORARIOS
                Section(header: Text("Horarios del Viaje")) {
                    DatePicker("Hora de Salida", selection: $horaSalida, displayedComponents: .hourAndMinute)
                    
                    // CAMPO DESHABILITADO SEGÚN REGLA DE NEGOCIO
                    HStack {
                        Text("Hora de Llegada")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Pendiente de Cierre")
                            .font(.footnote)
                            .italic()
                            .foregroundColor(.orange)
                    }
                }

                // 3. ADICIONALES
                Section(header: Text("Tipo de Servicio")) {
                    Toggle("Viaje Directo (Sin paradas)", isOn: $esViajeDirecto)
                }

                // 4. AVISO INFORMATIVO
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("La hora de llegada se registrará automáticamente cuando confirmes la llegada o al finalizar el turno.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Nuevo Viaje / Contrato")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Iniciar Viaje") {
                        // AQUÍ SE INVOCARÁ EL USE CASE DE KMP (sharedKit)
                        print("Iniciando viaje en Coche \(nroCoche) de \(origen) a \(destino)")
                        dismiss()
                    }
                    .bold()
                    .disabled(nroCoche.isEmpty) // Bloquea hasta que ponga el coche
                }
            }
        }
    }
}

#Preview {
    NuevoViajeView()
}
