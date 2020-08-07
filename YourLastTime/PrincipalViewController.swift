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
    @IBOutlet weak var buscadorView: UIView!
    @IBOutlet weak var btnLupa: SpringButton!
    
    @IBOutlet weak var backView: UIImageView!
    
  
  @IBOutlet weak var constraintTopBuscadorView: NSLayoutConstraint!
 
    

    fileprivate var bbdd: EventosDB
    fileprivate var eventos: [Evento]
    fileprivate var eventosFiltrados: [Evento] = [Evento]() //Eventos filtrados por el buscador
    fileprivate var buscador = UISearchController()
    fileprivate var buscadorOculto = true
    fileprivate var filtroAplicado = false

    fileprivate var hayqueBorrarRegistro = false // usado en protocolo alertaVC
    fileprivate var buscadorActivado = false   // usado para inhabilitar botones cuando está el buscador activado
   
    required init?(coder aDecoder: NSCoder) {
        bbdd = EventosDB()
        eventos = bbdd.arrayEventos()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Edge pan
        addingEdgePanDetection()
        
        // Título
        lblTitulo.text = NSLocalizedString("When was the last time I...?", comment:"cabecera de la pantalla principal")
        lblTitulo.textColor = YourLastTime.colorTextoPrincipal
      
        tableView.delegate = self
        tableView.dataSource = self
        
        // Crear background
        setupBackground(imageView: backView)
        
        // Creamos una vista como background de la tabla para evitar que quede gris al desplazar la tabla (con buscador no cogía el color de background)
       // let backgroundView = UIView(frame: self.tableView.bounds)
        //YourLastTime.colorBackground
       // self.tableView.backgroundView = backgroundView
      //  self.tableView.backgroundView?.alpha = 0.5
        //self.tableView.bounces = false
        
        // Nos registramos como observadores del cambio de background
        NotificationCenter.default.addObserver(self, selector: #selector(onDidChangeBackground), name: .didChangeBackground , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReloadEventsTable), name: Notification.Name(rawValue: "reloadEventsTable"), object: nil)
        
        
        // Configuración searchController
        self.buscador = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.delegate = self
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.searchBarStyle = .minimal//.Minimal
            controller.searchBar.tintColor = YourLastTime.colorFondoCelda
            controller.searchBar.backgroundColor = YourLastTime.colorBackground

            //self.tableView.tableHeaderView = controller.searchBar
            self.buscadorView.addSubview(controller.searchBar)
            //self.buscadorView.hidden = true
            self.buscadorView.alpha = 0
            return controller
        }) ()
        
        
        //abm 04-01-2016 self.tableView.reloadData() lo ponemos en viewWillAppear
        // TODO: posibilidad de reordenar filas?
        //tableView.setEditing(true, animated:true)
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        // Ocultamos el buscador
        // 16/11/2016: Añadimos el siguiente if ya que al ejecutar sin celdas el scrollToRow daba error.
        if self.tableView.numberOfRows(inSection: 0) > 0 {
          self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
        }
        // generamos los eventos ordenados
        eventos = bbdd.arrayEventos()
        self.tableView.reloadData()
    }
  
  override func viewDidAppear(_ animated: Bool) {
    updateConstraints()
  }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: UITableViewDataSource Protocol
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.buscador.isActive {
            return self.eventosFiltrados.count
        } else {
        return eventos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! EntradaTableViewCell
        let fecha = Fecha()
        if !filtroAplicado {
            cell.lbDescripcion.text = eventos[indexPath.row].descripcion
            //print(cell.lbDescripcion.text)
            if bbdd.tieneOcurrencias(idEvento: eventos[indexPath.row].id) {
                cell.lblHace.text = eventos[indexPath.row].cuantoTiempoHaceDesdeLaUltimaVez()
            } else {
                cell.lblHace.text = NSLocalizedString("It didn't happend yet!", comment: "")
            }
            cell.lblFecha.text = fecha.devolverFechaLocalizada(eventos[indexPath.row].fecha)
            cell.lblHora.text = eventos[indexPath.row].hora
            cell.lblContador.text = String(eventos[indexPath.row].contador)
            cell.idEvento = eventos[indexPath.row].id
            cell.entradaView.delay = CGFloat(0.01) * CGFloat(indexPath.row)
            cell.entradaView.animation = "slideRight"
            cell.entradaView.animate()
            if(eventos[indexPath.row].cantidad > 0) {
                cell.imgDespertador.image = UIImage(named: "despertador_white")?.withRenderingMode(.alwaysTemplate)
                cell.imgDespertador.tintColor = eventos[indexPath.row].colorParaEvento()
                cell.imgDespertador.isHidden = false
                cell.lblDetalleAlarma.text = eventos[indexPath.row].descripcionAlarma()
            } else {
                cell.imgDespertador.isHidden = true
                cell.lblDetalleAlarma.text = ""
            }
            
        } else {
            cell.lbDescripcion.text = eventosFiltrados[indexPath.row].descripcion
            cell.lblHace.text = eventosFiltrados[indexPath.row].cuantoTiempoHaceDesdeLaUltimaVez()
            cell.lblFecha.text = fecha.devolverFechaLocalizada(eventosFiltrados[indexPath.row].fecha)
            cell.lblHora.text = eventosFiltrados[indexPath.row].hora
            cell.lblContador.text = String(eventosFiltrados[indexPath.row].contador)
            cell.idEvento = eventosFiltrados[indexPath.row].id
            if(eventosFiltrados[indexPath.row].cantidad > 0) {
                cell.imgDespertador.image = UIImage(named: "despertador_white")?.withRenderingMode(.alwaysTemplate)
                cell.imgDespertador.tintColor = eventosFiltrados[indexPath.row].colorParaEvento()
                cell.imgDespertador.isHidden = false
            } else {
                cell.imgDespertador.isHidden = true
            }
        }
        
        // Fondo de la celda transparente para mostrar la vista background de la tabla (foto de fondo)
        cell.backgroundColor = UIColor.clear;
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if !self.buscadorActivado {
//            return true
//        } else {
//            return false
//        }
        
        return true
    }
  
  
  
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var arrayAcciones = [UITableViewRowAction]()

        // Ver historial
        // Si no hay ocurrencias no mostramos la acción correspondiente
        
        if bbdd.tieneOcurrenciasElEvento(self.eventos[indexPath.row].id) {
          let historialRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: NSLocalizedString("History", comment: ""), handler:{action, indexpath in
            self.performSegue(withIdentifier: "verHistorial", sender: indexPath)
            });
            historialRowAction.backgroundColor =  YourLastTime.colorAccion
            arrayAcciones.append(historialRowAction)
        }
        
        // Creación de una alarma
        // Si no hay ninguna ocurrencia no se pueden mostrar alarmas
        if bbdd.tieneOcurrenciasElEvento(self.eventos[indexPath.row].id) {
          let alarmaRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: NSLocalizedString("Alarm", comment: ""), handler:{action, indexpath in
                self.performSegue(withIdentifier: "crearAlarma", sender: indexPath)
            });
            alarmaRowAction.backgroundColor =  YourLastTime.colorAccion2
            arrayAcciones.append(alarmaRowAction)
        }
        
        // alerta de borrado
        let tituloAlerta = String.localizedStringWithFormat(NSLocalizedString("Delete Event", comment: ""), self.eventos[indexPath.row].descripcion)
        let alert = UIAlertController(title: tituloAlerta, message: NSLocalizedString("Msg Delete Event", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { action in
            var idEventoEliminar = ""
            var descripcionEvento: String?
            if !self.filtroAplicado {
                idEventoEliminar = self.eventos[indexPath.row].id
                descripcionEvento = self.eventos[indexPath.row].descripcion
                self.eventos.remove(at: indexPath.row)
            } else {
                idEventoEliminar = self.eventosFiltrados[indexPath.row].id
                descripcionEvento = self.eventosFiltrados[indexPath.row].descripcion
                self.eventosFiltrados.remove(at: indexPath.row)
                // Hay que eliminar también el evento de la lista eventos para que no aparezca al volver del buscardor
                self.eliminarEventoArrayEventos(idEventoEliminar)
            }
            
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            
            // Tenemos que eliminar el evento y sus ocurrencias
            if self.bbdd.eliminarOcurrencias(idEventoEliminar) {
                print("Eliminadas ocurrencias asociadas a idEvento = '\(idEventoEliminar)'")
                // se han eliminado las ocurrencias correctamente. Eliminamos el evento asociado
                if self.bbdd.eliminarEvento(idEventoEliminar, descripcion: descripcionEvento){
                    print("Evento eliminado con id = '\(idEventoEliminar)'")
                    // eliminar alarma asociada si existe (08-01-2019)
                    self.bbdd.eliminarAlarma(idEventoEliminar)
                } else {
                    print("No se puede eliminar Evento con id = '\(idEventoEliminar)'")
                }
            } else {
                print("No se han podido eliminar ocurrencias asociadas con idEvento = '\(idEventoEliminar)'")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        
        // Acción de borrado
      let deleteRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: NSLocalizedString("Delete", comment: ""), handler:{action, indexpath in
        
        
        
        
        self.present(alert, animated: true)
        
        
            
            
        });
        deleteRowAction.backgroundColor =  YourLastTime.colorAccion3
        arrayAcciones.append(deleteRowAction)
        return arrayAcciones
    }
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("celda pulsada")
    // Facilitamos ir al historial al pulsar sobre la celda.
    if bbdd.tieneOcurrenciasElEvento(self.eventos[indexPath.row].id) {
        self.performSegue(withIdentifier: "verHistorial", sender: indexPath)
    }

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
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
   
    
    @IBAction func touchDown(_ sender: AnyObject) {
        let boton = sender as! SpringButton
        boton.animation = "pop"
        boton.animate()
        
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
//        if !self.buscadorActivado {
//            return true
//        } else {
//            return false
//        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pasamos el parámetro idEvento para dar el alta al pulsar el ok en la pantalla de nuevaOcurrencia
        // Cogemos la celda adecuada según la posición del botón pulsado.
        // Quizás una buena forma alternativa sea utilizar un protocolo en nuevaOcurrencia que devuelva Ok o Cancel y se actue en consecuencia.
        
        if self.buscadorActivado {
                self.buscador.isActive = false
        }
        
        if(segue.identifier == "nuevaOcurrencia"){
            let nuevaOcurrenciaViewController = segue.destination as! NuevaOcurrenciaVC
            let buttonPosition: CGPoint = (sender! as AnyObject).convert(CGPoint.zero, to: self.tableView)
            if let indexPathCeldaSeleccionada = self.tableView.indexPathForRow(at: buttonPosition) {
                if !filtroAplicado {
                    nuevaOcurrenciaViewController.idEvento = self.eventos[indexPathCeldaSeleccionada.row].id
                } else {
                    nuevaOcurrenciaViewController.idEvento = self.eventosFiltrados[indexPathCeldaSeleccionada.row].id
                }
            }
        }
        
        if(segue.identifier == "verHistorial"){
            let historicoViewController = segue.destination as! HistorialVC
            let index = sender as! IndexPath
             if !filtroAplicado {
                historicoViewController.idEvento = self.eventos[index.row].id
             } else {
                historicoViewController.idEvento = eventosFiltrados[index.row].id
            }
            }
        
        if (segue.identifier == "crearAlarma") {
            let alarmaViewController = segue.destination as! NuevaAlarmaVC
            let index = sender as! IndexPath
            if !filtroAplicado {
                alarmaViewController.idEvento = self.eventos[index.row].id
            } else {
                alarmaViewController.idEvento = eventosFiltrados[index.row].id
            }
        }
        
        // Comentado 07-08-2020 pq falla con ios 13
        /*
          if(segue.identifier == "CrearNuevoEvento") {
            if #available(iOS 12.0, *) {
                let vc = segue.destination as! NuevoEventoVC
                let activity = Evento.newEventShortcut(thumbnail: UIImage(named: "logo375verdoso"))
                vc.userActivity = activity
                activity.becomeCurrent()
            } else {
                // Fallback on earlier versions
            }
        }
        */
        
    }
    
    // MARK: Delegado de uisearchcontroller
    func didPresentSearchController(_ searchController: UISearchController) {
        self.buscadorActivado = true
        print("buscador presentado")
        // se está escribiendo en el buscador, no se puede ocultar
        self.btnLupa.isEnabled = false
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        self.buscadorActivado = false
        filtroAplicado = false
        self.tableView.reloadData()
        print("buscador cancelado")
        // volvemos a activar la lupa
        self.btnLupa.isEnabled = true
    }
        
    // MARK: Función para filtrar resultados
    func filtrarContenidoParaTextoBuscado(_ texto: String){
        if texto.length != 0 {
        filtroAplicado = true
        self.eventosFiltrados = self.eventos.filter({(evento:Evento)->Bool in
            let stringMatch = evento.descripcion.range(of: texto, options: .caseInsensitive)
            return stringMatch != nil
        })
        } else {
            eventosFiltrados = eventos
            filtroAplicado = false
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.length > 0 {
            self.filtrarContenidoParaTextoBuscado(searchController.searchBar.text!)
            self.tableView.reloadData()
        }
    }
    
   
  // MARK: Acciones de botones
  @IBAction func pulsarLupa(_ sender: UIButton) {
    self.buscadorOculto = !self.buscadorOculto
    //self.buscadorView.hidden = !self.buscadorView.hidden
    
    updateConstraints()
  
    let boton = sender as! SpringButton
    boton.animation = "pop"
    boton.animate()
  }
  
    
    
  // actualización de la constraint de la table view
  func updateConstraints(){
    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut , animations: {
      if self.buscadorOculto {
        self.constraintTopBuscadorView.constant = -self.buscadorView.frame.height
        self.buscadorView.isUserInteractionEnabled = false
        self.buscadorView.alpha = 1.0
        for v in self.buscadorView.subviews {
            v.subviews.forEach({
                $0.alpha = 0
            })
        }
      } else {
        self.buscadorView.isUserInteractionEnabled = true
        self.buscadorView.alpha = 1.0
        self.constraintTopBuscadorView.constant = 0
        self.buscador.isEditing = true
        for v in self.buscadorView.subviews {
            v.subviews.forEach({
                $0.alpha = 1.0
            })
        }
      }
      
      self.view.layoutIfNeeded()
      }, completion: nil)
    
  }
    
    // MARK: Funciones auxiliares
    func eliminarEventoArrayEventos(_ idEvento: String) {
        for (index,evento) in eventos.enumerated() {
            if evento.id == idEvento {
                eventos.remove(at: index)
                break
            }
        }
    }
    
    func imagenDespertador(_ evento: Evento) -> UIImage {
        // para depurar
        _ =  evento.intervaloAlarmaEnHoras()
        _ = evento.fechaUltimaOcurrencia()
        
        let fechaMedia = Date(timeInterval: evento.intervaloAlarmaEnHoras() * 60 * 60 / 2, since: evento.fechaUltimaOcurrencia())
        let fechaFinal = Date(timeInterval: evento.intervaloAlarmaEnHoras() * 60 * 60, since: evento.fechaUltimaOcurrencia())
        let ahora = Date(timeIntervalSinceNow: 0)
        
        var nombreImagen = "despertador"
        if ahora.isGreaterThanDate(fechaFinal) {
            nombreImagen = "despertadorRojo"
        } else if ahora.isGreaterThanDate(fechaMedia) {
            nombreImagen = "despertadorNaranja"
        }
        return UIImage(named: nombreImagen)!
    }
    
    
    
    
  
    // MARK: Configuración de la app
    func addingEdgePanDetection() {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        
        view.addGestureRecognizer(edgePan)
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            print("Screen edge swiped!")
            let chooseImageVC = CustomImagePickerViewController()
            chooseImageVC.modalTransitionStyle = .flipHorizontal
            if #available(iOS 13.0, *) { // por defecto en iOS 13 se abren superponiéndose
              chooseImageVC.modalPresentationStyle = .fullScreen
            }
            self.present(chooseImageVC, animated: true, completion: nil)
        }
    }
    
    // MARK: Notifications
    @objc func onDidChangeBackground() {
        setupBackground(imageView: backView)
    }
    
    @objc func onReloadEventsTable() {
        eventos = bbdd.arrayEventos()
        tableView.reloadData()
    }
}

