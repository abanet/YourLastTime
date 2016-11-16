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
    @IBOutlet weak var btnCerrar: SpringButton!
    @IBOutlet var btnShare: UIButton!
    
    
    var idEvento: String!
    var database: EventosDB!
    var ocurrencias: [Ocurrencia] = [Ocurrencia]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        database = EventosDB()
        
        lblNombreEvento.text = database.encontrarEvento(idEvento)!.descripcion
        
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
        
        // Total de ocurrencias
        lblTotal.text = String(ocurrencias.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Ocultamos la barra de estatus
    override var prefersStatusBarHidden : Bool {
        return true;
    }

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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    
    func agitar() {
        btnCerrar.animation = "swing"
        btnCerrar.force = 5.0
        btnCerrar.duration = 0.5
        btnCerrar.animate()
    }
    
    // MARK: Función Compartir
    @IBAction func shareHistorial(_ sender: UIButton) {
        btnShare.alpha = 0
        
        let texto = "¡La última vez que \(lblNombreEvento.text!)!"
        let imagen: UIImage = screenShot()
        let activityViewController = UIActivityViewController(activityItems: [texto, imagen], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.assignToContact,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToTencentWeibo]
        present(activityViewController, animated: true, completion: nil)
            }
    
    
    
    // MARK: Capturar pantalla
    func screenShot() -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height))
        UIGraphicsGetCurrentContext()!
        self.view?.drawHierarchy(in: self.view.frame, afterScreenUpdates: false)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return screenShot!
    }

}
