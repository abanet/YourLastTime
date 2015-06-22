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
    @IBOutlet weak var descripcion: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
