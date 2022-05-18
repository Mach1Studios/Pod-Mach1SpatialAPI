//
//  SplashDeviceViewController.swift
//
//  Created by Dylan Marcus on 11/17/21.
//

import UIKit

@available(iOS 14.0, *)
class DeviceSelectionViewController: UIViewController {

    private var activityIndicator: ActivityIndicator?

    @IBAction func useCoreMotionDeviceTapped(_ sender: Any) {
        // Instead of using a session for a remote device, create a session for a
        // simulated device.
        bUseCustomOrientationInput = false
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            fatalError("Cannot instantiate view controller")
        }

        //vc.session = session
        show(vc, sender: self)
    }
    
    @IBAction func viewStoreView(_ sender: Any) {
        // View store page
    }

}
