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
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gray.colorWithAlpha(0.60)
        button.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(CustomImagePickerViewController.okPulsado), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gray.colorWithAlpha(0.60)
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(CustomImagePickerViewController.cancelPulsado), for: .touchUpInside)
        return button
    }()
    
    lazy var pickAnotherButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gray.colorWithAlpha(0.60)
        button.setTitle(NSLocalizedString("Change photo", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(CustomImagePickerViewController.changePhotoPulsado), for: .touchUpInside)
        return button
    }()
    
    lazy var restoreBackgroundButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gray.colorWithAlpha(0.60)
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
            okButton.bottomAnchor.constraint(equalTo: restoreBackgroundButton.topAnchor, constant: -32.0),
            
            // cancelButton
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            cancelButton.heightAnchor.constraint(equalToConstant: HEIGHT_BUTTON),
            //cancelButton.widthAnchor.constraint(equalToConstant: view.frame.width/3),
            cancelButton.leadingAnchor.constraint(equalTo: pickAnotherButton.trailingAnchor, constant: 8.0),
            cancelButton.bottomAnchor.constraint(equalTo: restoreBackgroundButton.topAnchor, constant: -32.0),
            cancelButton.widthAnchor.constraint(equalTo: okButton.widthAnchor),
            
            // pickAnotherButton
            pickAnotherButton.leadingAnchor.constraint(equalTo: okButton.trailingAnchor),
            pickAnotherButton.heightAnchor.constraint(equalToConstant: HEIGHT_BUTTON),
            //pickAnotherButton.widthAnchor.constraint(equalToConstant: view.frame.width/3),
            pickAnotherButton.bottomAnchor.constraint(equalTo:restoreBackgroundButton.topAnchor, constant: -32.0),
            
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
            imageBackgroundView.image = pickedImage
            self.dismiss(animated: true)
        }
    }
    
    
    
}
