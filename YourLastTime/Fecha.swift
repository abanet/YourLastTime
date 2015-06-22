//
//  Fecha.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 9/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class Fecha: NSObject {
    var fecha: String
    var hora: String
    
    override init(){
        let date = NSDate()
        let formateador = NSDateFormatter()
        formateador.dateFormat = NSLocalizedString("MM-dd-yyyy", comment: "Formato de fecha")
        println("Formateador: \(formateador.dateFormat)")
        fecha = formateador.stringFromDate(date)
        formateador.dateFormat = "HH:mm"
        hora = formateador.stringFromDate(date)
        super.init()
    }
    
}
