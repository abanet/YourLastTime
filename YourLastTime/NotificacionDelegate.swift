//
//  NotificationDelegateLT.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 29/10/2018.
//  Copyright © 2018 abanet. All rights reserved.
//
import UIKit
import UserNotifications

class NotificacionDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Se elimina la alarma de la bbdd
        print("Notification willPresent: queremos borrar alarma de bbdd")
//        let database = EventosDB()
//        database.eliminarAlarma(notification.request.identifier)
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadEventsTable"), object: nil)
         
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
        case "Delete":
            print("Delete")
        default:
            print("Unknown action")
        }
        completionHandler()
    }
    
    
}
