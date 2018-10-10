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
  
    override func draw(_ rect: CGRect) {
      // línea que cruza verticalmente el rect
      let bezierPath = UIBezierPath()
      bezierPath.move(to: CGPoint(x: frame.width/2, y: frame.minY))
      bezierPath.addLine(to: CGPoint(x:frame.width/2, y: frame.maxY))
      UIColor.gray.setFill()
      bezierPath.fill()
      YourLastTime.colorFechaHistorico.setStroke()
      bezierPath.stroke()
      
      // Círculo
      let radio = (frame.width - frame.width/3)/2 //aire para el círculo
      let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.width/2,y: frame.height/2), radius: radio, startAngle: CGFloat(0), endAngle:CGFloat(Float.pi * 2), clockwise: true)
      if rellenar {
        YourLastTime.colorFechaHistorico.setFill() }
      else {
        YourLastTime.colorBackground.setFill()
      }
      circlePath.fill()
      YourLastTime.colorFechaHistorico.setStroke()
      circlePath.stroke()
    }
  

}
//// Bezier Drawing
//let bezierPath = UIBezierPath()
//bezierPath.move(to: CGPoint(x: frame.minX + 10, y: frame.maxY - 34.31))
//bezierPath.addCurve(to: CGPoint(x: frame.minX + 10, y: frame.maxY - 50), controlPoint1: CGPoint(x: frame.minX + 10, y: frame.maxY - 50), controlPoint2: CGPoint(x: frame.minX + 10, y: frame.maxY - 50))
//UIColor.gray.setFill()
//bezierPath.fill()
//YourLastTime.colorFechaHistorico.setStroke()
//bezierPath.lineWidth = 1
//bezierPath.stroke()
//
//
////// Oval Drawing
//let ovalPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + 1, y: frame.minY + floor((frame.height - 18) * 0.50000 + 0.5), width: 18, height: 18))
//YourLastTime.colorFechaHistorico.setStroke()
//ovalPath.lineWidth = 1
//ovalPath.stroke()
//
//
////// Bezier 2 Drawing
//let bezier2Path = UIBezierPath()
//bezier2Path.move(to: CGPoint(x: frame.minX + 10, y: frame.minY + 50))
//bezier2Path.addCurve(to: CGPoint(x: frame.minX + 10, y: frame.minY + 34.31), controlPoint1: CGPoint(x: frame.minX + 10, y: frame.minY + 34.31), controlPoint2: CGPoint(x: frame.minX + 10, y: frame.minY + 34.31))
//UIColor.gray.setFill()
//bezier2Path.fill()
//YourLastTime.colorFechaHistorico.setStroke()
//bezier2Path.lineWidth = 1
//bezier2Path.stroke()
