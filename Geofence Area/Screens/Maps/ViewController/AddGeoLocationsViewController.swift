//
//  AddGeoLocationsViewController.swift
//  Geofence Area
//
//  Created by Scott.L on 21/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import UIKit
import MapKit

protocol AddGeoLocationViewControllerDelegate {
    func addGeoViewController(_ controller: AddGeoLocationsViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String)
}


class AddGeoLocationsViewController: UIViewController {
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var radiusTextField: UITextField!
    @IBOutlet private weak var addButton: UIButton!
    
    var delegate: AddGeoLocationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

}

extension AddGeoLocationsViewController {
    
    func configureView() {
        setupNavigationItem()
        addButton.addTarget(self, action: #selector(addNew), for: .touchUpInside)
        mapView.showsUserLocation = true
        
    }
    
    func setupNavigationItem() {
         navigationItem.title = "Add Geo Location"
               navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "location.circle.fill"), style: .plain, target: self, action: #selector(zoomToCurrentLocation))
    }
}

// MARK: -
// MARK: Event Function
@objc extension AddGeoLocationsViewController {
    
    func addNew() {
        mapView.zoomToUserLocation()
        
        let identifier = NSUUID().uuidString
        let coordinate = mapView.centerCoordinate
        let radius = Double(radiusTextField.text!) ?? 0
        
        delegate?.addGeoViewController(self, didAddCoordinate: coordinate, radius: radius, identifier: identifier
        )
    }
    
    func zoomToCurrentLocation() {
        mapView.zoomToUserLocation()
    }
    

}




