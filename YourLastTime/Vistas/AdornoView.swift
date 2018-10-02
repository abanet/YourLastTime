//
//  adornoView.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 28/09/2018.
//  Copyright © 2018 abanet. All rights reserved.
//

import UIKit

class AdornoView: UIView {

    var rellenar = false
    var esUltimaCelda = false
  
    override func draw(_ rect: CGRect) {
      drawLine()
      drawCircle()
      if esUltimaCelda {
        drawOval()
      }
    }
  
  func drawLine() {
    // línea que cruza verticalmente el rect
    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: frame.width/2, y: frame.minY))
    bezierPath.addLine(to: CGPoint(x:frame.width/2, y: frame.maxY))
    UIColor.gray.setFill()
    bezierPath.fill()
    YourLastTime.colorFechaHistorico.setStroke()
    bezierPath.stroke()
  }
  
  func drawCircle () {
    //let centroCirculo = CGPoint(x: frame.width/2,y: frame.height/2)
    let posY = (superview?.layoutMargins.top)! + 10 // Para centrarlo con la fecha
    let centroCirculo = CGPoint(x: frame.width/2, y: posY)
    let radio = (frame.width - frame.width/3)/2 //aire para el círculo
    let circlePath = UIBezierPath(arcCenter: centroCirculo, radius: radio, startAngle: CGFloat(0), endAngle:CGFloat(Float.pi * 2), clockwise: true)
    if rellenar {
      YourLastTime.colorFechaHistorico.setFill() }
    else {
      YourLastTime.colorBackground.setFill()
    }
    circlePath.fill()
    YourLastTime.colorFechaHistorico.setStroke()
    circlePath.stroke()
  }
  
  func drawOval() {
    let height = CGFloat(16)
    let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0, y: frame.maxY-2, width: frame.width, height: -height + height/4))
    YourLastTime.colorBackground.setFill()
    ovalPath.fill()
    YourLastTime.colorFechaHistorico.setStroke()
    ovalPath.stroke()
  }
  
}
