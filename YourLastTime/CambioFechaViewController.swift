//
//  CambioFechaViewController.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 28/09/2018.
//  Copyright © 2018 abanet. All rights reserved.
//

import UIKit

class CambioFechaViewController: UIViewController {

  @IBOutlet weak var btnVolver: UIButton!
  @IBOutlet weak var datePicker: UIDatePicker!
  var fecha: Date!
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

  @IBAction func closeViewController(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
