//
//  GeoLocationModel.swift
//  Geofence Area
//
//  Created by Scott.L on 21/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class GeoLocationModel: NSObject, MKAnnotation {
    var identifier: String
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    
    init(identifier: String, coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
    }
}
