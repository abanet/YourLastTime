//
//  Evento.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 9/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices
import Intents

public let kNewEventActivityType = "es.codigoswift.NewEvent"

class Evento: NSObject {
    var id: String
    var descripcion: String
    var fecha: String
    var hora: String
    var contador: Int
    var archivado: Bool
    var cantidad: Int   // unidades de la alarma establecida
    var periodo: PeriodoTemporal // hora, día, mes, año
    
    
//    @available(iOS 12.0, *)
//    public static func newEventShortcut(thumbnail: UIImage?) -> NSUserActivity {
//        let activity = NSUserActivity(activityType: kNewEventActivityType)
//        activity.persistentIdentifier =
//            NSUserActivityPersistentIdentifier(kNewEventActivityType)
//        activity.isEligibleForSearch = true
//        activity.isEligibleForPrediction = true
//        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
//        activity.title = NSLocalizedString("New Event", comment: "")
//        attributes.contentDescription = NSLocalizedString("Add a new event to Last Time!", comment: "")
//        attributes.thumbnailData = thumbnail?.jpegData(compressionQuality: 1.0)
//        activity.suggestedInvocationPhrase = NSLocalizedString("Create a new event!", comment: "")
//        activity.contentAttributeSet = attributes
//        return activity
//    }
    
    init(id:String, descripcion:String, fecha:String, hora: String, contador:Int, cantidad: Int = 0, periodo: PeriodoTemporal = .dias, archivado: Bool = false) {
        self.id = id
        self.descripcion = descripcion
        self.fecha = fecha
        self.hora = hora
        self.contador = contador
        self.archivado = archivado
        self.cantidad = cantidad
        self.periodo = periodo
    }
    
    func fechaUltimaOcurrencia()->Date {
        return Fecha().fechaCompletaStringToDate(self.fecha + self.hora)
    }
    
    func intervaloAlarmaEnHoras()->TimeInterval {
        let horas = periodo.numHoras
        return TimeInterval(cantidad * horas)
    }
    
    func intervaloParaProgramarAlarma() -> TimeInterval? {
        let segundosPasados = (Date().timeIntervalSince1970 - fechaUltimaOcurrencia().timeIntervalSince1970)
        let segundosAlarma = TimeInterval(intervaloAlarmaEnHoras() * 60 * 60)
        let segundosRestantes = segundosAlarma - segundosPasados
        if segundosRestantes > 0 {
            return segundosRestantes
        } else {
            return nil
        }
    }
    
    // Devuelve un string descriptivo de cuanto tiempo ha pasado desde la fecha y hora del evento
    func cuantoTiempoHaceDesdeLaUltimaVez()->String {
        let fechaEvento = Fecha().fechaCompletaStringToDate(self.fecha + self.hora)
        // Usamos Fecha pq formatea en la misma zona. Usando Date directamente la hora que da son 2 horas menos...
        let intervalo = Fecha(date:Date(timeIntervalSinceNow: 0)).fechaCompletaStringToDate().timeIntervalSince(fechaEvento) //
        
        let ti = NSInteger(intervalo)
        let minutos = (ti / 60) % 60
        let horas = (ti / 3600) % 24
        let dias  = (ti / (3600 * 24)) % 30
        let meses = (ti / (3600 * 24 * 30)) % 12
        let annos = (ti / (3600 * 24 * 30 * 12))
        
        
        let stringAnnos = annos == 1 ? NSLocalizedString("year", comment:"") :NSLocalizedString("years", comment:"")
        let stringMeses = meses == 1 ? NSLocalizedString("month", comment:"") :NSLocalizedString("months", comment:"")
        let stringDias  = dias ==  1 ? NSLocalizedString("day", comment:"") :NSLocalizedString("days", comment:"")
        let stringHoras  = horas ==  1 ? NSLocalizedString("hour", comment:"") :NSLocalizedString("hours", comment:"")
        let stringMinutos  = minutos ==  1 ? NSLocalizedString("minute", comment:"") :NSLocalizedString("minutes", comment:"")
        var text = "" //NSLocalizedString("Ago: ", comment:"")
        if annos != 0 {
            text = String(annos) + " " + stringAnnos + ", " + String(meses) + " " + stringMeses + ", " + String(dias) + " " + stringDias //+ "."
        } else {
            if meses != 0 {
                text =  String(meses) + " " + stringMeses + ", " + String(dias) + " " + stringDias + ", " + String(horas) + " " + stringHoras //+ "."
            } else {
                if dias != 0 {
                    text =  String(dias) + " " + stringDias + ", " + String(horas) + " " + stringHoras + ", " + String(minutos) + " " + stringMinutos //+ "."
                } else {
                    if horas != 0 {
                        text =  String(horas) + " " + stringHoras + ", " + String(minutos) + " " + stringMinutos //+ "."
                    } else {
                        if minutos != 0 {
                            text =  String(minutos) + " " + stringMinutos //+ "."
                        } else {
                            return NSLocalizedString("¡Acaba de ocurrir!", comment: "")
                        }
                    }
                }
            }
        }
      
      
        //return NSLocalizedString("Ago: ", comment:"") + text
        return String.localizedStringWithFormat(NSLocalizedString("Hace+tiempo", comment: ""), text)
    }
    
    func descripcionAlarma() -> String {
        return String(self.cantidad) + self.periodo.abreviatura()
    }

    func tieneAlarma() -> Bool {
        if cantidad > 0 {
            return true
        }
        return false
    }

    // Decide el color para un evento dato.
    // Se elige de un array de colores que indican del color dependiendo del tiempo
    // Dar más intensidad según al tiempo
    func colorParaEvento() -> UIColor? {
        let colores = [YourLastTime.colorTextoSecundario.darker(by: 10.0), YourLastTime.colorTextoSecundario.darker(by: 20.0), YourLastTime.colorTextoSecundario.darker(by: 40.0), YourLastTime.colorTextoSecundario.darker(by: 60.0), YourLastTime.colorTextoSecundario.darker(by: 80.0), UIColor.red]
        let fechaUltimaOcurrencia = self.fechaUltimaOcurrencia()
        let fechaAlarma = Date(timeInterval: self.intervaloAlarmaEnHoras() * 60 * 60, since: fechaUltimaOcurrencia)
        let ahora = Fecha(date:Date()).fechaCompletaStringToDate()
        var indiceSector = 0
        var colorElegido: UIColor?
        let intervaloHitos = (fechaAlarma.timeIntervalSince1970 - fechaUltimaOcurrencia.timeIntervalSince1970) / Double(colores.count)
        if intervaloHitos > 0 {
            for index in 1...colores.count {
                let hitoDate = Date(timeInterval: intervaloHitos * Double(index), since: fechaUltimaOcurrencia)
                // ¿está en el intervalo?
                if ahora.isLessThanDate(hitoDate) {
                    indiceSector = index - 1
                    colorElegido = colores[index-1]
                    break
                }
            }
        } else {
            colorElegido = colores[colores.count-1] // último color que es el que marca la urgencia
        }
        return colorElegido
    }
}
