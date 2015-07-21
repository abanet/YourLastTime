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
        // la descripción no puede llevar comillas simples que lia al sqlite y da error
        let descripcionSinComillasSimples = evento.stringByReplacingOccurrencesOfString("'", withString: "''", options: .LiteralSearch, range: nil)
        if database.open(){
            let insertSQL = "INSERT INTO EVENTOS (DESCRIPCION, FECHA, HORA, CONTADOR, ARCHIVADO, CANTIDAD, PERIODO) VALUES ('\(descripcionSinComillasSimples)', '\(fecha.fecha)', '\(fecha.hora)', 0, 0, 0, 0)"
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
    
    func addOcurrencia(idEvento: String, descripcion: String) {
        let fecha = Fecha()
        // la descripción no puede llevar comillas simples que lia al sqlite y da error
        let descripcionSinComillasSimples = descripcion.stringByReplacingOccurrencesOfString("'", withString: "''", options: .LiteralSearch, range: nil)
        if database.open(){
            let selectSQL = "INSERT INTO OCURRENCIAS (IDEVENTO, FECHA, HORA, DESCRIPCION) VALUES ('\(idEvento)', '\(fecha.fecha)', '\(fecha.hora)', '\(descripcionSinComillasSimples)')"
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
            let selectSQL = "SELECT ID, DESCRIPCION, FECHA, HORA, CONTADOR, CANTIDAD, PERIODO, ARCHIVADO FROM EVENTOS"
            let resultados: FMResultSet? = database.executeQuery(selectSQL, withArgumentsInArray: nil)
            while resultados?.next() == true {
                var unEvento: Evento = Evento(id: resultados!.stringForColumn("ID"),
                                            descripcion: resultados!.stringForColumn("DESCRIPCION")!,
                                            fecha: resultados!.stringForColumn("FECHA"),
                                            hora: resultados!.stringForColumn("HORA"),
                                            contador: Int(resultados!.intForColumn("CONTADOR")),
                                            cantidad: Int(resultados!.intForColumn("CANTIDAD")),
                                            periodo: PeriodoTemporal(rawValue:Int(resultados!.intForColumn("PERIODO"))))
                arrayResultado.append(unEvento)
            }
        } else {
            // problemas al abrir la bbdd
        }
        arrayResultado.sort({(e1: Evento, e2: Evento) in
            let fecha1NSDate: NSDate = Fecha().fechaCompletaStringToDate(e1.fecha+e1.hora)
            let fecha2NSDate: NSDate = Fecha().fechaCompletaStringToDate(e2.fecha+e2.hora)
            return fecha1NSDate.isGreaterThanDate(fecha2NSDate)
        })
        return  arrayResultado//arrayResultado.reverse() // los más nuevos primero
    }
    
    func arrayOcurrencias(idEvento:String)->[Ocurrencia] {
        var arrayResultado = [Ocurrencia]()
        if database.open() {
            let selectSQL = "SELECT IDEVENTO, FECHA, HORA, DESCRIPCION FROM OCURRENCIAS WHERE IDEVENTO = '\(idEvento)'"
            let resultados: FMResultSet? = database.executeQuery(selectSQL, withArgumentsInArray: nil)
            while resultados?.next() == true {
                var unaOcurrencia: Ocurrencia = Ocurrencia(idEvento: resultados!.stringForColumn("IDEVENTO"), fecha: resultados!.stringForColumn("FECHA"), hora: resultados!.stringForColumn("HORA"), descripcion: resultados!.stringForColumn("DESCRIPCION"))
                arrayResultado.append(unaOcurrencia)
            }
        } else {
            // problemas al abrir la bbdd
        }
        return arrayResultado.reverse() // los más nuevos primero
    }
    
    func tieneOcurrenciasElEvento(idEvento:String)->Bool {
        return arrayOcurrencias(idEvento).count != 0
    }
    
    func encontrarEvento(idEvento: String)->Evento?{
        if database.open() {
            let selectSQL = "SELECT DESCRIPCION, FECHA, HORA, CONTADOR, CANTIDAD, PERIODO FROM EVENTOS WHERE ID                                               = '\(idEvento)'"
            let resultado: FMResultSet? = database.executeQuery(selectSQL, withArgumentsInArray: nil)
            if resultado!.next() {
                let eventoFinal = Evento(id: idEvento,
                    descripcion: resultado!.stringForColumn("DESCRIPCION"),
                    fecha: resultado!.stringForColumn("FECHA"),
                    hora: resultado!.stringForColumn("HORA"),
                    contador: Int(resultado!.intForColumn("CONTADOR")),
                    cantidad: Int(resultado!.intForColumn("CANTIDAD")),
                    periodo: PeriodoTemporal(rawValue: Int(resultado!.intForColumn("PERIODO")))
                )
                return eventoFinal
            }
        }
        return nil
    }
    
    func contarOcurrenciasSemanaMesAnno(idEvento: String) -> (Int, Int, Int) {
        var resultado = (ultimaSemana: 0, ultimoMes: 0, ultimoAnno: 0)
        
        var arrayOcurrencias = self.arrayOcurrencias(idEvento)
        let fecha = Fecha()
        if arrayOcurrencias.count != 0 {
            // Los más nuevos vienen primero
            for ocurrencia in arrayOcurrencias {
                if fecha.estaEnUltimaSemana(ocurrencia.fecha) {
                    resultado.ultimaSemana++
                }
                if fecha.estaEnUltimoMes(ocurrencia.fecha){
                    resultado.ultimoMes++
                }
                if fecha.estaEnUltimoAnno(ocurrencia.fecha){
                    resultado.ultimoAnno++
                } else {break}
            }
        }
        return resultado
    }

    func arrayAlarmasEventos() -> [Evento] {
        var arrayResultado = [Evento]()
        if database.open() {
            let selectSQL = "SELECT ID, DESCRIPCION, FECHA, HORA, CANTIDAD, PERIODO FROM EVENTOS WHERE CANTIDAD>0"
            let resultados: FMResultSet? = database.executeQuery(selectSQL, withArgumentsInArray: nil)
             while resultados?.next() == true {
                let eventoConAlarma = Evento(id: resultados!.stringForColumn("ID"),
                    descripcion: resultados!.stringForColumn("DESCRIPCION"),
                    fecha: resultados!.stringForColumn("FECHA"),
                    hora: resultados!.stringForColumn("HORA"),
                    contador: Int(resultados!.intForColumn("CONTADOR")),
                    cantidad: Int(resultados!.intForColumn("CANTIDAD")),
                    periodo: PeriodoTemporal(rawValue: Int(resultados!.intForColumn("PERIODO"))))
                arrayResultado.append(eventoConAlarma)
            }
        }
        return arrayResultado
    }
    
    
    func establecerAlarma(idEvento:String, cantidad: Int, periodo: PeriodoTemporal) -> Bool {
        if database.open(){
            
            let updateSQL = "UPDATE EVENTOS SET CANTIDAD = '\(cantidad)', PERIODO = '\(periodo.rawValue)' WHERE ID = '\(idEvento)'"
            println("updateAlarma: \(updateSQL)")
            let resultado = database.executeUpdate(updateSQL, withArgumentsInArray: nil)
            println("resultado de actualizar alarma en eventos: \(resultado)")
            return resultado
        }
        return false
    }
    
    func eliminarAlarma(idEvento:String)->Bool {
        return establecerAlarma(idEvento,  cantidad: 0,  periodo: PeriodoTemporal.horas)
    }
    
    func tieneAlarma(evento:Evento) -> Bool {
        if evento.cantidad > 0 {
            return true
        }
        return false
    }
   
}
