//
//  GeoLocationViewController.swift
//  Geofence Area
//
//  Created by Scott.L on 21/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class GeoLocationViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var statusButton: UIButton!
    
    var geolocations: [GeoLocationModel] = []
    var locationManager = CLLocationManager()
    private let viewModel = GeoLocationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupCoreLocation()
    }
    
}

extension GeoLocationViewController {
    
    func configureView() {
        setupNavigationItem()
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.backgroundColor = UIColor.systemBlue
        statusButton.layer.cornerRadius = 20
        statusButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        statusButton.addTarget(self, action: #selector(checkStatus), for: .touchUpInside)
    }
    
    func setupNavigationItem() {
        navigationItem.title = "Geo Location"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(toAddGeo))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "location.circle.fill"), style: .plain, target: self, action: #selector(zoomToCurrentLocation))
    }
    
    func setupCoreLocation() {
        locationManager.delegate = self
        mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        locationManager = manager
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func add(_ geolocation: GeoLocationModel) {
        geolocations.append(geolocation)
        mapView.addAnnotation(geolocation)
        addRadiusOverlay(forGeolocation: geolocation)
        updateGeotificationsCount()
    }
    
    func updateGeotificationsCount() {
        title = "Geo Location: \(geolocations.count)"
        navigationItem.rightBarButtonItem?.isEnabled = (geolocations.count < 10)
    }
    
    func addRadiusOverlay(forGeolocation geolocation: GeoLocationModel) {
        mapView.addOverlay(MKCircle(center: geolocation.coordinate, radius: geolocation.radius))
    }
    
    func region(with geolocation: GeoLocationModel) -> CLCircularRegion {
        let region = CLCircularRegion(center: geolocation.coordinate, radius: geolocation.radius, identifier: geolocation.identifier)
        region.notifyOnExit = true
        region.notifyOnEntry = true
        return region
    }
    
    func startMonitoring(geolocation: GeoLocationModel) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
            Your geolocation is saved but will only be activated once you grant
            Geo permission to access the device location.
            """
            showAlert(withTitle:"Warning", message: message)
        }
        
        let fenceRegion = region(with: geolocation)
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    func stopMonitoring(geolocation: GeoLocationModel) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == geolocation.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
}

// MARK: -
// MARK: Event Function
@objc extension GeoLocationViewController {
    
    func toAddGeo() {
        let viewController = AddGeoLocationsViewController()
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func zoomToCurrentLocation() {
        mapView.zoomToUserLocation()
    }
    
    func checkStatus() {
        geolocations.forEach {
            let geofenceArea = GeoLocationModel(identifier: NSUUID().uuidString, coordinate: $0.coordinate, radius: $0.radius)
            
            let someOtherLocation: CLLocation = CLLocation(latitude: geofenceArea.coordinate.latitude,
                                                           longitude: geofenceArea.coordinate.longitude)
            
            guard let usersCurrentLocation: CLLocation = locationManager.location else { return }
            let distanceInMeters: CLLocationDistance = usersCurrentLocation.distance(from: someOtherLocation)
            
            if distanceInMeters < geofenceArea.radius {
                statusButton.setTitle(viewModel.handleEvent(status: .inside), for: .normal)
                
            } else {
                statusButton.setTitle(viewModel.handleEvent(status: .outside), for: .normal)
            }
        }
    }
    
}


// MARK: -
// MARK: AddGeoViewControllerDelegate
extension GeoLocationViewController: AddGeoLocationViewControllerDelegate {
    
    func addGeoViewController(_ controller: AddGeoLocationsViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String) {
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geolocation = GeoLocationModel(identifier: identifier, coordinate: coordinate, radius: clampedRadius)
        add(geolocation)
        startMonitoring(geolocation: geolocation)
    }
    
}

// MARK: -
// MARK: - Location Manager Delegate
extension GeoLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .authorizedAlways
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        statusButton.setTitle(viewModel.handleEvent(status: .inside), for: .normal)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        let network = NetworkMonitor.shared
        network.startMonitoring()
        
        if !network.isOn {
            statusButton.setTitle(viewModel.handleEvent(status: .outside), for: .normal)
        }
        network.stopMonitoring()
    }
    
}

extension GeoLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
}
