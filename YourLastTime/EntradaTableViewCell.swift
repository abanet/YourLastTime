//
//  EntradaTableViewCell.swift
//  Last Time
//
//  Created by Alberto Banet Masa on 28/5/15.
//  Copyright (c) 2015 UCM. All rights reserved.
//

import UIKit

class EntradaTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDescripcion: UILabel!
    @IBOutlet weak var entradaView: DesignableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
