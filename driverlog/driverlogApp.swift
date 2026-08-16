//
//  driverlogApp.swift
//  driverlog
//
//  Created by Tamara Perez Ricardo on 5/8/26.
//

import SwiftUI
import SwiftData

@main
struct driverlogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Jornada.self, Viaje.self, Guardia.self, Mensaje.self])
    }
}
