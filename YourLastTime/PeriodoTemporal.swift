//
//  File.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 13/7/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import Foundation

enum PeriodoTemporal: Int {
    case annos=1, meses, dias, horas
    
     var numHoras: Int {
        get {
            var num = 1
            switch self {
            case annos:
                num = 365 * 24
            case meses:
                num = 30 * 24
            case dias:
                num = 24
            case horas:
                num = 1
            default:
                num = 1
            }
            return num
        }
    }
    
    init(rawValue: Int){
        switch rawValue {
        case 1:
            self = .annos
        case 2:
            self = .meses
        case 3:
            self = .dias
        case 4:
            self = .horas
        default:
            self = .dias
        }
    }
    
    
}