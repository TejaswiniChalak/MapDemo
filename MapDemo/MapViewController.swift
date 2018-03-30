//
//  MapViewController.swift
//  MapDemo
//
//  Created by Tejaswini on 19/03/18.
//  Copyright © 2018 Tejaswini. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire

class MapViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var customAddress: UIBarButtonItem!
    @IBOutlet var setEndStartLocation: UIBarButtonItem!
    @IBOutlet var travelMode: UIBarButtonItem!
    @IBOutlet var mapType: UIBarButtonItem!
    
    @IBOutlet var hideShowButton: UIButton!
    @IBOutlet var customAdressButton: UIBarButtonItem!
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
//    let origin = "\(37.778483),\(-122.513960)"
//    let destination = "\(37.706753),\(-122.418677)"
    @IBOutlet var mapTypeButton: UIBarButtonItem!
    @IBOutlet var locationButton: UIBarButtonItem!
    @IBOutlet var travelModeButton: UIBarButtonItem!
    var selectedRoute : [[String : Any]] = []
    var wayPoints : [[String : Any]] = []
    var origin : String = ""
    var destination : String = ""
    var overviewPolyline : [String : Any] = [:]
    var points : String = ""
    var routePolyline: GMSPolyline!
    var legsArray : [[String:Any]] = []
    var startLoc = CLLocationCoordinate2D()
    var endLoc = CLLocationCoordinate2D()
    var startAddress : String = ""
    var endAddress : String = ""
    var markersArray : [GMSMarker] = []
    var wayPointsArray : [String] = []
    enum TravelModes: Int {
        case driving
        case walking
        case bicycling
        case transit
    }
    var modeOfTravel = TravelModes.driving
    let icon_Address : String = "\u{e9b3}"
    let icon_TravelMode : String = "\u{e949}"
    let icon_MapType : String = "\u{e94b}"
    let icon_Location : String = "\u{e947}"
    var showPicker : Bool = false
    let pickerView = UIPickerView()
    var locations = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
        hideShowButton.setTitle("Show List", for: .normal)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.frame = CGRect(x: 0, y: self.view.bounds.size.height/2, width: self.view.bounds.size.width, height: 200)
        
        let camera = GMSCameraPosition.camera(withLatitude:locations.latitude, longitude: locations.longitude, zoom: 8.0)
        mapView.camera = camera
          mapView.delegate = self
        showCurrentLocation(locations: locations)
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
//        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCC-46d5GIucbPNvDYonSfKaCGnN9aPbOc"
//        Alamofire.request(url).responseJSON { (response) in
//            print("Response",response)
//        }
        customAddress.title = icon_Address
        customAddress.setTitleTextAttributes([NSAttributedStringKey.font:UIFont.init(name: "icomoon", size: 24)!,NSAttributedStringKey.backgroundColor:UIColor.black,NSAttributedStringKey.foregroundColor:UIColor.black], for: .normal)
        
        locationButton.title = icon_Location
        locationButton.setTitleTextAttributes([NSAttributedStringKey.font:UIFont.init(name: "icomoon", size: 24)!,NSAttributedStringKey.backgroundColor:UIColor.black,NSAttributedStringKey.foregroundColor:UIColor.black], for: .normal)
        
        mapType.title = icon_MapType
        mapType.setTitleTextAttributes([NSAttributedStringKey.font:UIFont.init(name: "icomoon", size: 24)!,NSAttributedStringKey.backgroundColor:UIColor.black,NSAttributedStringKey.foregroundColor:UIColor.black], for: .normal)
        
        travelMode.title = icon_TravelMode
        travelMode.setTitleTextAttributes([NSAttributedStringKey.font:UIFont.init(name: "icomoon", size: 24)!,NSAttributedStringKey.backgroundColor:UIColor.black,NSAttributedStringKey.foregroundColor:UIColor.black], for: .normal)
        
    }
    func showCurrentLocation(locations:CLLocationCoordinate2D){
        let originMarker = GMSMarker()
        //originMarker.title = startAdd
        originMarker.position = locations
        originMarker.snippet = "US us us us us us"
        originMarker.map = mapView
    }
    func showMarker(origin : CLLocationCoordinate2D , destination : CLLocationCoordinate2D,startAdd:String,endAdd:String){
        let originMarker = GMSMarker()
        originMarker.title = startAdd
        originMarker.position = origin
        originMarker.snippet = "US us us us us us"
        originMarker.map = mapView
     
        let destinationMarker = GMSMarker(position: destination)
        destinationMarker.title = endAdd
        destinationMarker.snippet = "US us us us us us"
        destinationMarker.map = mapView
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeMapTypeClickedAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Map Type", message: "Select Map Type", preferredStyle: .actionSheet)
        let normalMapType = UIAlertAction(title: "Normal", style: .default) { (action) in
            self.mapView.mapType = .normal
        }
        let terrainMapType = UIAlertAction(title: "Terrain", style: .default) { (action) in
            self.mapView.mapType = .terrain
        }
        let hybridMapType = UIAlertAction(title: "Hybrid", style: .default) { (action) in
            self.mapView.mapType = .hybrid
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(normalMapType)
        actionSheet.addAction(terrainMapType)
        actionSheet.addAction(hybridMapType)
        actionSheet.addAction(cancel)
        if let presenter = actionSheet.popoverPresentationController{
            presenter.sourceView = self.view
            presenter.sourceRect = CGRect(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2, width: 0, height: 0)
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func customAddressActionClicked(_ sender: Any) {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.alert)
        
        addressAlert.addTextField { (textField) -> Void in
            textField.placeholder = "Origin?"
        }
        
        addressAlert.addTextField { (textField) -> Void in
            textField.placeholder = "Destination?"
        }
        
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.origin = (addressAlert.textFields![0] as UITextField).text!
            self.destination = (addressAlert.textFields![1] as UITextField).text!
            self.createDirectionAPI(origin: self.origin, destination: self.destination)
            
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        present(addressAlert, animated: true, completion: nil)
        
    }
    @IBAction func setLocationActionClicked(_ sender: Any) {
        let url  = "https://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Montreal&avoid=highways&mode=walking&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
        Alamofire.request(url).responseJSON { (response) in
            print("Response",response)
            let jsonData = response.data
            print("jsonData",jsonData!)
        }
    }
    @IBAction func travelModeActionClicked(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Travel Mode", message: "Select Travel Mode", preferredStyle: .actionSheet)
        let walking = UIAlertAction(title: "walking", style: .default) { (action) in
            let url  = "https://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Montreal&avoid=highways&mode=walking&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
            //let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.origin)&destination=\(self.destination)&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
            self.modeOfTravel = TravelModes.walking
            self.getDirectionAPICall(url: url)
       
        }
        let bicycling = UIAlertAction(title: "bicycling", style: .default) { (action) in
            let url  = "https://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Montreal&avoid=highways&mode=bicycling&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
            self.modeOfTravel = TravelModes.bicycling
            self.getDirectionAPICall(url: url)
        }
        let driving = UIAlertAction(title: "driving", style: .default) { (action) in
            let url  = "https://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Montreal&avoid=highways&mode=driving&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
            self.modeOfTravel = TravelModes.driving
            self.getDirectionAPICall(url: url)
        }
        let transit = UIAlertAction(title: "transit", style: .default) { (action) in
            let url  = "https://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Montreal&avoid=highways&mode=transit&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
            self.modeOfTravel = TravelModes.transit
            self.getDirectionAPICall(url: url)

        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in

        }
        actionSheet.addAction(walking)
        actionSheet.addAction(bicycling)
        actionSheet.addAction(driving)
        actionSheet.addAction(transit)
        actionSheet.addAction(cancel)
        if let presenter = actionSheet.popoverPresentationController{
            presenter.sourceView = self.view
            presenter.sourceRect = CGRect(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2, width: 0, height: 0)
        }
        self.present(actionSheet, animated: true, completion: nil)
      
}
    func createDirectionAPI(origin:String,destination:String){
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
        Alamofire.request(url).responseJSON { (response) in
            print("Response",response)
            if let responseDict : [String:AnyObject] = response.result.value as? [String:AnyObject]{
                if responseDict["status"] as? String == "OK"{
                    self.wayPoints = responseDict["geocoded_waypoints"] as! [[String : Any]]
                    self.selectedRoute = responseDict["routes"] as! [[String : Any]]
                    print("selectedRoute",self.selectedRoute)
                    for route in self.selectedRoute{
                        let dict = route
                        print("Dict",dict)
                        self.legsArray = dict["legs"] as! [[String : Any]]
                        for leg in self.legsArray{
                            let startLocation = leg["start_location"] as! [String : Any]
                            self.startLoc = CLLocationCoordinate2DMake(startLocation["lat"] as! CLLocationDegrees, startLocation["lng"] as! CLLocationDegrees)
                            let endLocation = leg["end_location"] as! [String : Any]
                            self.endLoc = CLLocationCoordinate2DMake(endLocation["lat"] as! CLLocationDegrees, endLocation["lng"] as! CLLocationDegrees)
                            self.startAddress = leg["start_address"] as? String ?? ""
                            self.endAddress = leg["end_address"] as? String ?? ""
                           }
                        self.overviewPolyline = dict["overview_polyline"] as! [String:Any]
                        print("overview_polyline",self.overviewPolyline)
                        self.points = self.overviewPolyline["points"] as? String ?? ""
                        print("points",self.points)
                        let camera = GMSCameraPosition.camera(withTarget: self.startLoc, zoom: 8.0)
                        self.mapView.camera = camera
                        //mapView.delegate = self
                        self.showMarker(origin: self.startLoc, destination: self.endLoc, startAdd: self.startAddress, endAdd: self.endAddress)
                        self.getTimeAndDurationAPI(origin: self.startAddress, destination: self.endAddress)
                        let path = GMSPath(fromEncodedPath: self.points)
                        self.routePolyline = GMSPolyline(path: path)
                        self.routePolyline.map = self.mapView
                    }
                    
                }
            }
        }
    }
    
    func getDirectionAPICall(url:String){
        Alamofire.request(url).responseJSON { (response) in
            print("Response",response)
            if let responseDict : [String:AnyObject] = response.result.value as? [String:AnyObject]{
                if responseDict["status"] as? String == "OK"{
                    self.wayPoints = responseDict["geocoded_waypoints"] as! [[String : Any]]
                    self.selectedRoute = responseDict["routes"] as! [[String : Any]]
                    print("selectedRoute",self.selectedRoute)
                    for route in self.selectedRoute{
                        let dict = route
                        print("Dict",dict)
                        self.legsArray = dict["legs"] as! [[String : Any]]
                        for leg in self.legsArray{
                            let startLocation = leg["start_location"] as! [String : Any]
                            self.startLoc = CLLocationCoordinate2DMake(startLocation["lat"] as! CLLocationDegrees, startLocation["lng"] as! CLLocationDegrees)
                            let endLocation = leg["end_location"] as! [String : Any]
                            self.endLoc = CLLocationCoordinate2DMake(endLocation["lat"] as! CLLocationDegrees, endLocation["lng"] as! CLLocationDegrees)
                            self.startAddress = leg["start_address"] as? String ?? ""
                            self.endAddress = leg["end_address"] as? String ?? ""
                        }
                        self.overviewPolyline = dict["overview_polyline"] as! [String:Any]
                        print("overview_polyline",self.overviewPolyline)
                        self.points = self.overviewPolyline["points"] as? String ?? ""
                        print("points",self.points)
                        let camera = GMSCameraPosition.camera(withTarget: self.startLoc, zoom: 8.0)
                        self.mapView.camera = camera
                        //mapView.delegate = self
                        self.showMarker(origin: self.startLoc, destination: self.endLoc, startAdd: self.startAddress, endAdd: self.endAddress)
                        self.getTimeAndDurationAPI(origin: self.startAddress, destination: self.endAddress)
                        let path = GMSPath(fromEncodedPath: self.points)
                        self.routePolyline = GMSPolyline(path: path)
                        self.routePolyline.map = self.mapView
                    }
                    
                }
            }
        }
    }
    func recreateRoute(url:String){
        if let polyline = routePolyline{
            self.getDirectionAPICall(url: url)
        }
    }
    
    func getTimeAndDurationAPI(origin:String,destination:String){
        let url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(origin),DC&destinations=\(destination)&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
        Alamofire.request(url).responseJSON { (response) in
            print("Response",response)
            if let responseDict : [String:AnyObject] = response.result.value as? [String:AnyObject]{
                if responseDict["status"] as? String == "OK"{
                    
                }
            }
    }
}
    @IBAction func hideShowButtonClickedAction(_ sender: Any) {
        if showPicker == true{
            hideShowButton.setTitle("Hide List", for: .normal)
            pickerView.isHidden = false
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.frame = CGRect(x: 0, y: mapView.bounds.size.height/2 + 65, width: mapView.bounds.size.width, height: 150)
            pickerView.backgroundColor = .white
            mapView.addSubview(pickerView)
            showPicker = false
        }
        else{
            hideShowButton.setTitle("Show List", for: .normal)
            pickerView.isHidden = true
            showPicker = true
        }
 
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension MapViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse{
            mapView.isMyLocationEnabled = true
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location : CLLocationCoordinate2D = (manager.location?.coordinate) {
            self.locations = location
            print("Locations",self.locations)
        }
    }
}
extension MapViewController : GMSMapViewDelegate{
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 70))
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 6.0
//
//        let nameLabel = UILabel(frame: CGRect(x: 8, y: 8, width: view.frame.size.width - 16, height: 15))
//        nameLabel.text = "NAME LABEL"
//        view.addSubview(nameLabel)
//
//        let nameLabel1 = UILabel(frame: CGRect(x: nameLabel.frame.origin.x, y: nameLabel.frame.origin.y + nameLabel.frame.size.height + 3, width: view.frame.size.width - 16, height: 15))
//        nameLabel1.text = "HI"
//        view.addSubview(nameLabel1)
//
//        return view
//    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let polyline = routePolyline {
            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
            wayPointsArray.append(positionString)
            print("WayPointsArray",wayPointsArray)
            
        }
    }
}

extension MapViewController : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 30, height: 60))
        
        let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        var rowString : String = ""
        switch row {
        case 0:
            rowString = "Washington"
            //myImageView.image = UIImage(named:"washington.jpg")
            myImageView.backgroundColor = .red
        case 1:
            rowString = "beijing"
            //myImageView.image = UIImage(named:"beijing.jpg")
            myImageView.backgroundColor = .blue
        case 2:
            rowString = "beijing"
            //myImageView.image = UIImage(named:"beijing.jpg")
            myImageView.backgroundColor = .red
        case 3:
            rowString = "beijing"
            //myImageView.image = UIImage(named:"beijing.jpg")
            myImageView.backgroundColor = .blue
        case 4:
            rowString = "beijing"
            //myImageView.image = UIImage(named:"beijing.jpg")
            myImageView.backgroundColor = .red
        default:
            rowString = "Error: too many rows"
            myImageView.image = nil
        }
        let myLabel = UILabel(frame: CGRect(x: 60, y: 0, width: pickerView.bounds.width - 90, height: 60))
        
        //myLabel.font = UIFont(name:UIFont.systemFontSize, size: 18)
        myLabel.text = rowString
        
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // do something with selected row
    }
}



//AIzaSyAjFNYR2-FgClI-X3yTFYcki1-dmS-xvJM

//AIzaSyCC-46d5GIucbPNvDYonSfKaCGnN9aPbOc

//Response SUCCESS: {
//    results =     (
//        {
//            "address_components" =             (
//                {
//                    "long_name" = "Google Building 41";
//                    "short_name" = "Google Building 41";
//                    types =                     (
//                        premise
//                    );
//            },
//                {
//                    "long_name" = 1600;
//                    "short_name" = 1600;
//                    types =                     (
//                        "street_number"
//                    );
//            },
//                {
//                    "long_name" = "Amphitheatre Parkway";
//                    "short_name" = "Amphitheatre Pkwy";
//                    types =                     (
//                        route
//                    );
//            },
//                {
//                    "long_name" = "Mountain View";
//                    "short_name" = "Mountain View";
//                    types =                     (
//                        locality,
//                        political
//                    );
//            },
//                {
//                    "long_name" = "Santa Clara County";
//                    "short_name" = "Santa Clara County";
//                    types =                     (
//                        "administrative_area_level_2",
//                        political
//                    );
//            },
//                {
//                    "long_name" = California;
//                    "short_name" = CA;
//                    types =                     (
//                        "administrative_area_level_1",
//                        political
//                    );
//            },
//                {
//                    "long_name" = "United States";
//                    "short_name" = US;
//                    types =                     (
//                        country,
//                        political
//                    );
//            },
//                {
//                    "long_name" = 94043;
//                    "short_name" = 94043;
//                    types =                     (
//                        "postal_code"
//                    );
//            }
//            );
//            "formatted_address" = "Google Building 41, 1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA";
//            geometry =             {
//                bounds =                 {
//                    northeast =                     {
//                        lat = "37.4228775";
//                        lng = "-122.085133";
//                    };
//                    southwest =                     {
//                        lat = "37.4221145";
//                        lng = "-122.0860002";
//                    };
//                };
//                location =                 {
//                    lat = "37.4224082";
//                    lng = "-122.0856086";
//                };
//                "location_type" = ROOFTOP;
//                viewport =                 {
//                    northeast =                     {
//                        lat = "37.4238449802915";
//                        lng = "-122.0842176197085";
//                    };
//                    southwest =                     {
//                        lat = "37.4211470197085";
//                        lng = "-122.0869155802915";
//                    };
//                };
//            };
//            "place_id" = ChIJxQvW8wK6j4AR3ukttGy3w2s;
//            types =             (
//                premise
//            );
//        }
//    );
//    status = OK;
//}

//https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=(latitude),(longitude)&radius=5000&key=(api_key)
