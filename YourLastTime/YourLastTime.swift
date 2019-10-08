//
//  YourLastTime.swift
//  Last Time
//
//  Created by Alberto Banet on 7/7/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//



import UIKit

open class YourLastTime : NSObject {

    //// Cache

    fileprivate struct Cache {
        static var colorTextoPrincipal: UIColor = UIColor(red: 0.169, green: 0.251, blue: 0.129, alpha: 1.000)
        static var colorTextoSecundario: UIColor = YourLastTime.colorTextoPrincipal.colorWithBrightness(1)
        static var colorFechaHistorico: UIColor = YourLastTime.colorTextoPrincipal.colorWithBrightness(0.827)
        static var colorFondoCelda: UIColor = UIColor(red: 0.612, green: 0.745, blue: 0.549, alpha: 1.000)
        static var colorAccion: UIColor = UIColor(red: 0.431, green: 0.545, blue: 0.376, alpha: 1.000)
        static var colorAccion2: UIColor = YourLastTime.colorAccion.colorWithBrightness(0.7)
        static var colorAccion3: UIColor = YourLastTime.colorAccion.colorWithBrightness(0.8)
        static var colorBackground: UIColor = UIColor(red: 0.875, green: 0.945, blue: 0.843, alpha: 1.000)
      static var colorTituloEvento: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.000)
      static var colorPlaceholderEvento: UIColor = UIColor(white: 0.5, alpha: 1.0 )
    }

    //// Colors

    open class var colorTextoPrincipal: UIColor { return Cache.colorTextoPrincipal }
    open class var colorTextoSecundario: UIColor { return Cache.colorTextoSecundario }
    open class var colorFechaHistorico: UIColor { return Cache.colorFechaHistorico }
    open class var colorFondoCelda: UIColor { return Cache.colorFondoCelda }
    open class var colorAccion: UIColor { return Cache.colorAccion }
    open class var colorAccion2: UIColor { return Cache.colorAccion2 }
    open class var colorAccion3: UIColor { return Cache.colorAccion3 }
    open class var colorBackground: UIColor { return Cache.colorBackground }
  open class var colorTituloEvento: UIColor { return Cache.colorTituloEvento }
  open class var colorPlaceholderEvento: UIColor { return Cache.colorPlaceholderEvento }

    //// Drawing Methods

    open class func drawCanvas1(frame: CGRect) {

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame.minX + 10, y: frame.maxY - 34.31))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 10, y: frame.maxY - 50), controlPoint1: CGPoint(x: frame.minX + 10, y: frame.maxY - 50), controlPoint2: CGPoint(x: frame.minX + 10, y: frame.maxY - 50))
        UIColor.gray.setFill()
        bezierPath.fill()
        YourLastTime.colorFechaHistorico.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()


        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + 1, y: frame.minY + floor((frame.height - 18) * 0.50000 + 0.5), width: 18, height: 18))
        YourLastTime.colorFechaHistorico.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()


        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: frame.minX + 10, y: frame.minY + 50))
        bezier2Path.addCurve(to: CGPoint(x: frame.minX + 10, y: frame.minY + 34.31), controlPoint1: CGPoint(x: frame.minX + 10, y: frame.minY + 34.31), controlPoint2: CGPoint(x: frame.minX + 10, y: frame.minY + 34.31))
        UIColor.gray.setFill()
        bezier2Path.fill()
        YourLastTime.colorFechaHistorico.setStroke()
        bezier2Path.lineWidth = 1
        bezier2Path.stroke()
    }

}



extension UIColor {
    func colorWithHue(_ newHue: CGFloat) -> UIColor {
        var saturation: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    func colorWithSaturation(_ newSaturation: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
    func colorWithBrightness(_ newBrightness: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
    func colorWithAlpha(_ newAlpha: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, brightness: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newAlpha)
    }
    func colorWithHighlight(_ highlight: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-highlight) + highlight, green: green * (1-highlight) + highlight, blue: blue * (1-highlight) + highlight, alpha: alpha * (1-highlight) + highlight)
    }
    func colorWithShadow(_ shadow: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-shadow), green: green * (1-shadow), blue: blue * (1-shadow), alpha: alpha * (1-shadow) + shadow)
    }
}

@objc protocol StyleKitSettableImage {
    func setImage(_ image: UIImage!)
}

@objc protocol StyleKitSettableSelectedImage {
    func setSelectedImage(_ image: UIImage!)
}
