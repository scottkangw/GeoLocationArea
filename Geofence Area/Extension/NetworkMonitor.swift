//
//  NetworkMonitor.swift
//  Geofence Area
//
//  Created by Scott.L on 21/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation
import Network

class NetworkMonitor {
    static public let shared = NetworkMonitor()
    private var monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    private var queue = DispatchQueue.global()
    var isOn: Bool = false
    
    private init() {
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue.global(qos: .background)
        self.monitor.start(queue: queue)
    }
    
    func startMonitoring() {
        self.monitor.pathUpdateHandler = { path in
            self.isOn = path.status == .satisfied
        }
    }
    
    func stopMonitoring() {
        self.monitor.cancel()
    }
}
