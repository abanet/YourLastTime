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
    
    private var intervaloHoras: Int = 0
    private var factorTemporal: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Colores de los elementos de la interfaz
        stepper.tintColor = YourLastTime.colorFondoCelda
        selectorTemporal.tintColor = YourLastTime.colorFondoCelda
        btnSetAlarm.tintColor = YourLastTime.colorFondoCelda
        btnCancelar.tintColor = YourLastTime.colorFondoCelda
        btnBorrarAlarma.tintColor = YourLastTime.colorFondoCelda
        
        btnSetAlarm.titleLabel!.text = NSLocalizedString("Set Alarm",comment: "")
        btnCancelar.titleLabel!.text = NSLocalizedString("Cancel",comment: "")
        btnBorrarAlarma.titleLabel!.text = NSLocalizedString("Delete Alarm",comment: "")
        fraseDescriptiva.text = NSLocalizedString("The event doesn't happened!",comment: "")
        selectorTemporal.removeAllSegments()
        selectorTemporal.insertSegmentWithTitle(NSLocalizedString("years",comment: ""), atIndex: 0, animated: false)
        selectorTemporal.insertSegmentWithTitle(NSLocalizedString("months",comment: ""), atIndex: 1, animated: false)
        selectorTemporal.insertSegmentWithTitle(NSLocalizedString("days",comment: ""), atIndex: 2, animated: false)
        selectorTemporal.insertSegmentWithTitle(NSLocalizedString("hours",comment: ""), atIndex: 3, animated: false)
        selectorTemporal.selectedSegmentIndex = 2
        factorTemporal = 24 // se corresponde con dias segmentIndex = 1
        
        // Animación de la alarma
        var timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("agitar"), userInfo: nil, repeats: true)
    }

    override func viewWillAppear(animated: Bool) {
        intervaloHoras = Int(stepper.value) * factorTemporal
        
        // Si existe una alarma ya creada para el evento en curso hay que actualizar la pantalla.
        let bbdd = EventosDB()
        let evento = bbdd.encontrarEvento(self.idEvento)!
        if bbdd.tieneAlarma(evento){
            // Recuperamos los datos de 
            stepper.value = Double(evento.cantidad)
            lblNumero.text = String(format:"%03d", Int(stepper.value))
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
    

    @IBAction func setAlarm(sender: AnyObject) {
        let bbdd = EventosDB()
        let elPeriodo = PeriodoTemporal(rawValue: selectorTemporal.selectedSegmentIndex + 1)
        bbdd.establecerAlarma(self.idEvento, cantidad: Int(stepper.value), periodo: elPeriodo)
        performSegueWithIdentifier("cerrarAlarma", sender: nil)
        
        // programamos una notificación local
        // TODO: si funciona esto no habría que almacenar las horas en la bbdd ya que al saltar la alarma vamos a quitarla del sistema...
        let evento: Evento = bbdd.encontrarEvento(self.idEvento)!
        
        var informacionEvento = [String:String]()
        informacionEvento["id"] = evento.id
        informacionEvento["descripcion"] = evento.descripcion
        informacionEvento["fecha"] = evento.fecha
        informacionEvento["hora"] = evento.hora
        
        let notificacionLocal = Notificacion(id: evento.id, info: informacionEvento)
        notificacionLocal.addLocalNotification(intervaloHoras)
        // Una vez registrada la notificación local borramos la alarma
        
    }
   
    @IBAction func borrarAlarma(sender: AnyObject) {
        let bbdd = EventosDB()
        bbdd.establecerAlarma(self.idEvento, cantidad: 0, periodo: PeriodoTemporal.dias)
        performSegueWithIdentifier("cerrarAlarma", sender: nil)
        
        // Hay que borrar la notificación de esta alarma
        let notificacionLocal = Notificacion(id:self.idEvento)
        notificacionLocal.cancelLocalNotification()
    }
    
    @IBAction func cancelarAlarma(sender: AnyObject) {
        performSegueWithIdentifier("cerrarAlarma", sender: nil)

    }
    
    
    @IBAction func stepperPulsado(sender: AnyObject) {
        // Intervalo posible: 1-365
        let step = sender as! UIStepper
        lblNumero.text = String(format:"%03d", Int(step.value))
        self.actualizarIntervaloHoras()
    }

    @IBAction func definirIntervaloTiempo(sender: AnyObject) {
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
    }
    
    func actualizarIntervaloHoras(){
        self.intervaloHoras = Int(stepper.value) * factorTemporal
        println("Valor del stepper: \(stepper.value); factorTemporal: \(factorTemporal)")
    }
    
    func agitar() {
        despertador.animation = "swing"
        despertador.force = 5.0
        despertador.duration = 0.5
        despertador.animate()
    }
}
