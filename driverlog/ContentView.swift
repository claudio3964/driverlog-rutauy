import SwiftUI
import sharedKit

struct ContentView: View {
    @State private var resultadoTexto = "Tocá el botón para probar"
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.fill")
                .imageScale(.large)
                .foregroundStyle(.blue)
            
            Text("COT Driver iOS")
                .font(.title)
            
            Text(resultadoTexto)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Probar LaudoCalculator") {
                probarCalculator()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    func probarCalculator() {
        // Timestamps simples en milisegundos (2026-07-30T08:00:00Z)
        let timestampInicio: Int64 = 1785398400000
        let timestampFin: Int64 = 1785405600000
        
        // 1. Instanciamos el Viaje pasando Int64 directamente para los campos Long
        let viaje = sharedKit.Viaje(
            id: "TEST-001",
            orderNumber: "TEST-001-20260730",
            origen: "Montevideo",
            destino: "Colonia",
            departureTime: "08:00",
            arrivalTime: "10:00",
            status: "cerrado",
            
            // --- DIFERENCIA DE TIPOS POR NULABILIDAD ---
            inicioProgramado: timestampInicio,                      // Long (no-nulo)  -> Int64 directo
            inicioReal: KotlinLong(value: timestampInicio),          // Long? (nullable) -> KotlinLong
            finReal: KotlinLong(value: timestampFin),                // Long? (nullable) -> KotlinLong
            
            kmEmpresa: 220,                                         // Int -> Int32 / Int
            kmAuto: 0,
            turno: "",
            tipoServicio: "",
            acoplado: false,
            acopladoKm: 0,
            coche: "Sedan",
            tomeCese: false,
            syncStatus: "synced",
            asignadoPorAdmin: false,
            notificado: false,
            duracionMinutos: nil,                                   // Int? -> nil o KotlinInt(value:)
            llegadaReal: nil,                                       // String? -> nil o String
            llegadaEstimada: nil,                                   // String? -> nil o String
            origenCreacion: "manual",
            cierreAutomatico: nil                                   // Boolean? -> nil o KotlinBoolean(value:)
        )
        
        let travelsArray: [sharedKit.Viaje] = [viaje]
        let guardsArray: [sharedKit.Guardia] = []
        
        // 2. Instanciamos la Jornada
        let jornada = sharedKit.JornadaCompleta(
            orderNumber: "TEST-001-20260730",
            fecha: "2026-07-30",
            legajo: "4112",
            baseInicio: "Montevideo",
            travels: travelsArray,
            guards: guardsArray,
            closed: false,
            tomeCeseGenerado: false,
            createdAt: 1722312000000,
            closedAt: nil,
            totalsSnapshot: nil
        )
        
        // 3. Ejecutamos el cálculo en LaudoCalculator
        let calculator = sharedKit.LaudoCalculator.shared
        let resultado = calculator.calcular(
            jornada: jornada,
            laudoKm: 8.0122,
            montoViatico: 455.26
        )
        
        resultadoTexto = """
        ✅ LaudoCalculator OK desde Kotlin!
        KM Total: \(resultado.kmTotal)
        Monto: $\(resultado.monto)
        """
        
        print("✅ LaudoCalculator funcionó!")
        print("KM Total: \(resultado.kmTotal)")
        print("Monto: \(resultado.monto)")
    }
}

#Preview {
    ContentView()
}
