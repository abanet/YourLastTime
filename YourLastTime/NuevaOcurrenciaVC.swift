//
//  NuevaOcurrenciaVC.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 16/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class NuevaOcurrenciaVC: UIViewController, UITextFieldDelegate {

    var idEvento: String!
    @IBOutlet weak var lblCabecera1: UILabel!
    @IBOutlet weak var lblCabecera2: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var descripcionOcurrencia: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        lblCabecera1.text = NSLocalizedString("It happened again!", comment:"")
        lblCabecera2.text = NSLocalizedString("Add a new occurrence", comment:"")
        descripcionOcurrencia.placeholder = NSLocalizedString("Add an optional description", comment:"")
        btnCancel.setTitle(NSLocalizedString("Cancel", comment:""), for: UIControl.State())
        btnCancel.setTitle(NSLocalizedString("Cancel", comment:""), for: UIControl.State.selected)

        
        lblCabecera1.textColor = YourLastTime.colorTextoPrincipal
        lblCabecera2.textColor = YourLastTime.colorTextoPrincipal
        btnOk.setTitleColor(YourLastTime.colorFondoCelda, for: UIControl.State())
        btnCancel.setTitleColor(YourLastTime.colorFondoCelda, for: UIControl.State())

        descripcionOcurrencia.delegate = self
        descripcionOcurrencia.autocapitalizationType = .sentences
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Para que oculte el teclado al pulsar fuera
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    @IBAction func btnOkPulsado(_ sender: AnyObject) {
        let database = EventosDB()
        database.addOcurrencia(idEvento, descripcion: descripcionOcurrencia.text!)
        
        // Ha ocurrido una nueva ocurrencia.
        // Si hay una notificación local puesta hay que quitarla y volver a poner otra.
        if let evento = database.encontrarEvento(idEvento) {
            if evento.tieneAlarma() {
                let notificacion = Notificacion(id: evento.id)
                let horas = evento.cantidad * evento.periodo.numHoras
                notificacion.reprogramarFechaNotificacion(horas)
            }
        }
        
        
        
        
    }
    
    @IBAction func btnCancelarPulsado(_ sender: AnyObject) {
        performSegue(withIdentifier: "cerrarNuevaOcurrencia", sender: nil)
    }


    // MARK: - UITextDelegate
    // Control de máximo de longitud
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.utf16.count + string.utf16.count - range.length
        return newLength <= Constants.Texto.longitudMaximaNuevaOcurrencia // Bool
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
