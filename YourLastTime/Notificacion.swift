//
//  Notificacion.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 13/7/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit
import UserNotifications

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
    func addLocalNotification(_ timeIntervalo:TimeInterval){
      let content = UNMutableNotificationContent()
      content.categoryIdentifier = "Categoria"
      content.title = NSString.localizedUserNotificationString(forKey:
        "Your Last Time Alarm!", arguments: nil)
      content.body = self.userInfo["descripcion"]!
      content.sound = UNNotificationSound.default
      content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
      // Deliver the notification in five seconds.
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalo, repeats: false)
      //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // debug
      let request = UNNotificationRequest(identifier: idNotificacion, content: content, trigger: trigger) // Schedule the notification.
      let center = UNUserNotificationCenter.current()
      center.add(request) { (error : Error?) in
        if let theError = error {
          print(theError)
        } else {
//            print("Eliminando alarma de base de datos")
//            let database = EventosDB()
//            database.eliminarAlarma(self.idNotificacion)
        }
      }
       
    }
    
    func cancelLocalNotification(){
       // UNUserNotificationCenter.current().removeAllPendingNotificationRequests()  // Para limpiar notificaciones haciendo pruebas
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            [unowned self](notificationRequests) in
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.idNotificacion])
            }
    }
    
    // Cambiar la fecha de notificación para añadir horas desde el momento actual.
    func reprogramarFechaNotificacion(_ intervalo: TimeInterval) {
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            [unowned self](notificationRequests) in
            var reprogramada = false
            for request in notificationRequests {
                print(request.content.userInfo["id"] as! String)
                print(self.idNotificacion)
                if (request.content.userInfo["id"] as! String) == self.idNotificacion {
                    self.userInfo = request.content.userInfo as! [String:String]
                    self.addLocalNotification(intervalo) // añadir una notificación con un id ya existente la sobreescribe.
                    reprogramada = true // se ha encontrado y se ha reprogramado
                }
            }
            if !reprogramada {
                self.addLocalNotification(intervalo)
            }
            
        }
    }
    
    
    
    
}
