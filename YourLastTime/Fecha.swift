//
//  Fecha.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 9/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class Fecha: NSObject, Equatable, Comparable {
    var fecha: String
    var hora: String
    
    override init(){
        let date = NSDate()
        let formateador = NSDateFormatter()
        // El formateador de fecha lo mantenemos siempre a MM-dd-yyy para guardarlo en el mismo formato en la bbdd
        formateador.dateFormat = "MM-dd-yyyy" //NSLocalizedString("MM-dd-yyyy", comment: "Formato de fecha")
        fecha = formateador.stringFromDate(date)
        formateador.dateFormat = "HH:mm"
        hora = formateador.stringFromDate(date)
        super.init()
    }
    
    func devolverFechaLocalizada(fecha: String)-> String?{
        var formateador = NSDateFormatter()
        // se guardó en formato MM-dd-yyyy
        formateador.dateFormat = "MM-dd-yyyy"
        let date = formateador.dateFromString(fecha)
        // formato en el que mostraremos la fecha
        formateador.dateFormat = NSLocalizedString("MM-dd-yyyy", comment: "Formato de fecha")
        return formateador.stringFromDate(date!)
    }
    
    func fechaStringToDate(fecha: String)->NSDate{
        // IMPORTANTE: Se supone que el formato en que se pasa la fecha es el original en el que está grabada.
        let formateador = NSDateFormatter()
        formateador.dateFormat = "MM-dd-yyyy"
        let fechaTemp = formateador.dateFromString(fecha)
        return fechaTemp!
    }
    
    func estaEnUltimosXdias(fecha:String, dias: Int)->Bool{
        
        let formateador = NSDateFormatter()
        formateador.dateFormat = "MM-dd-yyyy"
        let fechaNSDate = formateador.dateFromString(fecha)
        let intervaloXdias: NSTimeInterval = intervalo(dias)
        let fechaHaceXdias = NSDate(timeInterval: -intervaloXdias, sinceDate: self.fechaStringToDate(self.fecha))
        if fechaHaceXdias.isLessThanDate(fechaNSDate!){
            return true
        }
        return false
    }
    
    func estaEnUltimaSemana(fecha:String)->Bool {
        return estaEnUltimosXdias(fecha, dias: 7)
    }
    
    func estaEnUltimoMes(fecha:String)->Bool {
        return estaEnUltimosXdias(fecha, dias: 30)
    }
    
    func estaEnUltimoAnno(fecha:String)->Bool {
        return estaEnUltimosXdias(fecha, dias: 365)
    }
    
    private func intervalo(dias:Int)->NSTimeInterval {
        return NSTimeInterval(dias * 24 * 60 * 60)
    }
    
    
}

// MARK: Protocolo Equatable
// Dos fechas son iguales si el día, mes y año son el mismo. Despreciamos la hora.
func ==(lhs: Fecha, rhs: Fecha) -> Bool {
    if lhs.fecha == rhs.fecha {
        return true
    } else {
        return false
    }
}

// MARK: Protocolo Comparable
func <(lhs: Fecha, rhs: Fecha) -> Bool {
    let lhsDate = lhs.fechaStringToDate(lhs.fecha)
    let rhsDate = rhs.fechaStringToDate(rhs.fecha)
    if lhsDate.isLessThanDate(rhsDate) {
        return true
    } else {
        return false
    }
}

func >(lhs: Fecha, rhs: Fecha) -> Bool {
    let lhsDate = lhs.fechaStringToDate(lhs.fecha)
    let rhsDate = rhs.fechaStringToDate(rhs.fecha)
    if lhsDate.isGreaterThanDate(rhsDate) {
        return true
    } else {
        return false
    }
}