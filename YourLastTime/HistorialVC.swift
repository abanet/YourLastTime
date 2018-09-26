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
    @IBOutlet weak var lblNombreEvento: UILabel!
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
  
    var ocurrenciaModificada = false // ¿se ha modificado una ocurrencia?
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.separatorStyle = .none
      
      
        database = EventosDB()
        
        lblNombreEvento.text = database.encontrarEvento(idEvento)!.descripcion
      
      // Gesto para cerrar teclado
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
      self.view.addGestureRecognizer(tapGesture)
      
        // Animación del botón para cerrar
        _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(HistorialVC.agitar), userInfo: nil, repeats: true)
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
        let fecha = Fecha()
        
        cell.lblFecha.text = fecha.devolverFechaLocalizada(ocurrencias[indexPath.row].fecha)
        cell.lblHora.text = ocurrencias[indexPath.row].hora
        cell.textViewDescripcion.text = ocurrencias[indexPath.row].descripcion
        cell.textViewDescripcionCopia.text = ocurrencias[indexPath.row].descripcion
        cell.textViewDescripcion.delegate = self
        cell.textViewDescripcion.tag = indexPath.row // identificamos los uitextview
        // Calculo de la diferencia entre dos ocurrencias
        cell.lblHace.text = self.informarIntervalodeDiferencia(fila: indexPath.row, ocurrencia: ocurrencias[indexPath.row])
        
        // Si la celda a dibujar es la última hay que cambiar el gráfico de hito.
//        if indexPath.row == ocurrencias.count - 1 {
//            cell.imgHito.image = UIImage(named: "hitoFinal")
//        }
        
        return cell
    }
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print(indexPath.row)
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
        
        let texto = "¡La última vez que \(lblNombreEvento.text!)!"
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
        return String(" ")
    }
  
  @objc func dismissKeyboard(){
    self.view.endEditing(true)
  }

}

extension HistorialVC: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    self.ocurrenciaModificada = false
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    guard self.ocurrenciaModificada else {
      return
    }
    let ocurrenciaModificada = ocurrencias[textView.tag]
    // grabar la modificación de la descripción en la ocurrencia modificada
    database.modificarOcurrencia(ocurrenciaModificada.idOcurrencia, ocurrenciaModificada.idEvento, descripcion: textView.text)
    // refrescar la tabla para que coja el nuevo valor?
  }
  
  func textViewDidChange(_ textView: UITextView) {
    self.ocurrenciaModificada = true
  }
  
  
}



