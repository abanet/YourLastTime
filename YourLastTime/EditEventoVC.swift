//
//  EditEvento.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 9/7/19.
//  Copyright © 2019 abanet. All rights reserved.
//

import UIKit

class EditEventoVC: UIViewController, UITextFieldDelegate  {
   
    var idEvento: String!
    
    @IBOutlet weak var lblEditingEvent: UILabel!
    @IBOutlet weak var txtEventName: UITextField!
    
    
    override func viewWillAppear(_ animated: Bool) {
        let bbdd = EventosDB()
        let evento = bbdd.encontrarEvento(self.idEvento)!
        txtEventName.text = evento.descripcion
    }
    
    @IBAction func btnOkClicked(_ sender: Any) {
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        performSegue(withIdentifier: "cerrarEditarEvento", sender: nil)
        
    }
}
