//
//  Notificacion.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 13/7/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class Notificacion: NSObject {
    var idNotificacion: String
    var userInfo: [String:String]
    
    init (id:String) {
        idNotificacion = id
        userInfo = [String:String]()
    }
    
    init(id:String, info:[String:String]){
        idNotificacion = id
        userInfo = info
    }
    
    // TODO: la notificación se tiene que disparar desde la última fecha
    func addLocalNotification(horas:Int){
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Your Last Time Alarm!"
        localNotification.alertBody = self.userInfo["descripcion"]!
        localNotification.userInfo = self.userInfo //Datos sobre el evento
        let fechaDesdeAhoraHastaCumplirIntervalo = NSDate(timeIntervalSinceNow: NSTimeInterval(horas * 60 * 60))
        let fechaDeAlarma = Fecha().fechaCompletaStringToDate(self.userInfo["fecha"]! + self.userInfo["hora"]!)
        
        let intervalo = fechaDesdeAhoraHastaCumplirIntervalo.timeIntervalSinceDate(fechaDeAlarma)
        if intervalo > 0 {
            localNotification.fireDate = NSDate(timeIntervalSinceNow: intervalo)
            //localNotification.fireDate = NSDate(timeIntervalSinceNow: 20) // 20 segundos para probar
            localNotification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        } else {
            // Se ha puesto una alarma para un plazo que ya pasó.
            // Notificar??
        }
    }
    
    func cancelLocalNotification(){
       // var notifyCancel = UILocalNotification()
        //UIApplication.sharedApplication().cancelAllLocalNotifications() // Para limpiar notificaciones haciendo pruebas
        let notifyArray = UIApplication.sharedApplication().scheduledLocalNotifications
        print(notifyArray)
        for notifyCancel in notifyArray! {
            let info: [String: String] = notifyCancel.userInfo as! [String: String]
            if info["id"] == self.idNotificacion{
                UIApplication.sharedApplication().cancelLocalNotification(notifyCancel)
                //break comentamos para que se borren todas las alarmas de ese id
            }else{
                print("No Local Notification Found!")
            }
        }
    }
    
    // Cambiar la fecha de notificación para añadir horas desde el momento actual.
    func reprogramarFechaNotificacion(horas:Int) {
        let notificacionArray = UIApplication.sharedApplication().scheduledLocalNotifications
        for notificacion in notificacionArray!  {
            let info: [String:String] = notificacion.userInfo as! [String:String]
            if info["id"] == self.idNotificacion {
                // Notificación encontrada. Cambiamos su fireDate
                notificacion.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(horas * 60 * 60))
                print("Reprogramación realizada. Nueva fecha: \(notificacion.fireDate)")
                break
            }
        }
        
    }
    
    
    
    
}
