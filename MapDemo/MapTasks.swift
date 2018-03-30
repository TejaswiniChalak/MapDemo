//
//  MapTasks.swift
//  MapDemo
//
//  Created by Tejaswini on 20/03/18.
//  Copyright © 2018 Tejaswini. All rights reserved.
//

import UIKit

class MapTasks: NSObject {
   
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    var lookupAddressResults: [NSObject : AnyObject] = [:]
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    func geocodeAddress(address:String!,withCompletionHandler completionHandler:((_ status:String,_ success:Bool)->Void)){
        if let lookUpAddress = address{
            let geoCodeUrlString = baseURLGeocode + "address=" + lookUpAddress
            let geoUrl = URL(string: geoCodeUrlString)
        }
    }
}
