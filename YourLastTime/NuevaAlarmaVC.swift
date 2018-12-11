//
//  NuevaAlarmaVC.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 8/7/15.
//  Copyright (c) 2015 abanet. All rights reserved.
//

import UIKit

class NuevaAlarmaVC: UIViewController {
    var idEvento: String!
    @IBOutlet weak var lblNumero: UILabel!
    @IBOutlet weak var selectorTemporal: UISegmentedControl!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var btnSetAlarm: UIButton!
    @IBOutlet weak var despertador: SpringImageView!
    @IBOutlet weak var btnCancelar: UIButton!
    @IBOutlet weak var fraseDescriptiva: UILabel!
    @IBOutlet weak var btnBorrarAlarma: UIButton!
    
    fileprivate var intervaloHoras: Int = 0
    fileprivate var factorTemporal: Int = 0
    
    private lazy var notificacionLocal:Notificacion = Notificacion(id: self.idEvento)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Colores de los elementos de la interfaz
        stepper.tintColor = YourLastTime.colorFondoCelda
        selectorTemporal.tintColor = YourLastTime.colorFondoCelda
        btnSetAlarm.tintColor = YourLastTime.colorFondoCelda
        btnCancelar.tintColor = YourLastTime.colorFondoCelda
        btnBorrarAlarma.tintColor = YourLastTime.colorFondoCelda
        
        btnSetAlarm.setTitle(NSLocalizedString("Set Alarm",comment: ""), for: .normal)
        btnCancelar.setTitle(NSLocalizedString("Cancel",comment: ""), for: .normal)
        btnBorrarAlarma.setTitle(NSLocalizedString("Delete Alarm",comment: ""), for: .normal)
        
        
        selectorTemporal.removeAllSegments()
        selectorTemporal.insertSegment(withTitle: NSLocalizedString("years",comment: ""), at: 0, animated: false)
        selectorTemporal.insertSegment(withTitle: NSLocalizedString("months",comment: ""), at: 1, animated: false)
        selectorTemporal.insertSegment(withTitle: NSLocalizedString("days",comment: ""), at: 2, animated: false)
        selectorTemporal.insertSegment(withTitle: NSLocalizedString("hours",comment: ""), at: 3, animated: false)
        selectorTemporal.selectedSegmentIndex = 2
        factorTemporal = 24 // se corresponde con dias segmentIndex = 1
        
        fraseDescriptiva.text = stringAviso(unidades: Int(stepper.value), indiceSegmento: selectorTemporal.selectedSegmentIndex)
        fraseDescriptiva.text = String.localizedStringWithFormat(NSLocalizedString("The event doesn't happened!",comment: ""), "8", "años")
        // Animación de la alarma
        _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(NuevaAlarmaVC.agitar), userInfo: nil, repeats: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        intervaloHoras = Int(stepper.value) * factorTemporal
        
        // Si existe una alarma ya creada para el evento en curso hay que actualizar la pantalla.
        let bbdd = EventosDB()
        let evento = bbdd.encontrarEvento(self.idEvento)!
        if bbdd.tieneAlarma(evento){
            // Recuperamos los datos de 
            stepper.value = Double(evento.cantidad)
            lblNumero.text = String(format:"%03d", Int(stepper.value))
            fraseDescriptiva.text = stringAviso(unidades: Int(stepper.value), indiceSegmento: selectorTemporal.selectedSegmentIndex)
            switch evento.periodo {
            case .annos:
                selectorTemporal.selectedSegmentIndex = 0
                factorTemporal = 365 * 24
            case .meses:
                selectorTemporal.selectedSegmentIndex = 1
                factorTemporal = 30 * 24
            case .dias:
                selectorTemporal.selectedSegmentIndex = 2
                factorTemporal = 24
            case .horas:
                selectorTemporal.selectedSegmentIndex = 3
                factorTemporal = 1
            }
            self.actualizarIntervaloHoras()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func setAlarm(_ sender: AnyObject) {
        let bbdd = EventosDB()
        let elPeriodo = PeriodoTemporal(rawValue: selectorTemporal.selectedSegmentIndex + 1)
        bbdd.establecerAlarma(self.idEvento, cantidad: Int(stepper.value), periodo: elPeriodo)
        performSegue(withIdentifier: "cerrarAlarma", sender: nil)
        
        // programamos una notificación local
        guard let evento: Evento = bbdd.encontrarEvento(self.idEvento),
        let intervaloAlarma = evento.intervaloParaProgramarAlarma() else { return }
        
        var informacionEvento = [String:String]()
        informacionEvento["id"] = evento.id
        informacionEvento["descripcion"] = evento.descripcion
        informacionEvento["fecha"] = evento.fecha
        informacionEvento["hora"] = evento.hora
        
        // Calcular cuando hay que poner alarma: x tiempo desde la última vez.
        notificacionLocal = Notificacion(id: evento.id, info: informacionEvento)
        notificacionLocal.addLocalNotification(intervaloAlarma)
   
    }
   
    @IBAction func borrarAlarma(_ sender: AnyObject) {
        let bbdd = EventosDB()
        bbdd.eliminarAlarma(self.idEvento)
        performSegue(withIdentifier: "cerrarAlarma", sender: nil)
        
        // Hay que borrar la notificación de esta alarma
        notificacionLocal.cancelLocalNotification()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadEventsTable"), object: nil)
    }
    
    @IBAction func cancelarAlarma(_ sender: AnyObject) {
        performSegue(withIdentifier: "cerrarAlarma", sender: nil)

    }
    
    
    @IBAction func stepperPulsado(_ sender: AnyObject) {
        // Intervalo posible: 1-365
        let step = sender as! UIStepper
        lblNumero.text = String(format:"%03d", Int(step.value))
        fraseDescriptiva.text = stringAviso(unidades: Int(step.value), indiceSegmento: selectorTemporal.selectedSegmentIndex)
        //fraseDescriptiva.setNeedsDisplay()
        self.actualizarIntervaloHoras()
    }

    @IBAction func definirIntervaloTiempo(_ sender: AnyObject) {
        let segmento = sender as! UISegmentedControl
        
        switch (segmento.selectedSegmentIndex) {
        case 0: // años
            factorTemporal = 365 * 24 // horas en un año
            self.actualizarIntervaloHoras()
        case 1: // meses
            factorTemporal = 30 * 24
            self.actualizarIntervaloHoras()
        case 2: // días
            factorTemporal = 24
            self.actualizarIntervaloHoras()
        case 3: // horas
            factorTemporal = 1
            self.actualizarIntervaloHoras()
        default:
            factorTemporal = 1
            self.actualizarIntervaloHoras()
        }
        fraseDescriptiva.text = stringAviso(unidades: Int(stepper.value), indiceSegmento: selectorTemporal.selectedSegmentIndex)
    }
    
    func actualizarIntervaloHoras(){
        self.intervaloHoras = Int(stepper.value) * factorTemporal
        print("Valor del stepper: \(stepper.value); factorTemporal: \(factorTemporal)")
    }
    
    @objc func agitar() {
        despertador.animation = "swing"
        despertador.force = 5.0
        despertador.duration = 0.5
        despertador.animate()
    }
    
    
    /**
    * Dado un número de unidades y un valor de segmento devuelve el string con la frase a mostrar.
     * Valor por defecto: 1 día
    */
    func stringAviso(unidades: Int?, indiceSegmento: Int?) -> String {
        let cantidad = unidades ?? 1    // por defecto 1
        let indice   = indiceSegmento ?? 2 // por defecto días
        return String.localizedStringWithFormat(NSLocalizedString("The event doesn't happened!",comment: ""), String(cantidad), literalSelectedSegment(indice: indice,cantidad: cantidad))
    }
    /**
    * Devuelve el literal correspondiente a la selección del UISegmentedControl (indice) según la cantidad de unidades
    */
    func literalSelectedSegment(indice: Int, cantidad: Int) -> String {
        
        switch indice {
        case 0: /*años*/
            return cantidad > 1 ? NSLocalizedString("years", comment: "") : NSLocalizedString("year", comment: "")
        case 1: /*meses*/
            return cantidad > 1 ? NSLocalizedString("months", comment: "") : NSLocalizedString("month", comment: "")
        case 2: /*días*/
            return cantidad > 1 ? NSLocalizedString("days", comment: "") : NSLocalizedString("day", comment: "")
        case 3: /*horas*/
            return cantidad > 1 ? NSLocalizedString("hours", comment: "") : NSLocalizedString("hour", comment: "")
        default:
            return ""
        }
        
    }
}
