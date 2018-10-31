//
//  AppDelegate.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 8/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

   
    
    let notificacionDelegate = NotificacionDelegate()
    let center = UNUserNotificationCenter.current()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Activamos estadísticas
        GATracker.setup(tid: "UA-87790452-1") // id de GA para cronoTask (cuenta alberto.banet)
        GATracker.sharedInstance.screenView(screenName: "Sesiones Abiertas YourLastTime", customParameters: nil)
    
        // Solicitamos autorización para las notificaciones
        solicitarAutorizaciónNotificaciones()
        setupNotificaciones()
        application.registerForRemoteNotifications()
        
        // Si es la primera vez creamos la base de datos
        let yaentre = UserDefaults.standard.bool(forKey: "yaentre")
        if yaentre {
            print ("no es la primera vez")
        } else {
            print ("primera vez")
            // Creamos la base de datos
            let filemgr = FileManager.default
            let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let docsDir = dirPaths[0] 
            
            let databasePath = (docsDir as NSString).appendingPathComponent("YourLastTime.db")
            print("bbdd en " + databasePath)
            // Borramos el fichero por si existe (parece como si pese a borrar la app los datos se quedasen)
            do {
                try filemgr.removeItem(atPath: databasePath)
            } catch {
                print("Error eliminando Item")
            }
            
            if !filemgr.fileExists(atPath: databasePath as String) {
                
                let contactDB = FMDatabase(path: databasePath as String)
                
                if contactDB == nil {
                    print("Error: \(contactDB?.lastErrorMessage())")
                }
                
                // TODO: añadir campos posición y archivado en tabla de eventos.
                // posición: indicará la posición a ocupar en la visualización de la tabla (se usaría en un futuro si se permite reordenación de la tabla)
                // archivado: indica si se ha archivado o no el evento
                // Dias: en caso de ser != 0 establece una alarma para avisar de que hace más de x días que no se ha ocurrido un evento.
                if (contactDB?.open())! {
                    // tabla de eventos
                    let sql_crear_eventos = "CREATE TABLE IF NOT EXISTS EVENTOS (ID INTEGER PRIMARY KEY AUTOINCREMENT, DESCRIPCION TEXT, FECHA TEXT, HORA TEXT, CONTADOR INTEGER, ARCHIVADO INTEGER, CANTIDAD INTEGER, PERIODO INTEGER)"
                    if !(contactDB?.executeStatements(sql_crear_eventos))! {
                        print("Error: \(contactDB?.lastErrorMessage())")
                    }
                    // tabla de ocurrencias
                    let sql_crear_ocurrencias = "CREATE TABLE IF NOT EXISTS OCURRENCIAS (ID INTEGER PRIMARY KEY AUTOINCREMENT, IDEVENTO INTEGER, FECHA TEXT, HORA TEXT, DESCRIPCION TEXT)"
                    if !(contactDB?.executeStatements(sql_crear_ocurrencias))! {
                        print("Error: \(contactDB?.lastErrorMessage())")
                    }
                    contactDB?.close()
                    // nos aseguramos de q no se vuelva a crear
                    UserDefaults.standard.set(true, forKey: "yaentre")
                } else {
                    print("Error: \(contactDB?.lastErrorMessage())")
                }
            }
            
            
        }
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        // Al entrar eliminamos el badge number
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
  
    func setupNotificaciones() {
        let action = UNNotificationAction(identifier: "Ok", title: "Ok", options: [])
        let category = UNNotificationCategory(identifier: "Categoria",actions: [action], intentIdentifiers:[],options:[])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    
    func solicitarAutorizaciónNotificaciones() {
        let center = UNUserNotificationCenter.current()
        center.delegate = notificacionDelegate
        let options: UNAuthorizationOptions = [.sound, .alert, .badge]
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Algo fue mal con las notificaciones")
            }
        }
    }

}

