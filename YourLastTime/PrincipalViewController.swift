//
//  PrincipalViewController.swift
//  Last Time
//
//  Created by Alberto Banet Masa on 28/5/15.
//  Copyright (c) 2015 UCM. All rights reserved.
//

import UIKit



class PrincipalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate
{

    @IBOutlet weak var lblTitulo: SpringLabel!
    @IBOutlet weak var tableView: UITableView!

    private var bbdd: EventosDB
    private var eventos: [Evento]
    private var eventosFiltrados: [Evento] = [Evento]() //Eventos filtrados por el buscador
    private var buscador = UISearchController()
    private var filtroAplicado = false

    private var hayqueBorrarRegistro = false // usado en protocolo alertaVC
    private var buscadorActivado = false   // usado para inhabilitar botones cuando está el buscador activado
   
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
        
        // Creamos una vista como background de la tabla para evitar que quede gris al desplazar la tabla (con buscador no cogía el color de background)
        let backgroundView = UIView(frame: self.tableView.bounds)
        backgroundView.backgroundColor = YourLastTime.colorBackground
        self.tableView.backgroundView = backgroundView
        
        // Configuración searchController
        self.buscador = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.delegate = self
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.tintColor =  YourLastTime.colorFondoCelda
            
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        }) ()
        
        
        self.tableView.reloadData()
        // TODO: posibilidad de reordenar filas?
        //tableView.setEditing(true, animated:true)
    }

    
    
    override func viewWillAppear(animated: Bool) {
        // generamos los eventos ordenados 
        eventos = bbdd.arrayEventos()
    
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
        if self.buscador.active {
            return self.eventosFiltrados.count
        } else {
        return eventos.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! EntradaTableViewCell
        let fecha = Fecha()
        if !filtroAplicado {
        cell.lbDescripcion.text = eventos[indexPath.row].descripcion
        cell.lblHace.text = eventos[indexPath.row].cuantoTiempoHaceDesdeLaUltimaVez()
        cell.lblFecha.text = fecha.devolverFechaLocalizada(eventos[indexPath.row].fecha)
        cell.lblHora.text = eventos[indexPath.row].hora
        cell.lblContador.text = String(eventos[indexPath.row].contador)
        cell.idEvento = eventos[indexPath.row].id
        cell.entradaView.delay = CGFloat(0.05) * CGFloat(indexPath.row)
        cell.entradaView.animation = "slideRight"
        cell.entradaView.animate()
            if(eventos[indexPath.row].cantidad > 0) {
                cell.imgDespertador.image = imagenDespertador(eventos[indexPath.row])
                cell.imgDespertador.hidden = false
            } else {
                cell.imgDespertador.hidden = true
            }
            
        } else {
            cell.lbDescripcion.text = eventosFiltrados[indexPath.row].descripcion
            cell.lblHace.text = eventos[indexPath.row].cuantoTiempoHaceDesdeLaUltimaVez()
            cell.lblFecha.text = fecha.devolverFechaLocalizada(eventosFiltrados[indexPath.row].fecha)
            cell.lblHora.text = eventosFiltrados[indexPath.row].hora
            cell.lblContador.text = String(eventosFiltrados[indexPath.row].contador)
            cell.idEvento = eventosFiltrados[indexPath.row].id
            if(eventosFiltrados[indexPath.row].cantidad > 0) {
                cell.imgDespertador.image = imagenDespertador(eventos[indexPath.row])
                cell.imgDespertador.hidden = false
            } else {
                cell.imgDespertador.hidden = true
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if !self.buscadorActivado {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
       
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var arrayAcciones = [AnyObject]()

        // Ver historial
        // Si no hay ocurrencias no mostramos la acción correspondiente
        
        if bbdd.tieneOcurrenciasElEvento(self.eventos[indexPath.row].id) {
            var historialRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: NSLocalizedString("History", comment: ""), handler:{action, indexpath in
            self.performSegueWithIdentifier("verHistorial", sender: indexPath)
            });
            historialRowAction.backgroundColor =  YourLastTime.colorAccion
            arrayAcciones.append(historialRowAction)
        }
        
        // Creación de una alarma
        // Si no hay ninguna ocurrencia no se pueden mostrar alarmas
        if bbdd.tieneOcurrenciasElEvento(self.eventos[indexPath.row].id) {
            var alarmaRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: NSLocalizedString("Alarm", comment: ""), handler:{action, indexpath in
                self.performSegueWithIdentifier("crearAlarma", sender: indexPath)
            });
            alarmaRowAction.backgroundColor =  YourLastTime.colorAccion2
            arrayAcciones.append(alarmaRowAction)
        }
        
        // Acción de borrado
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: NSLocalizedString("Delete", comment: ""), handler:{action, indexpath in
                             var idEventoEliminar = ""
                if !self.filtroAplicado {
                    idEventoEliminar = self.eventos[indexPath.row].id
                    self.eventos.removeAtIndex(indexPath.row)
                } else {
                    idEventoEliminar = self.eventosFiltrados[indexPath.row].id
                    self.eventosFiltrados.removeAtIndex(indexPath.row)
                    // Hay que eliminar también el evento de la lista eventos para que no aparezca al volver del buscardor
                    self.eliminarEventoArrayEventos(idEventoEliminar)
                }
                
                
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
        deleteRowAction.backgroundColor =  YourLastTime.colorAccion3
        arrayAcciones.append(deleteRowAction)
        return arrayAcciones
    }
    

    
    // MARK: Edición de las celdas
//    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
//        
//    }
    
    // Ocultamos la barra de estatus
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
   
    
    @IBAction func touchDown(sender: AnyObject) {
        let boton = sender as! SpringButton
        boton.animation = "pop"
        boton.animate()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if !self.buscadorActivado {
            return true
        } else {
            return false
        }
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
             if !filtroAplicado {
                historicoViewController.idEvento = self.eventos[index.row].id
             } else {
                historicoViewController.idEvento = eventosFiltrados[index.row].id
            }
            }
        
        if (segue.identifier == "crearAlarma") {
            let alarmaViewController = segue.destinationViewController as! NuevaAlarmaVC
            let index = sender as! NSIndexPath
            if !filtroAplicado {
                alarmaViewController.idEvento = self.eventos[index.row].id
            } else {
                alarmaViewController.idEvento = eventosFiltrados[index.row].id
            }
        }
        
    }
    
    // MARK: Delegado de uisearchcontroller
    func didPresentSearchController(searchController: UISearchController) {
        self.buscadorActivado = true
        println("buscador presentado")
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        self.buscadorActivado = false
        println("buscador cancelado")
    }
        
    // MARK: Función para filtrar resultados
    func filtrarContenidoParaTextoBuscado(texto: String){
        if texto.length != 0 {
        filtroAplicado = true
        self.eventosFiltrados = self.eventos.filter({(evento:Evento)->Bool in
            let stringMatch = evento.descripcion.rangeOfString(texto)
            return stringMatch != nil
        })
        } else {
            eventosFiltrados = eventos
            filtroAplicado = false
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filtrarContenidoParaTextoBuscado(searchController.searchBar.text)
        self.tableView.reloadData()
    }
    
   
   
    
    
    // MARK: Funciones auxiliares
    func eliminarEventoArrayEventos(idEvento: String) {
        for (index,evento) in enumerate(eventos) {
            if evento.id == idEvento {
                eventos.removeAtIndex(index)
                break
            }
        }
    }
    
    func imagenDespertador(evento: Evento) -> UIImage {
        // para depurar
        let intervalo =  evento.intervaloAlarmaEnHoras()
        let fUltimaOcurrencia = evento.fechaUltimaOcurrencia()
        
        let fechaMedia = NSDate(timeInterval: evento.intervaloAlarmaEnHoras() * 60 * 30, sinceDate: evento.fechaUltimaOcurrencia())
        let fechaFinal = NSDate(timeInterval: evento.intervaloAlarmaEnHoras() * 60 * 60, sinceDate: evento.fechaUltimaOcurrencia())
        let ahora = NSDate(timeIntervalSinceNow: 0)
        
        var nombreImagen = "despertador"
        if ahora.isGreaterThanDate(fechaFinal) {
            nombreImagen = "despertadorRojo"
        } else if ahora.isGreaterThanDate(fechaMedia) {
            nombreImagen = "despertadorNaranja"
        }
        return UIImage(named: nombreImagen)!
    }
   
    
}

