//
//  ViewController.swift
//  TTS_avplayer_test
//
//  Created by Alexey Popov on 19.03.2021.
//

import UIKit

class ViewController: UIViewController {
    
    var playerArray: PlayerArray! = PlayerArray()
    
    @IBAction func PlayButtonPressed(_ sender: Any) {
        print("Play pressed")
        
        playerArray.activateAudioSession()
        playerArray.playSpatialAudioCue(audioCue: "Trying to play that")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        playerArray.setupAudio(globalGain: 1.0)
    }


}

