//
//  Fecha.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 9/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class Fecha: NSObject, Comparable {
    var fecha: String
    var hora: String
    
  
  init(fecha:String, hora: String) {
    self.fecha = fecha
    self.hora = hora
    super.init()
  }
  
  init(date:Date) {
    let formateador = DateFormatter()
    // El formateador de fecha lo mantenemos siempre a MM-dd-yyy para guardarlo en el mismo formato en la bbdd
    formateador.dateFormat = "MM-dd-yyyy" //NSLocalizedString("MM-dd-yyyy", comment: "Formato de fecha")
    formateador.timeZone = TimeZone.current //TimeZone(secondsFromGMT: 0)
    formateador.locale = Locale.current
    fecha = formateador.string(from: date)
    formateador.dateFormat = "HH:mm"
    hora = formateador.string(from: date)
    super.init()
  }
    override init(){
        let date = Date()
        let formateador = DateFormatter()
        formateador.timeZone = TimeZone.current
        formateador.locale = Locale.current
        // El formateador de fecha lo mantenemos siempre a MM-dd-yyy para guardarlo en el mismo formato en la bbdd
        formateador.dateFormat = "MM-dd-yyyy" //NSLocalizedString("MM-dd-yyyy", comment: "Formato de fecha")
        fecha = formateador.string(from: date)
        formateador.dateFormat = "HH:mm"
        hora = formateador.string(from: date)
        super.init()
    }
    
    func devolverFechaLocalizada(_ fecha: String)-> String?{
        let formateador = DateFormatter()
        formateador.timeZone = TimeZone.current //TimeZone(secondsFromGMT: 0)
        formateador.locale = Locale.current
        // se guardó en formato MM-dd-yyyy
        formateador.dateFormat = "MM-dd-yyyy"
        let date = formateador.date(from: fecha)
        // formato en el que mostraremos la fecha
        formateador.dateFormat = NSLocalizedString("MM-dd-yyyy", comment: "Formato de fecha")
        return formateador.string(from: date!)
    }
    
    func fechaStringToDate(_ fecha: String)->Date{
        // IMPORTANTE: Se supone que el formato en que se pasa la fecha es el original en el que está grabada.
        let formateador = DateFormatter()
        formateador.timeZone = TimeZone.current //TimeZone(secondsFromGMT: 0)
        formateador.locale = Locale.current
        formateador.dateFormat = "MM-dd-yyyy"
        let fechaTemp = formateador.date(from: fecha)
        return fechaTemp!
    }
  
  
    
    // fecha completa: fecha con  hora incluida.
  // Deprecate en un futuro. Usar siguiente versión.
  func fechaCompletaStringToDate(_ fechaCompleta: String) -> Date {
    let formateador = DateFormatter()
    formateador.timeZone = TimeZone.current //TimeZone(secondsFromGMT: 0) //¡¡ si no se añade esto resta dos horas!!
    print(formateador.timeZone!)
    formateador.locale = Locale.current
    formateador.dateFormat = "MM-dd-yyyyHH:mm"
    let fechaTemp = formateador.date(from: fechaCompleta)
    return fechaTemp!
  }
  
  // versión mejorada de la anterior q trabaja con los datos de la instancia
  func fechaCompletaStringToDate() -> Date {
    let formateador = DateFormatter()
     formateador.timeZone = TimeZone.current //TimeZone(secondsFromGMT: 0) //¡¡ si no se añade esto resta dos horas!!
    formateador.locale = Locale.current
    formateador.dateFormat = "MM-dd-yyyyHH:mm"
    let fechaTemp = formateador.date(from: self.fecha+self.hora)
    return fechaTemp!
  }
    
    func estaEnUltimosXdias(_ fecha:String, dias: Int)->Bool{
        let formateador = DateFormatter()
        formateador.timeZone = TimeZone.current //TimeZone(secondsFromGMT: 0)
        formateador.locale = Locale.current
        formateador.dateFormat = "MM-dd-yyyy"
        let fechaNSDate = formateador.date(from: fecha)
        let intervaloXdias: TimeInterval = intervalo(dias)
        let fechaHaceXdias = Date(timeInterval: -intervaloXdias, since: self.fechaStringToDate(self.fecha))
        if fechaHaceXdias.isLessThanDate(fechaNSDate!){
            return true
        }
        return false
    }
    
    func estaEnUltimaSemana(_ fecha:String)->Bool {
        return estaEnUltimosXdias(fecha, dias: 7)
    }
    
    func estaEnUltimoMes(_ fecha:String)->Bool {
        return estaEnUltimosXdias(fecha, dias: 30)
    }
    
    func estaEnUltimoAnno(_ fecha:String)->Bool {
        return estaEnUltimosXdias(fecha, dias: 365)
    }
    
    fileprivate func intervalo(_ dias:Int)->TimeInterval {
        return TimeInterval(dias * 24 * 60 * 60)
    }
    
    // Convertir intervalo a dias, horas, minutos segundos para sacar por pantalla.
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(abs(interval))
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600) % 24
        let days = (interval / 3600 / 24)
        
        // Dos posibles tipos de string: dia:horas:minutos si hay dias; horas:minutos:segundos si no hay días.
        if days > 0 {
           return String(format: "%02dd, %02dh:%02dm.", days, hours, minutes)
        } else {
            return String(format: "%02dh:%02dm:%02ds.",hours, minutes, seconds)
        }
    }
    
}

// MARK: Protocolo Equatable
// Dos fechas son iguales si el día, mes y año son el mismo. Despreciamos la hora.
func ==(lhs: Fecha, rhs: Fecha) -> Bool {
    if (lhs.fecha + lhs.hora) == (rhs.fecha + lhs.hora) {
        return true
    } else {
        return false
    }
}

// MARK: Protocolo Comparable
func <(lhs: Fecha, rhs: Fecha) -> Bool {
    let lhsDate = lhs.fechaCompletaStringToDate(lhs.fecha + lhs.hora)
    let rhsDate = rhs.fechaCompletaStringToDate(rhs.fecha + lhs.hora)
    if lhsDate.isLessThanDate(rhsDate) {
        return true
    } else {
        return false
    }
}

func >(lhs: Fecha, rhs: Fecha) -> Bool {
    let lhsDate = lhs.fechaCompletaStringToDate(lhs.fecha + lhs.hora)
    let rhsDate = rhs.fechaCompletaStringToDate(rhs.fecha + lhs.hora)
    if lhsDate.isGreaterThanDate(rhsDate) {
        return true
    } else {
        return false
    }
}
