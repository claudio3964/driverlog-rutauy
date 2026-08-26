import SwiftUI

struct DeviceApprovalView: View {
    let deviceId: String
    var onRecheckStatus: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "shield.badge.clock.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Dispositivo en Espera")
                    .font(.title2)
                    .bold()
                
                Text("Se ha enviado una solicitud a Administración para autorizar este equipo.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("ID DISPOSITIVO:")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.secondary)
                
                Text(deviceId)
                    .font(.footnote)
                    .fontDesign(.monospaced)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: onRecheckStatus) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Verificar Estado")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    DeviceApprovalView(deviceId: "UUID-TEST-2026-COT") {
        print("Verificando aprobación...")
    }
}
