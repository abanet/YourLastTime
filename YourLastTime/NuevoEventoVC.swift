//
//  NuevoEventoVC.swift
//  Last Time
//
//  Created by Alberto Banet Masa on 5/6/15.
//  Copyright (c) 2015 UCM. All rights reserved.
//

import UIKit

class NuevoEventoVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var lblCabecera1: UILabel!
    @IBOutlet weak var lblCabecera2: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var descripcionEvento: UITextField!
    @IBOutlet weak var cuadroNuevoEvento: DesignableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        lblCabecera1.text = NSLocalizedString("Create a", comment:"")
        lblCabecera2.text = NSLocalizedString("New Event", comment:"")
        descripcionEvento.placeholder = NSLocalizedString("Name of the new event", comment:"")
        btnCancel.setTitle(NSLocalizedString("Cancel", comment:""), forState: .Normal)
        btnCancel.setTitle(NSLocalizedString("Cancel", comment:""), forState: .Selected)
        
        lblCabecera1.textColor = YourLastTime.colorTextoPrincipal
        lblCabecera2.textColor = YourLastTime.colorTextoPrincipal
        btnOk.setTitleColor(YourLastTime.colorFondoCelda, forState: .Normal)
        btnCancel.setTitleColor(YourLastTime.colorFondoCelda, forState: .Normal)
        descripcionEvento.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        // descripcionEvento.becomeFirstResponder()
    }
    
    // Para que oculte el teclado al pulsar fuera
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
   
    // Creamos un nuevo evento y volvemos a la página anterior
    @IBAction func pulsarBotonAddEvento(sender: AnyObject) {
        let boton = sender as! UIButton
        let descripcion = descripcionEvento.text
        if !descripcion.isEmpty {
            let bbdd = EventosDB()
            bbdd.addEvento(descripcion)
            view.endEditing(true) // ocultamos el teclado
        } else {
            // No podemos añadir un evento sin descripción
            view.endEditing(true)
        }
        self.performSegueWithIdentifier("cerrarNuevoEvento", sender: self)
    }
    
    @IBAction func btnCancelarPulsado(sender: AnyObject) {
        performSegueWithIdentifier("cerrarNuevoEvento", sender: nil)
    }
    
    // Control de máximo de longitud
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = count(textField.text.utf16) + count(string.utf16) - range.length
        return newLength <= Constants.Texto.longitudMaxima // Bool
    }
    
}
