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
        _ = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] 
        databasePath = (docsDir as NSString).appendingPathComponent("YourLastTime.db")
        
        database = FMDatabase(path: databasePath)
        database.logsErrors = true
    }
    
    func addEvento(_ evento:String){
        
        let fecha = Fecha()
        // la descripción no puede llevar comillas simples que lia al sqlite y da error
        let descripcionSinComillasSimples = evento.replacingOccurrences(of: "'", with: "''", options: .literal, range: nil)
        if database.open(){
            let insertSQL = "INSERT INTO EVENTOS (DESCRIPCION, FECHA, HORA, CONTADOR, ARCHIVADO, CANTIDAD, PERIODO) VALUES ('\(descripcionSinComillasSimples)', '\(fecha.fecha)', '\(fecha.hora)', 0, 0, 0, 0)"
            print("addEvento: \(insertSQL)")
            let resultado = database.executeUpdate(insertSQL, withArgumentsIn: nil)
            
            if !resultado {
                print("Error: \(database.lastErrorMessage())")
            } else {
                print("Evento añadido")
                GATracker.sharedInstance.event(category: "Eventos", action: "Nuevo evento", label:"\(descripcionSinComillasSimples)", customParameters: nil)
            }
        } else {
            print("Error abriendo bbdd: \(database.lastErrorMessage())")
        }
    }
    
    // Devuelve true si el evento se ha podido eliminar
    func eliminarEvento(_ idEvento:String, descripcion: String?)->Bool {
        if database.open(){
            let deleteSQL = "DELETE FROM EVENTOS WHERE ID = '\(idEvento)'"
            let resultado = database.executeUpdate(deleteSQL, withArgumentsIn: nil)
            if !resultado {
                print("Error: \(database.lastErrorMessage())")
            } else {
                if let descripcionEvento = descripcion {
                GATracker.sharedInstance.event(category: "Eventos", action: "Borrar evento", label:"\(descripcionEvento)", customParameters: nil)
                }
                return true
            }
        }
        return false
    }
    
    func addOcurrencia(_ idEvento: String, descripcion: String) {
        let fecha = Fecha()
        // la descripción no puede llevar comillas simples que lia al sqlite y da error
        let descripcionSinComillasSimples = descripcion.replacingOccurrences(of: "'", with: "''", options: .literal, range: nil)
        if database.open(){
            let selectSQL = "INSERT INTO OCURRENCIAS (IDEVENTO, FECHA, HORA, DESCRIPCION) VALUES ('\(idEvento)', '\(fecha.fecha)', '\(fecha.hora)', '\(descripcionSinComillasSimples)')"
            let resultado = database.executeUpdate(selectSQL, withArgumentsIn: nil)
            if !resultado {
                print("Error: \(database.lastErrorMessage())")
            } else {
                print("Ocurrencia añadida")
                // al añadir una ocurrrencia modificamos en la tabla eventos la fecha y hora para que muestre siempre la última vez
                // Incrementamos en uno el número de ocurrencias en la tabla eventos
                let updateSQL = "UPDATE EVENTOS SET FECHA = '\(fecha.fecha)', HORA = '\(fecha.hora)', CONTADOR = CONTADOR + 1 WHERE ID = '\(idEvento)'"
                print(updateSQL)
                _ = database.executeUpdate(updateSQL, withArgumentsIn: nil)
                GATracker.sharedInstance.event(category: "Ocurrencia", action: "Nueva ocurrencia", label:"\(descripcionSinComillasSimples)", customParameters: nil)    
            }
        } else {
            print("Error abriendo bbdd: \(database.lastErrorMessage())")
        }
    }
    
    func eliminarOcurrencias(_ idEvento:String)->Bool {
        if database.open() {
            let deleteSQL = "DELETE FROM OCURRENCIAS WHERE IDEVENTO = '\(idEvento)'"
            let resultado = database.executeUpdate(deleteSQL, withArgumentsIn: nil)
            if !resultado {
                print("Error: \(database.lastErrorMessage())")
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
            let resultados: FMResultSet? = database.executeQuery(selectSQL, withArgumentsIn: nil)
            while resultados?.next() == true {
                let unEvento: Evento = Evento(id: resultados!.string(forColumn: "ID"),
                                            descripcion: resultados!.string(forColumn: "DESCRIPCION")!,
                                            fecha: resultados!.string(forColumn: "FECHA"),
                                            hora: resultados!.string(forColumn: "HORA"),
                                            contador: Int(resultados!.int(forColumn: "CONTADOR")),
                                            cantidad: Int(resultados!.int(forColumn: "CANTIDAD")),
                                            periodo: PeriodoTemporal(rawValue:Int(resultados!.int(forColumn: "PERIODO"))))
                arrayResultado.append(unEvento)
            }
        } else {
            // problemas al abrir la bbdd
        }
        arrayResultado.sort(by: {(e1: Evento, e2: Evento) in
            let fecha1NSDate: Date = Fecha().fechaCompletaStringToDate(e1.fecha+e1.hora)
            let fecha2NSDate: Date = Fecha().fechaCompletaStringToDate(e2.fecha+e2.hora)
            return fecha1NSDate.isGreaterThanDate(fecha2NSDate)
        })
        return  arrayResultado//arrayResultado.reverse() // los más nuevos primero
    }
    
    func arrayOcurrencias(_ idEvento:String)->[Ocurrencia] {
        var arrayResultado = [Ocurrencia]()
        if database.open() {
            let selectSQL = "SELECT IDEVENTO, FECHA, HORA, DESCRIPCION FROM OCURRENCIAS WHERE IDEVENTO = '\(idEvento)'"
            let resultados: FMResultSet? = database.executeQuery(selectSQL, withArgumentsIn: nil)
            while resultados?.next() == true {
                let unaOcurrencia: Ocurrencia = Ocurrencia(idEvento: resultados!.string(forColumn: "IDEVENTO"), fecha: resultados!.string(forColumn: "FECHA"), hora: resultados!.string(forColumn: "HORA"), descripcion: resultados!.string(forColumn: "DESCRIPCION"))
                arrayResultado.append(unaOcurrencia)
            }
        } else {
            // problemas al abrir la bbdd
        }
        return arrayResultado.reversed() // los más nuevos primero
    }
    
    func tieneOcurrenciasElEvento(_ idEvento:String)->Bool {
        return arrayOcurrencias(idEvento).count != 0
    }
    
    func encontrarEvento(_ idEvento: String)->Evento?{
        if database.open() {
            let selectSQL = "SELECT DESCRIPCION, FECHA, HORA, CONTADOR, CANTIDAD, PERIODO FROM EVENTOS WHERE ID                                               = '\(idEvento)'"
            let resultado: FMResultSet? = database.executeQuery(selectSQL, withArgumentsIn: nil)
            if resultado!.next() {
                let eventoFinal = Evento(id: idEvento,
                    descripcion: resultado!.string(forColumn: "DESCRIPCION"),
                    fecha: resultado!.string(forColumn: "FECHA"),
                    hora: resultado!.string(forColumn: "HORA"),
                    contador: Int(resultado!.int(forColumn: "CONTADOR")),
                    cantidad: Int(resultado!.int(forColumn: "CANTIDAD")),
                    periodo: PeriodoTemporal(rawValue: Int(resultado!.int(forColumn: "PERIODO")))
                )
                return eventoFinal
            }
        }
        return nil
    }
    
    func contarOcurrenciasSemanaMesAnno(_ idEvento: String) -> (Int, Int, Int) {
        var resultado = (ultimaSemana: 0, ultimoMes: 0, ultimoAnno: 0)
        
        let arrayOcurrencias = self.arrayOcurrencias(idEvento)
        let fecha = Fecha()
        if arrayOcurrencias.count != 0 {
            // Los más nuevos vienen primero
            for ocurrencia in arrayOcurrencias {
                if fecha.estaEnUltimaSemana(ocurrencia.fecha) {
                    resultado.ultimaSemana += 1
                }
                if fecha.estaEnUltimoMes(ocurrencia.fecha){
                    resultado.ultimoMes += 1
                }
                if fecha.estaEnUltimoAnno(ocurrencia.fecha){
                    resultado.ultimoAnno += 1
                } else {break}
            }
        }
        return resultado
    }

    func arrayAlarmasEventos() -> [Evento] {
        var arrayResultado = [Evento]()
        if database.open() {
            let selectSQL = "SELECT ID, DESCRIPCION, FECHA, HORA, CANTIDAD, PERIODO FROM EVENTOS WHERE CANTIDAD>0"
            let resultados: FMResultSet? = database.executeQuery(selectSQL, withArgumentsIn: nil)
             while resultados?.next() == true {
                let eventoConAlarma = Evento(id: resultados!.string(forColumn: "ID"),
                    descripcion: resultados!.string(forColumn: "DESCRIPCION"),
                    fecha: resultados!.string(forColumn: "FECHA"),
                    hora: resultados!.string(forColumn: "HORA"),
                    contador: Int(resultados!.int(forColumn: "CONTADOR")),
                    cantidad: Int(resultados!.int(forColumn: "CANTIDAD")),
                    periodo: PeriodoTemporal(rawValue: Int(resultados!.int(forColumn: "PERIODO"))))
                arrayResultado.append(eventoConAlarma)
            }
        }
        return arrayResultado
    }
    
    
    func establecerAlarma(_ idEvento:String, cantidad: Int, periodo: PeriodoTemporal) -> Bool {
        if database.open(){
            
            let updateSQL = "UPDATE EVENTOS SET CANTIDAD = '\(cantidad)', PERIODO = '\(periodo.rawValue)' WHERE ID = '\(idEvento)'"
            print("updateAlarma: \(updateSQL)")
            let resultado = database.executeUpdate(updateSQL, withArgumentsIn: nil)
            print("resultado de actualizar alarma en eventos: \(resultado)")
            return resultado
        }
        return false
    }
    
    func eliminarAlarma(_ idEvento:String)->Bool {
        return establecerAlarma(idEvento,  cantidad: 0,  periodo: PeriodoTemporal.horas)
    }
    
    func tieneAlarma(_ evento:Evento) -> Bool {
        if evento.cantidad > 0 {
            return true
        }
        return false
    }
   
}
