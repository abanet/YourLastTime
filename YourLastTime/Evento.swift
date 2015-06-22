//
//  Evento.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 9/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class Evento: NSObject {
    var id: String
    var descripcion: String
    var fecha: String
    var hora: String
    var contador: Int
    
    init(id:String, descripcion:String, fecha:String, hora: String, contador:Int) {
        self.id = id
        self.descripcion = descripcion
        self.fecha = fecha
        self.hora = hora
        self.contador = contador
    }
}
