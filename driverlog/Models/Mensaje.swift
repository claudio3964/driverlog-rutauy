//
//  Mensaje.swift
//  driverlog
//
//  No existe como @Entity de Room en el proyecto Android hermano: ahí los mensajes se leen
//  al vuelo como JSONObject desde Supabase (MensajesPollingWorker) y nunca se persisten
//  localmente. Este modelo reconstruye la forma de la tabla `mensajes` de Supabase para
//  poder persistirla en el dispositivo. `dataJSON` guarda el payload jsonb crudo porque su
//  forma cambia según `tipo` (asignacion/guardia/editar_guardia/cancelar_viaje/sync_jornada/
//  mensaje/urgente); se decodifica en la capa de repositorio, no acá.
//

import Foundation
import SwiftData

@Model
final class Mensaje {
    @Attribute(.unique) var id: Int
    var de: String
    var para: String
    var tipo: String
    var dataJSON: Data
    var leido: Bool
    var respuesta: String?
    var cerrado: Bool
    var cerradoPor: String?
    var cerradoAt: Date?
    var creadoAt: Date

    init(
        id: Int,
        de: String,
        para: String,
        tipo: String,
        dataJSON: Data,
        leido: Bool = false,
        respuesta: String? = nil,
        cerrado: Bool = false,
        cerradoPor: String? = nil,
        cerradoAt: Date? = nil,
        creadoAt: Date = .now
    ) {
        self.id = id
        self.de = de
        self.para = para
        self.tipo = tipo
        self.dataJSON = dataJSON
        self.leido = leido
        self.respuesta = respuesta
        self.cerrado = cerrado
        self.cerradoPor = cerradoPor
        self.cerradoAt = cerradoAt
        self.creadoAt = creadoAt
    }
}
