//
//  HistorialVC.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 19/6/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class HistorialVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtNombreEvento: UITextView!
    @IBOutlet weak var lblUltimaSemana: UILabel!
    @IBOutlet weak var lblUltimoMes: UILabel!
    @IBOutlet weak var lblUltimoAnno: UILabel!
    @IBOutlet weak var btnCerrar: SpringButton!
    
    
    var idEvento: String!
    var database: EventosDB!
    var ocurrencias: [Ocurrencia] = [Ocurrencia]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        database = EventosDB()
        
        // Animación del botón para cerrar
        var timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("agitar"), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        println("Histórico para evento: \(idEvento)")
        ocurrencias = database.arrayOcurrencias(idEvento)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Ocultamos la barra de estatus
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("Número de ocurrencias: \(ocurrencias.count)")
        return ocurrencias.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CeldaHistorial") as! CeldaHistorialTableViewCell
        cell.lblFecha.text = ocurrencias[indexPath.row].fecha
        cell.descripcion.text = ocurrencias[indexPath.row].descripcion
        // No funcionaba utilizar DesignableTextView que sería lo idóneo. 
        // Esperar a ver si más adelante funciona.
        cell.descripcion.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 146.0
    }
    
    
    func agitar() {
        btnCerrar.animation = "swing"
        btnCerrar.force = 5.0
        btnCerrar.duration = 0.5
        btnCerrar.animate()
    }

}
