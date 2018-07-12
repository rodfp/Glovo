//
//  PermissionsManager.swift
//  Glovo
//
//  Created by Rodrigo Franco on 7/11/18.
//

import Foundation
import UIKit
import CoreLocation

extension Notification.Name {
  static let locationPermissionUpdated = Notification.Name("locationPermissionUpdated")
}

class PermissionsManager : NSObject{
  static let shared = PermissionsManager()
  var locationManager: CLLocationManager!
  var locationCompletion: ((Bool) -> Void)?
  var locationGranted : Bool?
  
  fileprivate override init() {
    super.init()
    let locationStatus = CLLocationManager.authorizationStatus()
    
    switch locationStatus {
      case .authorizedAlways, .authorizedWhenInUse: locationGranted = true
      case .denied, .restricted: locationGranted = false
      case .notDetermined: locationGranted = nil
    }
  }
  
  func requestLocationPermission() {
    if locationManager == nil { locationManager = CLLocationManager() }
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }
  
}

extension PermissionsManager: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse: locationGranted = true
    case .denied, .restricted: locationGranted = false
    case .notDetermined: locationGranted = nil
    }
    if locationCompletion != nil {
      locationCompletion!(locationGranted ?? false)
      locationCompletion = nil
    }
    NotificationCenter.default.post(name: .locationPermissionUpdated, object: nil)
  }
  
}
