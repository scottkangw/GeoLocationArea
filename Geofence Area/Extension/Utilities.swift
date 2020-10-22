//
//  Utilities.swift
//  Geofence Area
//
//  Created by Scott.L on 21/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation
import MapKit
import Network

extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

enum RegionStatus: String {
    case inside = "inside"
    case outside = "outside"
}

