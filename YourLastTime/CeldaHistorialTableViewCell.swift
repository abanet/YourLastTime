//
//  CeldaHistorialTableViewCell.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 19/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class CeldaHistorialTableViewCell: UITableViewCell {

    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var imgHito: UIImageView!
    @IBOutlet weak var lblHora: UILabel!
    @IBOutlet weak var lblHace: UILabel!
    @IBOutlet weak var textViewDescripcion: UITextView!
    @IBOutlet weak var textViewDescripcionCopia: UITextView! // se usa sólo para dimensionamiento y tiene enable scroll = false
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    
    textViewDescripcionCopia.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  
}
