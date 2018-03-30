//
//  NearByPlacesModule.swift
//  MapDemobeauty_salon



//
//  Created by Tejaswini on 26/03/18.
//  Copyright © 2018 Tejaswini. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import GoogleMaps
import GooglePlacePicker

class NearByPlacesModule: UIViewController,GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        print("Picked")
        let coordinates = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        let marker = GMSMarker(position: coordinates)
        marker.title = place.name
//        marker.map = self.googleMapView
//        self.googleMapView.animateToLocation(coordinates)
    }
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var tableView: UITableView!
    var category : String = ""
    var locations = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    var placesArray : [[String : Any]] = []
    var addressArray : [String] = []
    var locationArray : [[String : Any]] = []
    let typeArray : [String] = ["Accounting","Airport","Amusement Park","Aquarium","Art Gallery","ATM","Bakery","Bank","Bar","Bus Station","Cafe","Car Dealer","Car Rental","Car Repair","Car Wash","Church","Clothing Store","Dentist","Doctor","Electrician","Electronics Store","Fire Station","Furniture Store","Gas Station","Gym","Hair Care","Hardware Store","Hindu Temple","Home Goods Store","Hospital","Insurance Agency","Jewelry Store","Laundry","Lawyer","Library","Local Government Office","Lodging","Meal Delivery","Meal Takeaway","Movie Rental","Movie Theater","Museum","Night Club","Painter","Park","Parking","Pet Store","Pharmacy","Physiotherapist","Plumber","Police","Post Office","Real Estate Agency","Restaurant","Roofing Contractor","School","Shoe_ Store","Shopping Mall","Spa","Stadium","Storage","Store","Subway Station","Supermarket","Taxi Stand","Train Station","Travel Agency","Veterinary Care","Zoo"]
    
    let categoryArray : [String] = ["accounting","airport","amusement_park","aquarium","art_gallery","atm","bakery","bank","bar","bus_station","cafe","car_dealer","car_rental","car_repair","car_wash","church","clothing_store","dentist","doctor","electrician","electronics_store","fire_station","furniture_store","gas_station","gym","hair_care","hardware_store","hindu_temple","home_goods_store","hospital","insurance_agency","jewelry_store","laundry","lawyer","library","local_government_office","lodging","meal_delivery","meal_takeaway","movie_rental","movie_theater","museum","night_club","painter","park","parking","pet_store","pharmacy","physiotherapist","plumber","police","post_office","real_estate_agency","restaurant","roofing_contractor","school","shoe_store","shopping_mall","spa","stadium","storage","store","subway_station","supermarket","taxi_stand","train_station","travel_agency","veterinary_care","zoo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        // Do any additional setup after loading the view.
    }
//    func nearByPlacesAPI(){
//        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=22.5849923,88.4016579&radius=4000&types=bar&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
//        Alamofire.request(url).responseJSON { (response) in
//            //print("Response",response)
//            if let responseDict : [String:AnyObject] = response.result.value as? [String:AnyObject]{
//                if responseDict["status"] as? String == "OK"{
//                    self.placesArray = responseDict["results"] as! [[String : Any]]
//                    print("PlacesArray",self.placesArray)
//                    for places in self.placesArray{
//                        let add = places["vicinity"] as! String
//                        self.addressArray.append(add)
//                        print("AddressArray",self.addressArray)
//                        let gemotry = places["geometry"] as! [String : Any]
//                        print("Gemotry",gemotry)
//                        let location = gemotry["location"] as! [String : Any]
//                        let lat = location["lat"] as! Double
//                        let lng = location["lng"] as! Double
//                        self.locationArray.append(location)
//                        print("LocationsArray",self.locationArray)
//                        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 8.0)
//                        self.mapView.camera = camera
//                        self.showMarker(location: self.locationArray)
//                    }
//                }
//            }
//        }
//    }

    
    func nearByPlacesAPI(){
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(String(describing: locations.latitude)),\(String(describing: locations.longitude))&radius=1000&types=\(category)&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
        Alamofire.request(url).responseJSON { (response) in
            //print("Response",response)
            if let responseDict : [String:AnyObject] = response.result.value as? [String:AnyObject]{
                if responseDict["status"] as? String == "OK"{
                    self.placesArray = responseDict["results"] as! [[String : Any]]
                    print("PlacesArray",self.placesArray)
                    for places in self.placesArray{
                        let add = places["vicinity"] as! String
                        self.addressArray.append(add)
                        print("AddressArray",self.addressArray)
                        let gemotry = places["geometry"] as! [String : Any]
                        print("Gemotry",gemotry)
                        let location = gemotry["location"] as! [String : Any]
                        let viewPort = gemotry["viewport"] as! [String : Any]
                        let northeast = viewPort["northeast"] as! [String : Any]
                        let southwest = viewPort["southwest"] as! [String : Any]
                        self.locationArray.append(location)
                        print("LocationsArray",self.locationArray)
                        //let center = CLLocationCoordinate2D(latitude: self.locations.latitude, longitude: self.locations.longitude)
                        let northEast = CLLocationCoordinate2D(latitude: northeast["lat"] as! CLLocationDegrees, longitude: northeast["lng"] as! CLLocationDegrees)
                        let southWest = CLLocationCoordinate2D(latitude: southwest["lat"] as! CLLocationDegrees, longitude: southwest["lng"] as! CLLocationDegrees)
                        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                        let config = GMSPlacePickerConfig(viewport: viewport)
                        //let placePicker = GMSPlacePicker(config: config)
                        let placePicker:GMSPlacePickerViewController = GMSPlacePickerViewController(config: config)
                    
                        placePicker.delegate = self
                    
                        self.present(placePicker, animated: true, completion: nil)
//                        placePicker.pickPlace(callback: {(place, error) -> Void in
//                            if let error = error {
//                                print("Pick Place error: \(error.localizedDescription)")
//                                return
//                            }
//                        })
                        //                        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 8.0)
                        //                         self.mapView.camera = camera
                        //                        self.showMarker(location: self.locationArray)
                    }
                }
            }
        }
    }
}
extension NearByPlacesModule : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearByPlacesCell", for: indexPath) as! NearByPlacesCell
        cell.locationLabel.text = typeArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByPlacesDetail") as! NearByPlacesDetail
        category = categoryArray[indexPath.row]
        //self.nearByPlacesAPI()
        
        let center = CLLocationCoordinate2D(latitude: self.locations.latitude, longitude: self.locations.longitude)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        //let placePicker = GMSPlacePicker(config: config)
        let placePicker:GMSPlacePickerViewController = GMSPlacePickerViewController(config: config)
        
        placePicker.delegate = self
        self.present(placePicker, animated: true, completion: nil)
        
//        vc.locations = self.locations
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
extension NearByPlacesModule : CLLocationManagerDelegate{
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location : CLLocationCoordinate2D = (manager.location?.coordinate) {
            self.locations = location
            print("Locations",self.locations)
        }
    }
}
