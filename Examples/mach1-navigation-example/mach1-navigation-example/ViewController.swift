//
//  ViewController.swift
//

import UIKit

class ViewController: UIViewController {
    
    var Encoder: Encoder! = Encoder()
    
    @IBAction func PlayButtonPressed(_ sender: Any) {
        print("Play pressed")
        
        Encoder.activateAudioSession()
        Encoder.playSpatialAudioCue(audioCue: "Trying to play that")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        playerArray.setupAudio(globalGain: 1.0)
    }

}

