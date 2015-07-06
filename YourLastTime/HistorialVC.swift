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
    @IBOutlet weak var lblHace: UILabel!
    @IBOutlet weak var lblResultadoHace: UILabel!
    @IBOutlet weak var lblUltimaSemana: UILabel!
    @IBOutlet weak var lblResultadoUltimaSemana: UILabel!
    @IBOutlet weak var lblUltimoMes: UILabel!
    @IBOutlet weak var lblResultadoUltimoMes: UILabel!
    @IBOutlet weak var lblUltimoAnno: UILabel!
    @IBOutlet weak var lblResultadoUltimoAnno: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
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
        
        txtNombreEvento.editable = true
        txtNombreEvento.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
        txtNombreEvento.editable = false
        txtNombreEvento.text = database.encontrarEvento(idEvento)!.descripcion
        
        // Animación del botón para cerrar
        var timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("agitar"), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        ocurrencias = database.arrayOcurrencias(idEvento)
        
        
        // Calculamos los datos estadísticos
        // Ultima vez hace...
        let fechaNSDate = Fecha().fechaStringToDate(ocurrencias[0].fecha)
        let annos = NSDate().yearsFrom(fechaNSDate)
        let meses = NSDate().monthsFrom(fechaNSDate)
        let dias  = NSDate().daysFrom(fechaNSDate)
        
        let stringAnnos = annos == 1 ? NSLocalizedString("year", comment:"") :NSLocalizedString("years", comment:"")
        let stringMeses = meses == 1 ? NSLocalizedString("month", comment:"") :NSLocalizedString("months", comment:"")
        let stringDias  = dias ==  1 ? NSLocalizedString("day", comment:"") :NSLocalizedString("days", comment:"")
        
        lblHace.text = NSLocalizedString("Ago: ", comment:"")
        lblResultadoHace.text = String(annos) + " " + stringAnnos + ", " + String(meses) + " " + stringMeses + ", " + String(dias) + " " + stringDias + "."
        
        // Ocurrencias en última semana, mes y año
        let (ocurrenciasSemana, ocurrenciasMes, ocurrenciasAnno) = database.contarOcurrenciasSemanaMesAnno(idEvento)
        lblUltimaSemana.text = NSLocalizedString("Last week: ", comment: "")
        lblResultadoUltimaSemana.text =  String(ocurrenciasSemana)
        lblUltimoMes.text = NSLocalizedString("Last month: ", comment: "")
        lblResultadoUltimoMes.text = String(ocurrenciasMes)
        lblUltimoAnno.text = NSLocalizedString("Last year: ", comment: "")
        lblResultadoUltimoAnno.text = String(ocurrenciasAnno)
        
        // Total de ocurrencias
        lblTotal.text = String(ocurrencias.count)
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
        let fecha = Fecha()
        
        cell.lblFecha.text = fecha.devolverFechaLocalizada(ocurrencias[indexPath.row].fecha)
        cell.lblHora.text = ocurrencias[indexPath.row].hora
        cell.descripcion.text = ocurrencias[indexPath.row].descripcion
        // No funcionaba utilizar DesignableTextView que sería lo idóneo. 
        // Esperar a ver si más adelante funciona.
        //cell.descripcion.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
        
        // Si la celda a dibujar es la última hay que cambiar el gráfico de hito.
        if indexPath.row == ocurrencias.count - 1 {
            cell.imgHito.image = UIImage(named: "hitoFinal")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    
    func agitar() {
        btnCerrar.animation = "swing"
        btnCerrar.force = 5.0
        btnCerrar.duration = 0.5
        btnCerrar.animate()
    }

}
