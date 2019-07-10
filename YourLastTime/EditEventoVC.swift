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
    @IBOutlet weak var switchValue: UISwitch!
    @IBOutlet weak var lblAddValue: UILabel!
    
    override func viewDidLoad() {
        lblEditingEvent.text = NSLocalizedString("Editing Event", comment:"")
        lblAddValue.text = NSLocalizedString("Add economic value", comment: "")
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let bbdd = EventosDB()
        let evento = bbdd.encontrarEvento(self.idEvento)!
        txtEventName.text = evento.descripcion
        switchValue.isOn = evento.estaMonetizado()
    }
    
    @IBAction func btnOkClicked(_ sender: Any) {
        let database = EventosDB()
        if let description = txtEventName.text?.removingAllExtraNewLines, !description.isEmpty {
            database.updateEventoName(idEvento: idEvento, newName: description)
            database.updateEventoMonetizado(idEvento: idEvento, monetizado: switchValue.isOn)
            performSegue(withIdentifier: "cerrarEditarEvento", sender: nil)
        }
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        performSegue(withIdentifier: "cerrarEditarEvento", sender: nil)
    }
}
