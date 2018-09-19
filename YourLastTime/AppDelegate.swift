//
//  AppDelegate.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 8/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var categoryID:String {
        get{
            return "OK_CATEGORY"
        }
    }
    
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Activamos estadísticas
        GATracker.setup(tid: "UA-87790452-1") // id de GA para cronoTask (cuenta alberto.banet)
        GATracker.sharedInstance.screenView(screenName: "Sesiones Abiertas YourLastTime", customParameters: nil)
        // Registramos notificaciones locales
        if(UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:))))
        {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: []))
        }
        
        
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
        registerNotification()
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        print("notification is here. Open alert window or whatever")
        //let alerta = AlertaVC()
        //window?.addSubview(alerta.view)
        
        // Handle notification action *****************************************
        if notification.category == categoryID {
            //No hacemos nada. De momento sólo es para ver si muestra la acción.
        }
        // Abrir alerta notificando alarma
        // Desactivar alarma de la base de datos
        let database = EventosDB()
        let info: [String: String] = notification.userInfo as! [String: String]
        if let identificador = info["id"] {
            database.eliminarAlarma(identificador)
        }
        
        // Must be called when finished
        completionHandler()
    }
    
    // Register notification settings
    func registerNotification() {
        // 1. Create the actions
        // reset Action
        let okAction = UIMutableUserNotificationAction()
        okAction.identifier = "Ok"
        okAction.title = "OK"
        okAction.activationMode = UIUserNotificationActivationMode.foreground
        // NOT USED resetAction.authenticationRequired = true
        okAction.isDestructive = true
        
        
        // 2. Create the category
        
        // Category
        let counterCategory = UIMutableUserNotificationCategory()
        counterCategory.identifier = categoryID
        
        // A. Set actions for the default context
        counterCategory.setActions([okAction],
            for: UIUserNotificationActionContext.default)
        
        // B. Set actions for the minimal context
        counterCategory.setActions([okAction],
            for: UIUserNotificationActionContext.minimal)
    }

}

