import Foundation
import UIKit

class ProximityController {
    init() {}

    func enable() {
        DispatchQueue.main.async {
            let device = UIDevice.current
            device.isProximityMonitoringEnabled = true
        }
    }

    func disable() {
        DispatchQueue.main.async {
            let device = UIDevice.current
            device.isProximityMonitoringEnabled = false
        }
    }
}

