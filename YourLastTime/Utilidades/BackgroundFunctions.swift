//
//  Helpers.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 24/10/2018.
//  Copyright © 2018 abanet. All rights reserved.
//

import UIKit

public let imageNameCustomBackground = "custombackground"
public let imageNameBackgroundDefault = "background2"

// MARK: Save and Restore image background
func saveImageToLocal(_ image: UIImage, name: String) {
    let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(name).png"
    let imageUrl: URL = URL(fileURLWithPath: imagePath)
    DispatchQueue.global().async {
        do {
            try image.pngData()?.write(to: imageUrl)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didChangeBackground, object: nil)
            }
            
        } catch {
            print(error)
        }
    }
}

func loadImageCustomBackground(name: String) -> UIImage? {
    let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(name).png"
    let imageUrl: URL = URL(fileURLWithPath: imagePath)
    guard FileManager.default.fileExists(atPath: imagePath),
        let imageData: Data = try? Data(contentsOf: imageUrl),
        let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) else {
            return nil // No image found!
    }
    return image
}

// Mira si hay un background personalizado; en caso contrario se añade el background por defecto
func setupBackground(imageView: UIImageView) {
    if let background = loadImageCustomBackground(name: imageNameCustomBackground) {
        imageView.image = background
    } else {
        imageView.image = UIImage(named: imageNameBackgroundDefault)
    }
}

