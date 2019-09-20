//
//  CustomizeDatePicker.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 01/10/2018.
//  Copyright © 2018 abanet. All rights reserved.
//

import UIKit

protocol CustomizeDatePickerDelegate: class {
    var isCustomizeDatePickerShow: Bool { get set }
    func setFechaValueToDatabase(_ fecha: Fecha?)
}

enum CustomizeDatePickerConfiguration: Int {
   case tag = 100
}

class CustomizeDatePicker: UIView {
  weak var delegate: CustomizeDatePickerDelegate?

  
  var date: Date? {
    didSet {
      if let date = date {
        datePicker.date = date
      }
    }
  }
  
  var minimunDate: Date? {
    didSet {
      if let minimumDate = minimunDate {
        datePicker.minimumDate = minimumDate
      }
    }
  }
  
  private lazy var datePicker: UIDatePicker = {
    let dp = UIDatePicker(frame: self.frame)
    dp.translatesAutoresizingMaskIntoConstraints = false
    dp.datePickerMode = .dateAndTime
    dp.maximumDate = Date() // máx en fecha y hora actual
    if let d = date {
      dp.date = d
    }
    return dp
  } ()
  
  lazy var okButton: UIButton = {
    let okButton = UIButton(frame: .zero)
    okButton.translatesAutoresizingMaskIntoConstraints = false
    okButton.setTitle(NSLocalizedString("Ok", comment: ""), for: .normal)
    okButton.addTarget(self, action: #selector(CustomizeDatePicker.okPulsado), for: .touchUpInside)
    return okButton
  }()
  
  lazy var cancelButton: UIButton = {
    let cancelButton = UIButton(frame: .zero)
    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
    cancelButton.addTarget(self, action: #selector(CustomizeDatePicker.cancelPulsado), for: .touchUpInside)
    return cancelButton
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  //initWithCode to init view from xib or storyboard
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  
  //common func to init our view
  private func setupView() {
    self.tag = CustomizeDatePickerConfiguration.tag.rawValue
    backgroundColor = YourLastTime.colorFechaHistorico
    addSubview(datePicker)
    addSubview(okButton)
    addSubview(cancelButton)
    setupLayout()
  }
  
  private func setupLayout() {
    // Autolayout para el datePicker
    
    // Safe area para los botones si iOS >= 11
    if #available(iOS 11, *) {
        let guide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            okButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
            ])
        
    } else {
        let standardSpacing: CGFloat = -8
        NSLayoutConstraint.activate([
            okButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: standardSpacing),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: standardSpacing)
            
            ])
    }
    
    NSLayoutConstraint.activate([
      // okButton
      okButton.leadingAnchor.constraint(equalTo: leadingAnchor),
      okButton.heightAnchor.constraint(equalToConstant: 32),
      okButton.widthAnchor.constraint(equalToConstant: frame.width/2),
      
      // cancelButton
      cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor),
      cancelButton.heightAnchor.constraint(equalToConstant: 32),
      cancelButton.widthAnchor.constraint(equalToConstant: frame.width/2),
      
      // datePicker
      datePicker.topAnchor.constraint(equalTo: topAnchor),
      datePicker.bottomAnchor.constraint(equalTo: okButton.topAnchor),
      datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
      datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
      ])
    
    
  }

  
  @objc func cancelPulsado() {
    self.removeFromSuperview()
    delegate?.setFechaValueToDatabase(nil)
    delegate?.isCustomizeDatePickerShow = false
  }
  
  @objc func okPulsado() {
    let fecha = Fecha(date: datePicker.date)
    delegate?.setFechaValueToDatabase(fecha)
    delegate?.isCustomizeDatePickerShow = false
    self.removeFromSuperview()
  }
}
