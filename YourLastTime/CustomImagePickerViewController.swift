//
//  CustomImagePickerViewController.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 23/10/2018.
//  Copyright © 2018 abanet. All rights reserved.
//

import UIKit




class CustomImagePickerViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let HEIGHT_BUTTON: CGFloat = 50.0
    let CORNER_RADIUS: CGFloat = 5.0
    
    
    let picker: UIImagePickerController = {
        let p = UIImagePickerController()
        p.allowsEditing = false
        return p
    }()
    
    let imageBackgroundView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var okButton: UIButton = {
        //let button = UIButton(type: .system)
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false // un poco de aire para que no se ajuste hasta el límite del texto
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.setContentHuggingPriority(UILayoutPriority(rawValue: 750.0), for: .horizontal)
        button.layer.cornerRadius = CORNER_RADIUS
        button.backgroundColor = YourLastTime.colorFondoCelda
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(.yellow, for: .highlighted)
        button.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(CustomImagePickerViewController.okPulsado), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = CORNER_RADIUS
        button.backgroundColor = YourLastTime.colorFondoCelda
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(.yellow, for: .highlighted)
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(CustomImagePickerViewController.cancelPulsado), for: .touchUpInside)
        return button
    }()
    
    lazy var pickAnotherButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = CORNER_RADIUS
        button.backgroundColor = YourLastTime.colorFondoCelda
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(.yellow, for: .highlighted)
        button.setTitle(NSLocalizedString("Select", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(CustomImagePickerViewController.changePhotoPulsado), for: .touchUpInside)
        return button
    }()
    
    lazy var restoreBackgroundButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = CORNER_RADIUS
        button.backgroundColor = YourLastTime.colorFondoCelda
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(.yellow, for: .highlighted)
        button.setTitle(NSLocalizedString("Restore default", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(CustomImagePickerViewController.restoreBackgroundPulsado), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blue
        picker.delegate = self
        setupBackground(imageView: imageBackgroundView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    
    
    
    // MARK: Setup Views
    private func setupView() {
        
        view.addSubview(imageBackgroundView)
        view.addSubview(okButton)
        view.addSubview(cancelButton)
        view.addSubview(pickAnotherButton)
        view.addSubview(restoreBackgroundButton)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            // restoreBackgroundButton
            restoreBackgroundButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            restoreBackgroundButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            restoreBackgroundButton.heightAnchor.constraint(equalToConstant: HEIGHT_BUTTON),
            restoreBackgroundButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32.0),
            
            // okButton
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            okButton.heightAnchor.constraint(equalToConstant: HEIGHT_BUTTON),
            okButton.trailingAnchor.constraint(equalTo: pickAnotherButton.leadingAnchor, constant: -8.0),
            //okButton.widthAnchor.constraint(equalToConstant: view.frame.width/3),
            okButton.bottomAnchor.constraint(equalTo: restoreBackgroundButton.topAnchor, constant: -16.0),
            
            // cancelButton
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            cancelButton.heightAnchor.constraint(equalToConstant: HEIGHT_BUTTON),
            //cancelButton.widthAnchor.constraint(equalToConstant: view.frame.width/3),
            cancelButton.leadingAnchor.constraint(equalTo: pickAnotherButton.trailingAnchor, constant: 8.0),
            cancelButton.bottomAnchor.constraint(equalTo: restoreBackgroundButton.topAnchor, constant: -16.0),
            cancelButton.widthAnchor.constraint(equalTo: okButton.widthAnchor),
            
            // pickAnotherButton
            pickAnotherButton.leadingAnchor.constraint(equalTo: okButton.trailingAnchor),
            pickAnotherButton.heightAnchor.constraint(equalToConstant: HEIGHT_BUTTON),
            //pickAnotherButton.widthAnchor.constraint(equalToConstant: view.frame.width/3),
            pickAnotherButton.bottomAnchor.constraint(equalTo:restoreBackgroundButton.topAnchor, constant: -16.0),
            
            // imageBackgrounView
            imageBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            imageBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
    }
    
    
    
    // MARK: Button's actions
    @objc func cancelPulsado() {
        self.dismiss(animated: true)
    }
    
    @objc func okPulsado() {
        if let img = imageBackgroundView.image {
            saveImageToLocal(img, name: imageNameCustomBackground)
        }
        self.dismiss(animated: true)
    }
    
    @objc func changePhotoPulsado() {
        self.present(picker, animated: true)
    }
    
    @objc func restoreBackgroundPulsado() {
        if let img = UIImage(named: imageNameBackgroundDefault) {
            imageBackgroundView.image = img
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageBackgroundView.image = fixImageOrientation(pickedImage)
            self.dismiss(animated: true)
        }
    }
    
    // función auxiliar que devuelve la imagen con la orientación correcta.
    func fixImageOrientation(_ image: UIImage)->UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
    }
    
}
