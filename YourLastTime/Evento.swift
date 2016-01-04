//
//  Evento.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 9/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class Evento: NSObject {
    var id: String
    var descripcion: String
    var fecha: String
    var hora: String
    var contador: Int
    var archivado: Bool
    var cantidad: Int
    var periodo: PeriodoTemporal
    
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
    
    func fechaUltimaOcurrencia()->NSDate {
        return Fecha().fechaCompletaStringToDate(self.fecha + self.hora)
    }
    
    func intervaloAlarmaEnHoras()->NSTimeInterval {
        let horas = periodo.numHoras
        return NSTimeInterval(cantidad * horas)
    }
    
    // Devuelve un string descriptivo de cuanto tiempo ha pasado desde la fecha y hora del evento
    func cuantoTiempoHaceDesdeLaUltimaVez()->String {
        let fechaEvento = Fecha().fechaCompletaStringToDate(self.fecha + self.hora)
        let intervalo = NSDate(timeIntervalSinceNow: 0).timeIntervalSinceDate(fechaEvento)
        
        let ti = NSInteger(intervalo)
        let minutos = (ti / 60) % 60
        let horas = (ti / 3600) % 24
        let dias  = (ti / (3600 * 24)) % 30
        let meses = (ti / (3600 * 24 * 30)) % 12
        let annos = (ti / (3600 * 24 * 365))
        
        
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
                            text = "- - -"
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

}
