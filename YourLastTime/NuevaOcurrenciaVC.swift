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
    var isDescription = false
    var notificacion = Notificacion(id: "")
   
    
    @IBOutlet weak var lblCabecera1: UILabel!
    @IBOutlet weak var lblCabecera2: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var textViewDescripcionOcurrencia: UITextView! {
    didSet {
      textViewDescripcionOcurrencia.text = NSLocalizedString("Add an optional description", comment:"")
      textViewDescripcionOcurrencia.textColor = UIColor.lightGray
      textViewDescripcionOcurrencia.delegate = self
    }
  }
  
  override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        lblCabecera1.text = NSLocalizedString("It happened again!", comment:"")
        lblCabecera2.text = NSLocalizedString("Add a new occurrence", comment:"")
        btnCancel.setTitle(NSLocalizedString("Cancel", comment:""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("Cancel", comment:""), for: .selected)

        
        lblCabecera1.textColor = YourLastTime.colorTextoPrincipal
        lblCabecera2.textColor = YourLastTime.colorTextoPrincipal
        btnOk.setTitleColor(YourLastTime.colorFondoCelda, for: .normal)
        btnCancel.setTitleColor(YourLastTime.colorFondoCelda, for: .normal)

        textViewDescripcionOcurrencia.layer.cornerRadius = 10.0
    }

    override func viewDidAppear(_ animated: Bool) {
        textViewDescripcionOcurrencia.becomeFirstResponder()
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
        //database.addOcurrencia(idEvento, descripcion: descripcionOcurrencia.text!)
        
        let description = isDescription ? textViewDescripcionOcurrencia.text.removingAllExtraNewLines : ""
        database.addOcurrencia(idEvento, descripcion: description)
    
      
        // Ha ocurrido una nueva ocurrencia.
        // Si hay una notificación local puesta hay que quitarla y volver a poner otra.
        if let evento = database.encontrarEvento(idEvento) {
            if evento.tieneAlarma(), let intervaloAlarma = evento.intervaloParaProgramarAlarma() { // programamos una notificación local
               
                var informacionEvento = [String:String]()
                informacionEvento["id"] = evento.id
                informacionEvento["descripcion"] = evento.descripcion
                informacionEvento["fecha"] = evento.fecha
                informacionEvento["hora"] = evento.hora
                notificacion = Notificacion(id: evento.id, info: informacionEvento)
                // Calcular cuando hay que poner alarma: x tiempo desde la última vez.
                let intervaloSegundos = TimeInterval(evento.cantidad * evento.periodo.numHoras * 60 * 60)
                notificacion.reprogramarFechaNotificacion(intervaloSegundos)
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

    
   
}

// Control del uitextview
extension NuevaOcurrenciaVC: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      textView.text = nil
      textView.textColor = UIColor.black
      isDescription = true
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = NSLocalizedString("Add an optional description", comment:"")
      textView.textColor = UIColor.lightGray
        isDescription = false
    }
  }
 
    
}


