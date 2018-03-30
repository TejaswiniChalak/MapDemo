//
//  NearByPlacesDetail.swift
//  MapDemo
//
//  Created by Tejaswini on 27/03/18.
//  Copyright © 2018 Tejaswini. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import GooglePlacePicker

class NearByPlacesDetail: UIViewController {

    //@IBOutlet var mapView: GMSMapView!
    var placeCategory : String = ""
    var locations = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    var placesArray : [[String : Any]] = []
    var addressArray : [String] = []
    var locationArray : [[String : Any]] = []
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.frame = CGRect(x: 0, y: self.view.bounds.size.height/2, width: self.view.bounds.size.width, height: 200)
        self.view.addSubview(pickerView)
        // Do any additional setup after loading the view.
        print("PlaceCategory",placeCategory)
       
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(String(describing: locations.latitude)),\(String(describing: locations.longitude))&radius=1000&types=\(placeCategory)&key=AIzaSyDY4utU6hyV0hqpUGyeWf8H4zdIurQt3Ao"
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
                        let lat = location["lat"] as! Double
                        let lng = location["lng"] as! Double
                        self.locationArray.append(location)
                        print("LocationsArray",self.locationArray)
                        let center = CLLocationCoordinate2D(latitude: 37.788204, longitude: -122.411937)
                        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
                        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
                        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                        let config = GMSPlacePickerConfig(viewport: viewport)
                        let placePicker = GMSPlacePicker(config: config)
                        placePicker.pickPlace(callback: {(place, error) -> Void in
                            if let error = error {
                                print("Pick Place error: \(error.localizedDescription)")
                                return
                            }
                        })
//                        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 8.0)
//                         self.mapView.camera = camera
//                        self.showMarker(location: self.locationArray)
                    }
                }
            }
        }
    }
//    func showMarker(location:[[String : Any]]){
//        for dict in location{
//            print("dict",dict)
//            let lat = dict["lat"] as! Double
//            let lng = dict["lng"] as! Double
//            let loc = CLLocationCoordinate2D(latitude: lat, longitude: lng)
//            var originMarker = GMSMarker()
//            originMarker.title = ""
//            originMarker.position = loc
//            originMarker.snippet = "US us us us us us"
//            originMarker.map = mapView
//
//        }
//
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
extension NearByPlacesDetail : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
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
            break
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
