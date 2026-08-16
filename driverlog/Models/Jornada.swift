//
//  Jornada.swift
//  driverlog
//
//  Espeja la entidad Room `Jornada` (tabla `jornadas_local`) del proyecto Android hermano.
//

import Foundation
import SwiftData

@Model
final class Jornada {
    @Attribute(.unique) var orderNumber: String
    var legajo: String
    var fecha: String
    var status: String
    var syncStatus: String
    var createdAt: Date
    var closedAt: Date?
    var horaInicio: String
    var kmTotal: Double
    var monto: Double
    var kmViajes: Double
    var kmAcoplados: Double
    var kmGuardias: Double
    var kmTomeCese: Double
    var viaticos: Int

    @Relationship(deleteRule: .cascade, inverse: \Viaje.jornada) var viajes: [Viaje] = []
    @Relationship(deleteRule: .cascade, inverse: \Guardia.jornada) var guardias: [Guardia] = []

    init(
        orderNumber: String,
        legajo: String,
        fecha: String,
        status: String = "activa",
        syncStatus: String = "pending",
        createdAt: Date = .now,
        closedAt: Date? = nil,
        horaInicio: String = "",
        kmTotal: Double = 0.0,
        monto: Double = 0.0,
        kmViajes: Double = 0.0,
        kmAcoplados: Double = 0.0,
        kmGuardias: Double = 0.0,
        kmTomeCese: Double = 0.0,
        viaticos: Int = 0
    ) {
        self.orderNumber = orderNumber
        self.legajo = legajo
        self.fecha = fecha
        self.status = status
        self.syncStatus = syncStatus
        self.createdAt = createdAt
        self.closedAt = closedAt
        self.horaInicio = horaInicio
        self.kmTotal = kmTotal
        self.monto = monto
        self.kmViajes = kmViajes
        self.kmAcoplados = kmAcoplados
        self.kmGuardias = kmGuardias
        self.kmTomeCese = kmTomeCese
        self.viaticos = viaticos
    }
}
