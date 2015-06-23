//
//  NuevaOcurrenciaVC.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 16/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class NuevaOcurrenciaVC: UIViewController {

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
        btnCancel.setTitle(NSLocalizedString("Cancel", comment:""), forState: .Normal)
        btnCancel.setTitle(NSLocalizedString("Cancel", comment:""), forState: .Selected)

        
        lblCabecera1.textColor = YourLastTime.colorTextoPrincipal
        lblCabecera2.textColor = YourLastTime.colorTextoPrincipal
        btnOk.setTitleColor(YourLastTime.colorFondoCelda, forState: .Normal)
        btnCancel.setTitleColor(YourLastTime.colorFondoCelda, forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Para que oculte el teclado al pulsar fuera
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    @IBAction func btnOkPulsado(sender: AnyObject) {
        let database = EventosDB()
        database.addOcurrencia(idEvento, descripcion: descripcionOcurrencia.text)
    }
    
    @IBAction func btnCancelarPulsado(sender: AnyObject) {
        performSegueWithIdentifier("cerrarNuevaOcurrencia", sender: nil)
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
