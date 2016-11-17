//
//  Ocurrencia.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 10/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class Ocurrencia: NSObject {
    
    var idEvento: String
    var fecha: String
    var hora: String
    var descripcion: String
    
    init(idEvento:String, fecha:String, hora: String, descripcion: String) {
        self.idEvento = idEvento
        self.fecha = fecha
        self.hora = hora
        self.descripcion = descripcion
    }
    
    init(idEvento:String, fecha:String) {
        self.idEvento = idEvento
        self.fecha = fecha
        self.hora = ""
        self.descripcion = ""
    }
    
    // Momento de la ocurrencia en formato MM-dd-YYYYHH:mm
    // Utilizada para el cálculo de las diferencias entre ocurrencias
    func formatoMMddYYYYHHmm () -> String {
        return "\(fecha)\(hora)"
    }
    
}
