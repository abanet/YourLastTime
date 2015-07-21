//
//  AlertaVC.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 13/7/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit



class AlertaVC: UIViewController {

   
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var txtDescripcion: DesignableTextView!
    @IBOutlet weak var btnOk: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnPulsado(sender: AnyObject) {
        
            self.dismissViewControllerAnimated(true, completion: nil)
     
    }
    

}
