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
    @IBOutlet weak var txtViewNombreEvento: UITextView!
    @IBOutlet weak var lblHace: UILabel!
    @IBOutlet weak var lblUltimaSemana: UILabel!
    @IBOutlet weak var lblResultadoUltimaSemana: UILabel!
    @IBOutlet weak var lblUltimoMes: UILabel!
    @IBOutlet weak var lblResultadoUltimoMes: UILabel!
    @IBOutlet weak var lblUltimoAnno: UILabel!
    @IBOutlet weak var lblResultadoUltimoAnno: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblEtiquetaMedia: UILabel!
    @IBOutlet weak var lblMedia: UILabel!
    
    
    @IBOutlet weak var btnCerrar: SpringButton!
    @IBOutlet var btnShare: UIButton!
    
    @IBOutlet weak var viewResume: UIView!
    
    
    var idEvento: String!
    var database: EventosDB!
    var ocurrencias: [Ocurrencia] = [Ocurrencia]()
    var ocurrenciaSeleccionada: Int? // la ocurrencia con la que se está trabajando
    var ocurrenciaModificada = false // ¿se ha modificado una ocurrencia?
    var tituloEventoModificado = false
    var originalOffset = CGPoint(x: 0.0, y: 0.0)
    var isCustomizeDatePickerShow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Status del color de fondo
        // Comentado el 10 - 10 - 2019: en iOS 13 no funciona y el truco para hacerlo descuadra otros elementos.
        //setStatusBarBackgroundColor(color: YourLastTime.colorBackground)
      
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.separatorStyle = .none
        
        
        database = EventosDB()
        
        txtViewNombreEvento.text = database.encontrarEvento(idEvento)!.descripcion
      txtViewNombreEvento.textColor = YourLastTime.colorTituloEvento
      txtViewNombreEvento.backgroundColor = YourLastTime.colorAccion2
        txtViewNombreEvento.isScrollEnabled = false
        txtViewNombreEvento.isEditable = true
        txtViewNombreEvento.isSelectable = true
        txtViewNombreEvento.delegate = self
        
        
        // Gesto para cerrar teclado
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // Animación del botón para cerrar
        _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(HistorialVC.agitar), userInfo: nil, repeats: true)
        
        // Listening de la grabación de fecha y hora en la bbdd
        NotificationCenter.default.addObserver(self, selector: #selector(onDateTimeChangedInDatabase(_:)), name: .didDateTimeChangedInDatabase, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ocurrencias = database.arrayOcurrencias(idEvento)
        
        
        // Calculamos los datos estadísticos
        
        // Última vez hace...
        lblHace.text = database.encontrarEvento(idEvento)!.cuantoTiempoHaceDesdeLaUltimaVez()
        
        // Ocurrencias en última semana, mes y año
        let (ocurrenciasSemana, ocurrenciasMes, ocurrenciasAnno) = database.contarOcurrenciasSemanaMesAnno(idEvento)
        lblUltimaSemana.text = NSLocalizedString("Last week: ", comment: "")
        lblResultadoUltimaSemana.text =  String(ocurrenciasSemana)
        lblUltimoMes.text = NSLocalizedString("Last month: ", comment: "")
        lblResultadoUltimoMes.text = String(ocurrenciasMes)
        lblUltimoAnno.text = NSLocalizedString("Last year: ", comment: "")
        lblResultadoUltimoAnno.text = String(ocurrenciasAnno)
        lblEtiquetaMedia.text = NSLocalizedString("Average: ", comment: "")
        
        // Total de ocurrencias
        lblTotal.text = String(ocurrencias.count)
        
        // Media de las ocurrencias. Sólo si hay más de 1 ocurrencia.
        if ocurrencias.count > 1 {
            lblMedia.text = Ocurrencia.mediaOcurrencias(ocurrencia1: ocurrencias[0], ocurrencia2: ocurrencias[ocurrencias.count - 1], numOcurrencias: ocurrencias.count)
        } else {
            lblMedia.text = "N/A"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Ocultamos la barra de estatus
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    // MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Número de ocurrencias: \(ocurrencias.count)")
        return ocurrencias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CeldaHistorial") as! CeldaHistorialTableViewCell
        // Al reutilizar las celdas hay que tener cuidado con el relleno de los adornos.
        
        if let indice = ocurrenciaSeleccionada {
            if indice == indexPath.row {
                cell.adorno.rellenar = true
                cell.adorno.setNeedsDisplay()
            }  else {
                cell.adorno.rellenar = false
                cell.adorno.setNeedsDisplay()
            }
        }
        
        if indexPath.row == ocurrencias.count - 1 {
            cell.adorno.esUltimaCelda = true
            cell.adorno.setNeedsDisplay()
        } else if cell.adorno.esUltimaCelda {
            cell.adorno.esUltimaCelda = false
            cell.adorno.setNeedsDisplay()
        }
        let fecha = Fecha()
        
        cell.lblFecha.text = fecha.devolverFechaLocalizada(ocurrencias[indexPath.row].fecha)
        cell.lblHora.text = ocurrencias[indexPath.row].hora
        cell.textViewDescripcion.text = ocurrencias[indexPath.row].descripcion
        cell.textViewDescripcionCopia.text = ocurrencias[indexPath.row].descripcion
        cell.textViewDescripcion.delegate = self
        cell.textViewDescripcion.tag = indexPath.row // identificamos los uitextview
        cell.lblFecha.tag = indexPath.row
        
        
        // tap de la celda
        let tapFecha = UITapGestureRecognizer(target: self, action: #selector(HistorialVC.tapLabel(_:)))
        let tapHora = UITapGestureRecognizer(target: self, action: #selector(HistorialVC.tapLabel(_:)))
        cell.lblFecha.addGestureRecognizer(tapFecha)
        cell.lblHora.addGestureRecognizer(tapHora)
        
        // Calculo de la diferencia entre dos ocurrencias
        cell.lblHace.text = self.informarIntervalodeDiferencia(fila: indexPath.row, ocurrencia: ocurrencias[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var arrayAcciones = [UITableViewRowAction]()
        
        // alerta de borrado
        let tituloAlerta = String.localizedStringWithFormat(NSLocalizedString("Delete Ocurrence", comment: ""), "Borrar ocurrencia seleccionada")
        let alert = UIAlertController(title: tituloAlerta, message: NSLocalizedString("Msg Delete Ocurrencia", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { [unowned self] action in
            
              // si se está intentando eliminar la primera ocurrencia hay que guardar la fecha de la segunda para reemplazar en eventos.
              var fechaPenultimaOcurrencia: Fecha?
              var esPrimeraOcurrencia: Bool = false
              if self.ocurrencias.count > 1 && indexPath.row == 0 {
                  esPrimeraOcurrencia = true
                  fechaPenultimaOcurrencia = Fecha(fecha: self.ocurrencias[1].fecha, hora: self.ocurrencias[1].hora)
              }
                let idOcurrenciaABorrar = self.ocurrencias[indexPath.row].getId()
                let idEventoPadre       = self.ocurrencias[indexPath.row].idEvento
                self.ocurrencias.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            
                // Tenemos que eliminar la ocurrencia
                
                if self.database.eliminarOcurrenciaId(idOcurrenciaABorrar, fromEvento: idEventoPadre) {
                  // si era la primera incidencia hay que poner como fecha de última vez del evento la fecha de la que ahora es primera incidencia.
                  if esPrimeraOcurrencia, let fecha = fechaPenultimaOcurrencia {
                    self.database.updateEventoDate(idEvento: idEventoPadre, fecha: fecha)
                    self.lblHace.text = self.database.encontrarEvento(idEventoPadre)!.cuantoTiempoHaceDesdeLaUltimaVez()
                  }
                    print("Eliminada ocurrencia \(idOcurrenciaABorrar)  asociada a idEvento = \(idEventoPadre)")
                    DispatchQueue.main.async {
                      self.tableView.reloadData()
                    }
                } else {
                    print("No se ha podido eliminar la ocurrencia asociada con idEvento = \(idEventoPadre)")
                }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        
        // Acción de borrado
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: NSLocalizedString("Delete", comment: ""), handler:{action, indexpath in
                self.present(alert, animated: true)
            })
        deleteRowAction.backgroundColor =  YourLastTime.colorAccion3
        arrayAcciones.append(deleteRowAction)
        return arrayAcciones
    }
    
    func desplazarTableView(_ tableView: UITableView, offset: CGFloat) {
        var contentOffset:CGPoint = tableView.contentOffset
        originalOffset = contentOffset
        print("originalOffset: \(originalOffset)")
        contentOffset.y = offset
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0.1, options: UIView.AnimationOptions.curveLinear, animations: {
                self.tableView.contentOffset = contentOffset
            }, completion: nil)
            
        }
    }
    
    func desplazarTableViewToOrigin(_ tableView: UITableView) {
        DispatchQueue.main.async {
          print("vamos a mover a un originalOffset de: \(self.originalOffset)")
            UIView.animate(withDuration: 0.5, delay: 0.1, options: UIView.AnimationOptions.curveLinear, animations: {
                self.tableView.contentOffset = self.originalOffset
                self.originalOffset = CGPoint(x: 0, y: 0)
            }, completion: nil)
        }
    }
    
    @objc func agitar() {
        btnCerrar.animation = "swing"
        btnCerrar.force = 5.0
        btnCerrar.duration = 0.5
        btnCerrar.animate()
    }
    
    // MARK: Función Compartir
    @IBAction func shareHistorial(_ sender: UIButton) {
        //btnShare.alpha = 0
        
        let texto = "¡La última vez que \(txtViewNombreEvento.text!)!"
        let imagenCaptura = screenShot()
        //let imagen = UIImageJPEGRepresentation(imagenCaptura, 1.0)!
        let imagen = imagenCaptura.jpegData(compressionQuality: 1.0)!
        let activityViewController = UIActivityViewController(activityItems: [imagen], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            .assignToContact,
            .addToReadingList,
            .postToFlickr,
            .postToTencentWeibo]
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    
    // MARK: Capturar pantalla
    func screenShot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(viewResume.bounds.size, viewResume.isOpaque, 0.0)
        viewResume.drawHierarchy(in: viewResume.bounds, afterScreenUpdates: false)
        let viewShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //        UIGraphicsBeginImageContext(CGSize(width: self.viewResume.frame.size.width, height: self.viewResume.frame.size.height))
        //        UIGraphicsGetCurrentContext()!
        //        self.view?.drawHierarchy(in: self.viewResume.frame, afterScreenUpdates: false)
        //        let screenShot = UIGraphicsGetImageFromCurrentImageContext()
        //        UIGraphicsEndImageContext()
        // return screenShot!
        return viewShot!
    }
    
    func informarIntervalodeDiferencia(fila: Int, ocurrencia: Ocurrencia)->String{
        if fila != ocurrencias.count - 1  { // todo menos la última fila
            // Restamos de la ocurrencia actual la ocurrencia anterior
            let fechaActualString = ocurrencia.formatoMMddYYYYHHmm()
            let fechaActualDate = Fecha().fechaCompletaStringToDate(fechaActualString)
            let fechaAnteriorString = ocurrencias[fila+1].formatoMMddYYYYHHmm()
            let fechaAnteriorDate = Fecha().fechaCompletaStringToDate(fechaAnteriorString)
            let intervalo = fechaActualDate.timeIntervalSince(fechaAnteriorDate) // número de segundos de diferencia
            print("Restando \(fechaActualString) de \(fechaAnteriorString). Intervalo: \(intervalo.description)")
            return Fecha().stringFromTimeInterval(interval: intervalo)
        }
        return NSLocalizedString("First time!", comment:"")
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    //MARK: Etiqueta pulsada
    @objc func tapLabel(_ sender:UITapGestureRecognizer) {
        print("Tap en fecha")
        if let dp = view.viewWithTag(CustomizeDatePickerConfiguration.tag.rawValue) as? CustomizeDatePicker {
            dp.cancelPulsado()
        }
        guard isCustomizeDatePickerShow == false else {
            return
        }
        isCustomizeDatePickerShow = true
        let datePicker: CustomizeDatePicker = {
            var keyboardSize = KeyboardService.keyboardSize()
          // apaño 30 sept 2019. A veces keyboardSize es .zero y creaba muchos problemas. Asignamos un tercio de la pantalla por defecto. 
          if keyboardSize == .zero {
            keyboardSize = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/3)
          }
            return CustomizeDatePicker(frame: keyboardSize)
        }()
        datePicker.delegate = self
        
        setTextViewsAsNoEditable()
        removeDatePicker()
        if let lbl = sender.view as? UILabel {
            desmarcarTodasCeldas()
            // Marcar celda como celda de edición
            if let cellSelect = tableView.cellForRow(at: IndexPath(row:lbl.tag,section:0)) as? CeldaHistorialTableViewCell {
                ocurrenciaSeleccionada = lbl.tag
              DispatchQueue.main.async {
                cellSelect.adorno.rellenar = true
                cellSelect.adorno.setNeedsDisplay()
              }  
            }
            let ocurrencia = ocurrencias[lbl.tag]
            let fecha = Fecha()
            let date = fecha.fechaCompletaStringToDate(ocurrencia.fecha+ocurrencia.hora)
            // Crear datepicker pasando la fecha a modificar
            let newFrame = CGRect(x:view.frame.origin.x,
                                  y: view.frame.origin.y - 200,
                                  width: view.frame.width,
                                  height: view.frame.height)
            
            datePicker.date = date
            let minDate = getMinimumDateForDatePicker()
            let maxDate = getMaximumDateForDatePicker()
            datePicker.minimunDate = minDate
            datePicker.maximumDate = maxDate
            view.addSubview(datePicker)
            //      UIView.animate(withDuration: 1.0, animations: {
            //        self.datePicker.frame = newFrame
            //      }, completion: nil)
            
            // Desplazar tabla si la etiqueta va a quedar oculta
            let keyboardSize = KeyboardService.keyboardSize()
            let aRect = lbl.frame
            
            let pointInTable:CGPoint = lbl.superview!.convert(lbl.frame.origin, to: tableView)
          let puntoAltoTecladoY = tableView.frame.height - datePicker.frame.height//keyboardSize.height
            print("if ((pointInTable.y (\(pointInTable.y)) + aRect.height/2 (\(aRect.height/2))) > puntoAltoTecladoY (\(puntoAltoTecladoY)))")
            if ((pointInTable.y + aRect.height/2) > puntoAltoTecladoY) {
                // Tiene q haber desplazamiento
//                print("contentOffset inicial: \(tableView.contentOffset.y)")
//                print("Tamaño teclado: \(keyboardSize.height)")
//                print("tableView.frame.height: \(tableView.frame.height)")
//                print("posición textView.superview: \(lbl.superview!.frame.height)")
//                print("pointInTable de la uitextView: \(pointInTable.y)")
                let offset = pointInTable.y - puntoAltoTecladoY + lbl.superview!.frame.height
                desplazarTableView(tableView, offset: offset)
            }
        }
    }
    
    func getMinimumDateForDatePicker() -> Date? {
        guard ocurrenciaSeleccionada != nil else {
            return nil
        }
        if ocurrenciaSeleccionada! < ocurrencias.count - 1 {
            let minFecha = ocurrencias[ocurrenciaSeleccionada! + 1].fecha
            let minHora  = ocurrencias[ocurrenciaSeleccionada! + 1].hora
            let fecha = Fecha(fecha: minFecha, hora: minHora)
            return fecha.fechaCompletaStringToDate()
        } else {
            return nil
        }
    }
  
  func getMaximumDateForDatePicker() -> Date? {
    guard ocurrenciaSeleccionada != nil else {
        return nil
    }
    
    if ocurrenciaSeleccionada! > 0 {
      //No es la primera ocurrencia, la fecha y hora máxima será la de la anterior ocurrencia
      let maxFecha = ocurrencias[ocurrenciaSeleccionada! - 1].fecha
      let maxHora  = ocurrencias[ocurrenciaSeleccionada! - 1].hora
      let fecha = Fecha(fecha:maxFecha, hora: maxHora)
      return fecha.fechaCompletaStringToDate()
    } else {
      return nil
    }
  }
    
    func updateLabelFechaHora(paraOcurrencia ocurrencia: Int, conFecha fecha: Fecha) {
        let indice = IndexPath(row: ocurrencia, section: 0)
        if let cellSelect = tableView.cellForRow(at: indice) as? CeldaHistorialTableViewCell {
            // Actualizamos la ocurrencia correspondiente para no perder coherencia de datos
            ocurrencias[ocurrencia].fecha = fecha.fecha
            ocurrencias[ocurrencia].hora  = fecha.hora
            
            cellSelect.lblFecha.text = fecha.devolverFechaLocalizada(fecha.fecha)
            cellSelect.lblHora.text = fecha.hora
            // Calculo de la diferencia entre dos ocurrencias
            cellSelect.lblHace.text = self.informarIntervalodeDiferencia(fila: ocurrencia, ocurrencia: ocurrencias[ocurrencia])
            // refrescar valores de los textos
            cellSelect.setNeedsDisplay()
        }
    }
    
    func desmarcarTodasCeldas () {
      DispatchQueue.main.async {
        _ = self.tableView.subviews.filter{$0 is CeldaHistorialTableViewCell}.map{
        ($0 as? CeldaHistorialTableViewCell)?.adorno.rellenar = false
        ($0 as? CeldaHistorialTableViewCell)?.adorno.setNeedsDisplay()
          }
        }
        //ocurrenciaSeleccionada = nil
    }
    
    func setTextViewsAsNoEditable() {
        _ = tableView.subviews.filter{$0 is CeldaHistorialTableViewCell}.map{
            if let txtView = ($0 as? CeldaHistorialTableViewCell)?.textViewDescripcion {
                desmarcarTextView(txtView)
                txtView.resignFirstResponder()
            }
        }
        desmarcarTextView(self.txtViewNombreEvento)
        txtViewNombreEvento.resignFirstResponder()
    }
    
    func removeDatePicker() {
        _ = view.subviews.filter {$0 is CustomizeDatePicker}.map{
            ($0 as? CustomizeDatePicker)?.removeFromSuperview()
        }
    }
  
  func setStatusBarBackgroundColor(color: UIColor) {
    if #available(iOS 13.0, *) { // truco para colorear la barra de estatus en iOS 13
//        let app = UIApplication.shared
//        let statusBarHeight: CGFloat = app.statusBarFrame.size.height
//
//        let statusbarView = UIView()
//        statusbarView.backgroundColor = color
//        view.addSubview(statusbarView)
//        statusbarView.translatesAutoresizingMaskIntoConstraints = false
//        statusbarView.heightAnchor
//            .constraint(equalToConstant: statusBarHeight).isActive = true
//        statusbarView.widthAnchor
//            .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
//        statusbarView.topAnchor
//            .constraint(equalTo: view.topAnchor).isActive = true
//        statusbarView.centerXAnchor
//            .constraint(equalTo: view.centerXAnchor).isActive = true
    } else { // sólo se puede cambiar el statusBar en iOS anterior al 13.0!!
      guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
      statusBar.backgroundColor = color
    }
  }
    
}


// MARK: UITextViewDelegate
extension HistorialVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard isCustomizeDatePickerShow == false else { return } // que no esté el cambio de fecha activo
        
        
        removeDatePicker()
        remarcarTextView(textView)
        
        if textView != txtViewNombreEvento { // en una celda del historial
            self.ocurrenciaModificada = false
            if let cellSelect = tableView.cellForRow(at: IndexPath(row:textView.tag,section:0)) as? CeldaHistorialTableViewCell {
                desmarcarTodasCeldas()
                cellSelect.adorno.rellenar = true
                cellSelect.adorno.setNeedsDisplay()
            }
        } else {
            desmarcarTodasCeldas()
            self.tituloEventoModificado = false
        }
    }
    
  // Vamos a limitar el número de caracteres en título de evento
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    return true
  }
  
  
    func textViewDidEndEditing(_ textView: UITextView) {
        desmarcarTextView(textView)
        
        if textView != txtViewNombreEvento {
            desplazarTableViewToOrigin(tableView)
            
            guard self.ocurrenciaModificada else {
                return
            }
            let ocurrenciaModificada = ocurrencias[textView.tag]
            // grabar la modificación de la descripción en la ocurrencia modificada
            database.modificarOcurrencia(ocurrenciaModificada.idOcurrencia, ocurrenciaModificada.idEvento, descripcion: textView.text.removingAllExtraNewLines)
            // refrescar la tabla para que coja el nuevo valor?
        } else {
            guard self.tituloEventoModificado else { return }
            let nuevoNombre = textView.text.removingAllExtraNewLines
            guard nuevoNombre.count > 0 else {
              return
            }
            // Modificar el título del evento
            database.updateEventoName(idEvento: self.idEvento, nombre: nuevoNombre)
        }
    }
    
  func textViewDidChange(_ textView: UITextView) {
    if textView != txtViewNombreEvento {
      self.ocurrenciaModificada = true
    } else {
      
      
        self.tituloEventoModificado = true
      }
    }
 
    // TODO: Hay que hacer que sólo se mueva si está en la zona cubierta por el teclado. Y que al salir de editar vuelva a la posición de origen
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard isCustomizeDatePickerShow == false else { return false}
        
        if textView != txtViewNombreEvento {
            let keyboardSize = KeyboardService.keyboardSize() // Tamaño del teclado
            let aRect = textView.frame
            
            let pointInTable:CGPoint = textView.superview!.convert(textView.frame.origin, to: tableView)
            let puntoAltoTecladoY = tableView.frame.height - keyboardSize.height
            print("if ((pointInTable.y (\(pointInTable.y)) + aRect.height/2 (\(aRect.height/2))) > puntoAltoTecladoY (\(puntoAltoTecladoY)))")
            if ((pointInTable.y + aRect.height/2) > puntoAltoTecladoY) {
                // Tiene q haber desplazamiento
                
                print("contentOffset inicial: \(tableView.contentOffset.y)")
                print("Tamaño teclado: \(keyboardSize.height)")
                print("tableView.frame.height: \(tableView.frame.height)")
                print("posición textView.superview: \(textView.superview!.frame.height)")
                print("pointInTable de la uitextView: \(pointInTable.y)")
                let offset = pointInTable.y - puntoAltoTecladoY + textView.superview!.frame.height
                desplazarTableView(tableView, offset: offset)
            }
        }
        return true;
    }
    
    
    func remarcarTextView (_ textView: UITextView) {
        textView.layer.borderColor = YourLastTime.colorFondoCelda.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.backgroundColor = YourLastTime.colorFondoCelda.colorWithAlpha(0.3)
    }
    
    func desmarcarTextView (_ textView: UITextView) {
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.layer.borderWidth = 0
        textView.backgroundColor = UIColor.clear
    }
    
    @objc func onDateTimeChangedInDatabase(_ notification: Notification) {
        // Última vez hace...
        // Si no se ejecutaba en el main daba problemas de database is locked
        DispatchQueue.main.async {
            self.lblHace.text = self.database.encontrarEvento(self.idEvento)!.cuantoTiempoHaceDesdeLaUltimaVez()
            self.lblHace.setNeedsDisplay()
        }
    }
}


// MARK: CustomizeDatePickerDelegate
extension HistorialVC: CustomizeDatePickerDelegate {
    // Actualiza la base de datos. Si viene del botón cancel la fecha es nil
    func setFechaValueToDatabase(_ fecha: Fecha?) {
        guard ocurrenciaSeleccionada != nil else {
            return
        }
        if let fecha = fecha {
            let ocur = ocurrencias[ocurrenciaSeleccionada!]
            database.modificarOcurrenciaFechaHora(ocur.idOcurrencia, ocur.idEvento, nuevaFecha: fecha)
            updateLabelFechaHora(paraOcurrencia: ocurrenciaSeleccionada!, conFecha: fecha)
            if ocurrenciaSeleccionada! == 0 {// es la primera, hay que cambiar la fecha del evento
                database.updateEventoDate(idEvento: ocur.idEvento, fecha: fecha)
            }
        }
        desplazarTableViewToOrigin(tableView)
        tableView.reloadData()
    }
    
    
}



