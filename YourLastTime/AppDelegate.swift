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
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Registramos notificaciones locales
        
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:")))
        {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: nil))
        }
        
        
        // Si es la primera vez creamos la base de datos
        let yaentre = NSUserDefaults.standardUserDefaults().boolForKey("yaentre")
        if yaentre {
            println ("no es la primera vez")
        } else {
            println ("primera vez")
            // Creamos la base de datos
            let filemgr = NSFileManager.defaultManager()
            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docsDir = dirPaths[0] as! String
            
            let databasePath = docsDir.stringByAppendingPathComponent("YourLastTime.db")
            println("bbdd en " + databasePath)
            // Borramos el fichero por si existe (parece como si pese a borrar la app los datos se quedasen)
            filemgr.removeItemAtPath(databasePath, error: nil)
            
            if !filemgr.fileExistsAtPath(databasePath as String) {
                
                let contactDB = FMDatabase(path: databasePath as String)
                
                if contactDB == nil {
                    println("Error: \(contactDB.lastErrorMessage())")
                }
                
                // TODO: añadir campos posición y archivado en tabla de eventos.
                // posición: indicará la posición a ocupar en la visualización de la tabla (se usaría en un futuro si se permite reordenación de la tabla)
                // archivado: indica si se ha archivado o no el evento
                // Dias: en caso de ser != 0 establece una alarma para avisar de que hace más de x días que no se ha ocurrido un evento.
                if contactDB.open() {
                    // tabla de eventos
                    let sql_crear_eventos = "CREATE TABLE IF NOT EXISTS EVENTOS (ID INTEGER PRIMARY KEY AUTOINCREMENT, DESCRIPCION TEXT, FECHA TEXT, HORA TEXT, CONTADOR INTEGER, ARCHIVADO INTEGER, CANTIDAD INTEGER, PERIODO INTEGER)"
                    if !contactDB.executeStatements(sql_crear_eventos) {
                        println("Error: \(contactDB.lastErrorMessage())")
                    }
                    // tabla de ocurrencias
                    let sql_crear_ocurrencias = "CREATE TABLE IF NOT EXISTS OCURRENCIAS (ID INTEGER PRIMARY KEY AUTOINCREMENT, IDEVENTO INTEGER, FECHA TEXT, HORA TEXT, DESCRIPCION TEXT)"
                    if !contactDB.executeStatements(sql_crear_ocurrencias) {
                        println("Error: \(contactDB.lastErrorMessage())")
                    }
                    contactDB.close()
                    // nos aseguramos de q no se vuelva a crear
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "yaentre")
                } else {
                    println("Error: \(contactDB.lastErrorMessage())")
                }
            }
            
            
        }
        registerNotification()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        println("notification is here. Open alert window or whatever")
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
        okAction.activationMode = UIUserNotificationActivationMode.Foreground
        // NOT USED resetAction.authenticationRequired = true
        okAction.destructive = true
        
        
        // 2. Create the category
        
        // Category
        let counterCategory = UIMutableUserNotificationCategory()
        counterCategory.identifier = categoryID
        
        // A. Set actions for the default context
        counterCategory.setActions([okAction],
            forContext: UIUserNotificationActionContext.Default)
        
        // B. Set actions for the minimal context
        counterCategory.setActions([okAction],
            forContext: UIUserNotificationActionContext.Minimal)
    }

}

