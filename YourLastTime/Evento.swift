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
    
    
    func tieneAlarma() -> Bool {
        if cantidad > 0 {
            return true
        }
        return false
    }

}
