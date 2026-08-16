//
//  Viaje.swift
//  driverlog
//
//  Espeja la entidad Room `Viaje` (tabla `viajes`) del proyecto Android hermano.
//

import Foundation
import SwiftData

@Model
final class Viaje {
    @Attribute(.unique) var id: String
    var orderNumber: String
    var jornada: Jornada?
    var origen: String
    var destino: String
    var departureTime: String
    var arrivalTime: String
    var status: String
    var inicioProgramado: Date
    var inicioReal: Date?
    var finReal: Date?
    var kmEmpresa: Int
    var kmAuto: Int
    var turno: String
    var tipoServicio: String
    var acoplado: Bool
    var acopladoKm: Int
    var coche: String?
    var tomeCese: Bool
    var syncStatus: String
    var asignadoPorAdmin: Bool
    var notificado: Bool
    var duracionMinutos: Int64?
    var llegadaReal: Date?
    var llegadaEstimada: Date?
    var origenCreacion: String
    var cierreAutomatico: Bool?

    init(
        id: String,
        orderNumber: String,
        jornada: Jornada? = nil,
        origen: String,
        destino: String,
        departureTime: String,
        arrivalTime: String,
        status: String,
        inicioProgramado: Date,
        inicioReal: Date? = nil,
        finReal: Date? = nil,
        kmEmpresa: Int = 0,
        kmAuto: Int = 0,
        turno: String = "",
        tipoServicio: String = "",
        acoplado: Bool = false,
        acopladoKm: Int = 0,
        coche: String? = nil,
        tomeCese: Bool = false,
        syncStatus: String = "local",
        asignadoPorAdmin: Bool = false,
        notificado: Bool = false,
        duracionMinutos: Int64? = nil,
        llegadaReal: Date? = nil,
        llegadaEstimada: Date? = nil,
        origenCreacion: String = "app",
        cierreAutomatico: Bool? = nil
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.jornada = jornada
        self.origen = origen
        self.destino = destino
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.status = status
        self.inicioProgramado = inicioProgramado
        self.inicioReal = inicioReal
        self.finReal = finReal
        self.kmEmpresa = kmEmpresa
        self.kmAuto = kmAuto
        self.turno = turno
        self.tipoServicio = tipoServicio
        self.acoplado = acoplado
        self.acopladoKm = acopladoKm
        self.coche = coche
        self.tomeCese = tomeCese
        self.syncStatus = syncStatus
        self.asignadoPorAdmin = asignadoPorAdmin
        self.notificado = notificado
        self.duracionMinutos = duracionMinutos
        self.llegadaReal = llegadaReal
        self.llegadaEstimada = llegadaEstimada
        self.origenCreacion = origenCreacion
        self.cierreAutomatico = cierreAutomatico
    }
}
