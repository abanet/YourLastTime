//
//  EventosDB.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 8/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class EventosDB: NSObject {
    
    let databasePath: String
    let database: FMDatabase
    
    override init(){
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        databasePath = docsDir.stringByAppendingPathComponent("YourLastTime.db")
        
        database = FMDatabase(path: databasePath)
        database.logsErrors = true
    }
    
    func addEvento(evento:String){
        let fecha = Fecha()
        if database.open(){
            let insertSQL = "INSERT INTO EVENTOS (DESCRIPCION, FECHA, HORA, CONTADOR) VALUES ('\(evento)', '\(fecha.fecha)', '\(fecha.hora)', 1)"
            println("addEvento: \(insertSQL)")
            let resultado = database.executeUpdate(insertSQL, withArgumentsInArray: nil)
            
            if !resultado {
                println("Error: \(database.lastErrorMessage())")
            } else {
                println("Evento añadido")
            }
        } else {
            println("Error abriendo bbdd: \(database.lastErrorMessage())")
        }
    }
    
    // Devuelve true si el evento se ha podido eliminar
    func eliminarEvento(idEvento:String)->Bool {
        if database.open(){
            let deleteSQL = "DELETE FROM EVENTOS WHERE ID = '\(idEvento)'"
            let resultado = database.executeUpdate(deleteSQL, withArgumentsInArray: nil)
            if !resultado {
                println("Error: \(database.lastErrorMessage())")
            } else {
                return true
            }
        }
        return false
    }
    
    func addOcurrencia(idEvento: String) {
        let fecha = Fecha()
        if database.open(){
            let selectSQL = "INSERT INTO OCURRENCIAS (IDEVENTO, FECHA, HORA, DESCRIPCION) VALUES ('\(idEvento)', '\(fecha.fecha)', '\(fecha.hora)', ' ')"
            let resultado = database.executeUpdate(selectSQL, withArgumentsInArray: nil)
            if !resultado {
                println("Error: \(database.lastErrorMessage())")
            } else {
                println("Ocurrencia añadida")
                // al añadir una ocurrrencia modificamos en la tabla eventos la fecha y hora para que muestre siempre la última vez
                // Incrementamos en uno el número de ocurrencias en la tabla eventos
                let updateSQL = "UPDATE EVENTOS SET FECHA = '\(fecha.fecha)', HORA = '\(fecha.hora)', CONTADOR = CONTADOR + 1 WHERE ID = '\(idEvento)'"
                println(updateSQL)
                let resultado = database.executeUpdate(updateSQL, withArgumentsInArray: nil)
          
                
            }
        } else {
            println("Error abriendo bbdd: \(database.lastErrorMessage())")
        }
    }
    
    func eliminarOcurrencias(idEvento:String)->Bool {
        if database.open() {
            let deleteSQL = "DELETE FROM OCURRENCIAS WHERE IDEVENTO = '\(idEvento)'"
            let resultado = database.executeUpdate(deleteSQL, withArgumentsInArray: nil)
            if !resultado {
                println("Error: \(database.lastErrorMessage())")
            } else {
                return true
            }
        }
        return false
    }
    
    func arrayEventos()->[Evento] {
        var arrayResultado = [Evento]()
        if database.open() {
            let selectSQL = "SELECT ID, DESCRIPCION, FECHA, HORA, CONTADOR FROM EVENTOS"
            let resultados: FMResultSet? = database.executeQuery(selectSQL, withArgumentsInArray: nil)
            while resultados?.next() == true {
                var unEvento: Evento = Evento(id: resultados!.stringForColumn("ID"), descripcion: resultados!.stringForColumn("DESCRIPCION")!, fecha: resultados!.stringForColumn("FECHA"), hora: resultados!.stringForColumn("HORA"), contador: Int(resultados!.intForColumn("CONTADOR")))
                arrayResultado.append(unEvento)
            }
        } else {
            // problemas al abrir la bbdd
        }
        return arrayResultado.reverse() // los más nuevos primero
    }
   
}
