//
//  YourLastTime.swift
//  Last Time
//
//  Created by Alberto Banet on 25/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//



import UIKit

public class YourLastTime : NSObject {

    //// Cache

    private struct Cache {
        static var colorTextoPrincipal: UIColor = UIColor(red: 0.169, green: 0.251, blue: 0.129, alpha: 1.000)
        static var colorTextoSecundario: UIColor = YourLastTime.colorTextoPrincipal.colorWithBrightness(1)
        static var colorFondoCelda: UIColor = UIColor(red: 0.612, green: 0.745, blue: 0.549, alpha: 1.000)
        static var colorAccion: UIColor = UIColor(red: 0.431, green: 0.545, blue: 0.376, alpha: 1.000)
        static var colorAccion2: UIColor = YourLastTime.colorAccion.colorWithBrightness(0.7)
    }

    //// Colors

    public class var colorTextoPrincipal: UIColor { return Cache.colorTextoPrincipal }
    public class var colorTextoSecundario: UIColor { return Cache.colorTextoSecundario }
    public class var colorFondoCelda: UIColor { return Cache.colorFondoCelda }
    public class var colorAccion: UIColor { return Cache.colorAccion }
    public class var colorAccion2: UIColor { return Cache.colorAccion2 }

    //// Drawing Methods

    public class func drawCanvas1(#frame: CGRect) {
        //// Color Declarations
        let colorFechaHistorico = YourLastTime.colorTextoPrincipal.colorWithBrightness(0.827)

        //// Bezier Drawing
        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(frame.minX + 10, frame.maxY - 34.31))
        bezierPath.addCurveToPoint(CGPointMake(frame.minX + 10, frame.maxY - 50), controlPoint1: CGPointMake(frame.minX + 10, frame.maxY - 50), controlPoint2: CGPointMake(frame.minX + 10, frame.maxY - 50))
        UIColor.grayColor().setFill()
        bezierPath.fill()
        colorFechaHistorico.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()


        //// Oval Drawing
        var ovalPath = UIBezierPath(ovalInRect: CGRectMake(frame.minX + 1, frame.minY + floor((frame.height - 18) * 0.50000 + 0.5), 18, 18))
        colorFechaHistorico.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()


        //// Bezier 2 Drawing
        var bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPointMake(frame.minX + 10, frame.minY + 50))
        bezier2Path.addCurveToPoint(CGPointMake(frame.minX + 10, frame.minY + 34.31), controlPoint1: CGPointMake(frame.minX + 10, frame.minY + 34.31), controlPoint2: CGPointMake(frame.minX + 10, frame.minY + 34.31))
        UIColor.grayColor().setFill()
        bezier2Path.fill()
        colorFechaHistorico.setStroke()
        bezier2Path.lineWidth = 1
        bezier2Path.stroke()
    }

}



extension UIColor {
    func colorWithHue(newHue: CGFloat) -> UIColor {
        var saturation: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    func colorWithSaturation(newSaturation: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
    func colorWithBrightness(newBrightness: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
    func colorWithAlpha(newAlpha: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, brightness: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newAlpha)
    }
    func colorWithHighlight(highlight: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-highlight) + highlight, green: green * (1-highlight) + highlight, blue: blue * (1-highlight) + highlight, alpha: alpha * (1-highlight) + highlight)
    }
    func colorWithShadow(shadow: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-shadow), green: green * (1-shadow), blue: blue * (1-shadow), alpha: alpha * (1-shadow) + shadow)
    }
}

@objc protocol StyleKitSettableImage {
    func setImage(image: UIImage!)
}

@objc protocol StyleKitSettableSelectedImage {
    func setSelectedImage(image: UIImage!)
}
