//
//  EntradaTableViewCell.swift
//  Last Time
//
//  Created by Alberto Banet Masa on 28/5/15.
//  Copyright (c) 2015 UCM. All rights reserved.
//

import UIKit


class EntradaTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var lbDescripcion: UILabel!
    @IBOutlet weak var lblHace: UILabel!
    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var lblHora: UILabel!
    @IBOutlet weak var entradaView: DesignableView!
    @IBOutlet weak var lblContador: UILabel!
    @IBOutlet weak var imgDespertador: UIImageView!
    @IBOutlet weak var lblDetalleAlarma: UILabel!
    
    var idEvento: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // añadir una nueva ocurrencia
    @IBAction func addOcurrencia(_ sender: AnyObject) {
        let boton = sender as! SpringButton
        boton.animation = "pop"
        boton.animate()
        
    }
    
}
