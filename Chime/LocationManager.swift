//
//  LocationManager.swift
//  ImageUploader
//
//  Created by Root on 03/08/14.
//
//

import Foundation
import UIKit
import CoreLocation

protocol userLocationProtocol {
    func didReceiveUserLocation(location: CLLocation)
}

let GlobalVariableSharedInstance = LocationManager()


class LocationManager: NSObject,  CLLocationManagerDelegate
{
    

    var delegate: userLocationProtocol?
    var coreLocationManager = CLLocationManager()

    

    /*
    if CLLocationManager.locationServicesEnabled() {
          coreLocationManager.startUpdatingLocation()
    }
*/

    
    class var SharedLocationManager: LocationManager
    {
        GlobalVariableSharedInstance.coreLocationManager.requestAlwaysAuthorization()
        
      
        return GlobalVariableSharedInstance
        
    }
    
    
    
    func initLocationManager()
    {
        if (CLLocationManager.locationServicesEnabled())
        {
            coreLocationManager.delegate = self
            coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
            coreLocationManager.startUpdatingLocation()
            coreLocationManager.startMonitoringSignificantLocationChanges()
//            coreLocationManager.st
        }
        else
        {
            var alert:UIAlertView = UIAlertView(title: "Error", message: "Location Services not Enabled. Please enable Location Services in your phone settings.", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        println("Location updated...")
        
        if (locations.count > 0)
        {
            // the last location is the good one?
            var newLocation:CLLocation = locations[0] as! CLLocation
            coreLocationManager.stopUpdatingLocation()
            delegate?.didReceiveUserLocation(newLocation)
            
        } else {
         
            var newLocation = CLLocation(latitude: 51.368123, longitude: -0.021973)

            delegate?.didReceiveUserLocation(newLocation)
            
        }
        
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if (status == CLAuthorizationStatus.AuthorizedAlways)
        {
            println("Location manager is authorized...")
        }
        else if(status == CLAuthorizationStatus.Denied)
        {
            coreLocationManager.stopUpdatingLocation()
            coreLocationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    

    func currentLocation() -> CLLocation {
        var location:CLLocation? = coreLocationManager.location
        
        
        if (location==nil) {
            println("Location is nil!")
            location = CLLocation(latitude: 51.368123, longitude: -0.021973)
        }
        /*        if (("iPhone Simulator" == UIDevice.currentDevice().model) || ("iPad Simulator" == UIDevice.currentDevice().model))
        {//51.368123,-0.021973, 41.8059,  123.4323
        location = CLLocation(latitude: 51.368123, longitude: -0.021973)
        }
        */

        return location!
    }
    
    func findLocation() {
        
//        println(coreLocationManager)
        coreLocationManager.startUpdatingLocation()
        
    }
    
    // 1.take the geopoint transform to ClLocation using the latitude and longitude of the geopoint 2. take our current location 3. calculate distance from location using the distanfeFromLocation function
    
    
    // streetname, whole city name, state abbrevuatuib
    func findDistance(location:PFGeoPoint!) -> NSNumber
    {
        var distance:CLLocationDistance = -1
        if ((location) != nil)
        {
            
            // the location we want to go to
            var locationFromGeoPoint:CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let current_location:CLLocation? = GlobalVariableSharedInstance.currentLocation()
            distance = abs(locationFromGeoPoint.distanceFromLocation(current_location))
//            println("DISTANCE \(distance)")
        }
        
        
        return NSNumber(double: distance)
    }
    
    func addressToLocationProtocol(addressString: String) {
        var geocoder = CLGeocoder()
        
        

        
        geocoder.geocodeAddressString(addressString, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            
            if (error == nil) {
                
            
                
                var placemark: CLPlacemark = placemarks.last as! CLPlacemark
                var location = placemark.location as CLLocation
                var locationLat = placemark.location.coordinate.latitude
                var locationLon = placemark.location.coordinate.longitude
                
                println("Location Found! lat: \(locationLat) long: \(locationLon)")
                var geoPoint = PFGeoPoint(latitude: locationLat, longitude: locationLon) as PFGeoPoint

            
            
                
                
            } else {
                
                println("Error while trying to find latitude and longtitude of address search")
                
                
            }
            
            
        })
        
        
    }
    
    
    func addressToLocation (addressString: String, completion: (geoPoint: PFGeoPoint?) -> Void) {
        var geocoder = CLGeocoder()
        
        var geoPoint: PFGeoPoint?
        
        // this is not in the main thread, so if return value for geopoint, geopoint will be nil bfefore it gets set in that method (this is why we should use completion block)
        geocoder.geocodeAddressString(addressString,  completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            
            if (error == nil) {
                
                
                
                var placemark: CLPlacemark = placemarks.last as! CLPlacemark
                var location = placemark.location as CLLocation
                var locationLat = placemark.location.coordinate.latitude
                var locationLon = placemark.location.coordinate.longitude
                
                println("Location Found! lat: \(locationLat) long: \(locationLon)")
                geoPoint = PFGeoPoint(latitude: locationLat, longitude: locationLon) as PFGeoPoint

                completion(geoPoint: geoPoint)
                
                
            } else {
                
                println("Error while trying to find latitude and longtitude of address search...")
                
                
            }
            
            
        })
        
    }
    
}

