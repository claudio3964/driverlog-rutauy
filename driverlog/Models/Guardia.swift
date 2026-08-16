//
//  Guardia.swift
//  driverlog
//
//  Espeja la entidad Room `Guardia` (tabla `guardias`) del proyecto Android hermano.
//

import Foundation
import SwiftData

@Model
final class Guardia {
    @Attribute(.unique) var id: String
    var dia: String
    var inicio: String
    var fin: String
    var type: String
    var hours: Double
    var status: String
    var viatico: Bool
    var kmGuardia: Double
    var asignadoPorAdmin: Bool
    var orderNumber: String
    var jornada: Jornada?
    var createdAt: Date
    var descripcion: String?

    init(
        id: String,
        dia: String = "",
        inicio: String = "",
        fin: String = "",
        type: String = "comun",
        hours: Double = 0.0,
        status: String = "en_curso",
        viatico: Bool = false,
        kmGuardia: Double = 0.0,
        asignadoPorAdmin: Bool = false,
        orderNumber: String = "",
        jornada: Jornada? = nil,
        createdAt: Date = .now,
        descripcion: String? = nil
    ) {
        self.id = id
        self.dia = dia
        self.inicio = inicio
        self.fin = fin
        self.type = type
        self.hours = hours
        self.status = status
        self.viatico = viatico
        self.kmGuardia = kmGuardia
        self.asignadoPorAdmin = asignadoPorAdmin
        self.orderNumber = orderNumber
        self.jornada = jornada
        self.createdAt = createdAt
        self.descripcion = descripcion
    }
}
