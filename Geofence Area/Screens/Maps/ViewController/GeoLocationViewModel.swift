//
//  GeoLocationViewModel.swift
//  Geofence Area
//
//  Created by Scott.L on 28/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        setRegion(region, animated: true)
    }
    
}


class GeoLocationViewModel {
    
    func handleEvent(status: RegionStatus) -> String {
        return status.rawValue
    }
    
}
