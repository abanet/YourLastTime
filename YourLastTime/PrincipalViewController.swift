//
//  PrincipalViewController.swift
//  Last Time
//
//  Created by Alberto Banet Masa on 28/5/15.
//  Copyright (c) 2015 UCM. All rights reserved.
//

import UIKit

class PrincipalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblTitulo: SpringLabel!
    @IBOutlet weak var tableView: UITableView!
    private var bbdd: EventosDB
    private var eventos: [Evento]

   
    required init(coder aDecoder: NSCoder) {
        bbdd = EventosDB()
        eventos = bbdd.arrayEventos()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitulo.text = NSLocalizedString("When was the last time I...?", comment:"cabecera de la pantalla principal")
        lblTitulo.textColor = YourLastTime.colorTextoPrincipal
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: UITableViewDataSource Protocol
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventos.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! EntradaTableViewCell
        cell.tvDescripcion.text = eventos[indexPath.row].descripcion
        cell.lblFecha.text = eventos[indexPath.row].fecha
        cell.lblHora.text = eventos[indexPath.row].hora
        cell.lblContador.text = String(eventos[indexPath.row].contador)
        cell.idEvento = eventos[indexPath.row].id
        cell.entradaView.delay = CGFloat(0.05) * CGFloat(indexPath.row)
        cell.entradaView.animation = "slideRight"
        cell.entradaView.animate()
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
       
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        // Opción de borrado
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: NSLocalizedString("Delete", comment: ""), handler:{action, indexpath in
            let idEventoEliminar = self.eventos[indexPath.row].id
            self.eventos.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            // Tenemos que eliminar el evento y sus ocurrencias
            if self.bbdd.eliminarOcurrencias(idEventoEliminar) {
                println("Eliminadas ocurrencias asociadas a idEvento = '\(idEventoEliminar)'")
                // se han eliminado las ocurrencias correctamente. Eliminamos el evento asociado
                if self.bbdd.eliminarEvento(idEventoEliminar){
                    println("Evento eliminado con id = '\(idEventoEliminar)'")
                } else {
                    println("No se puede eliminar Evento con id = '\(idEventoEliminar)'")
                }
            } else {
                println("No se han podido eliminar ocurrencias asociadas con idEvento = '\(idEventoEliminar)'")
            }
            
        });
        deleteRowAction.backgroundColor =  YourLastTime.colorAccion
        
        // Opción de estadísticas
        var historialRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: NSLocalizedString("History", comment: ""), handler:{action, indexpath in
            self.performSegueWithIdentifier("verHistorial", sender: indexPath)
        });
        historialRowAction.backgroundColor =  YourLastTime.colorAccion
        
        
        return [deleteRowAction, historialRowAction];
    }
    
    
    // Ocultamos la barra de estatus
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
   
    
    @IBAction func touchDown(sender: AnyObject) {
        let boton = sender as! SpringButton
        boton.animation = "pop"
        boton.animate()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pasamos el parámetro idEvento para dar el alta al pulsar el ok en la pantalla de nuevaOcurrencia
        // Cogemos la celda adecuada según la posición del botón pulsado.
        // Quizás una buena forma alternativa sea utilizar un protocolo en nuevaOcurrencia que devuelva Ok o Cancel y se actue en consecuencia.
        if(segue.identifier == "nuevaOcurrencia"){
            let nuevaOcurrenciaViewController = segue.destinationViewController as! NuevaOcurrenciaVC
            let buttonPosition: CGPoint = sender!.convertPoint(CGPointZero, toView: self.tableView)
            if let indexPathCeldaSeleccionada = self.tableView.indexPathForRowAtPoint(buttonPosition) {
                nuevaOcurrenciaViewController.idEvento = self.eventos[indexPathCeldaSeleccionada.row].id
            }
        }
        
        if(segue.identifier == "verHistorial"){
            let historicoViewController = segue.destinationViewController as! HistorialVC
            let index = sender as! NSIndexPath
            historicoViewController.idEvento = self.eventos[index.row].id
            }
        }
        
        
}

