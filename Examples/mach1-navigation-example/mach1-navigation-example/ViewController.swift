//
//  ViewController.swift
//

import UIKit

class ViewController: UIViewController {
    
    var encoder: Encoder! = Encoder()
    
    @IBAction func PlayButtonPressed(_ sender: Any) {
        print("Play pressed")
        
        encoder.activateAudioSession()
        encoder.playSpatialAudioCue(audioCue: "Take a right turn on Vestry Street")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        encoder.setupAudio()
    }

}

