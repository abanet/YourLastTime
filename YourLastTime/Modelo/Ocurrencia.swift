//
//  Ocurrencia.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 10/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class Ocurrencia: NSObject {
  private (set) var idOcurrencia: String
    var idEvento: String
    var fecha: String
    var hora: String
    var descripcion: String
    
  init(idOcurrencia: String, idEvento:String, fecha:String, hora: String, descripcion: String) {
        self.idOcurrencia = idOcurrencia
        self.idEvento = idEvento
        self.fecha = fecha
        self.hora = hora
        self.descripcion = descripcion
    }
    
  init(idOcurrencia:String, idEvento:String, fecha:String) {
        self.idOcurrencia = idOcurrencia
        self.idEvento = idEvento
        self.fecha = fecha
        self.hora = ""
        self.descripcion = ""
    }
    
    // Momento de la ocurrencia en formato MM-dd-YYYYHH:mm
    // Utilizada para el cálculo de las diferencias entre ocurrencias
    func formatoMMddYYYYHHmm () -> String {
        return "\(fecha)\(hora)"
    }
    
    class func mediaOcurrencias(ocurrencia1: Ocurrencia, ocurrencia2: Ocurrencia, numOcurrencias: Int)-> String {
        let fechaOcurrencia1String = ocurrencia1.formatoMMddYYYYHHmm()
        let fechaOcurrencia1Date = Fecha().fechaCompletaStringToDate(fechaOcurrencia1String)
        let fechaOcurrencia2String = ocurrencia2.formatoMMddYYYYHHmm()
        let fechaOcurrencia2Date = Fecha().fechaCompletaStringToDate(fechaOcurrencia2String)
        let intervalo = fechaOcurrencia2Date.timeIntervalSince(fechaOcurrencia1Date) // número de segundos de diferencia
        let media = intervalo / Double(numOcurrencias - 1)
    
        return Fecha().stringFromTimeInterval(interval: media)
    }
    
}
