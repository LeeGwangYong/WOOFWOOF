//
//  MapViewController.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import CoreLocation
enum POIType: Int {
    case dog = 0
    case home = 1
}

class MapViewController: UIViewController {
    var flag = false
    //MARK -: Property
    @IBOutlet var mapAreaView: UIView!
    @IBOutlet var timeLabel: UILabel!
    lazy var mapView: MTMapView = MTMapView(frame:
        CGRect(x: 0, y: 0, width: self.mapAreaView.frame.size.width, height: self.mapAreaView.frame.size.height))
    let locationManager = CLLocationManager()
    
    @IBOutlet var profileImage: RoundedImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var alertButton: UIButton!
    
    var date: Date?
    
    //MARK -: Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImage.image = Profile.getProfile()
        self.setUpMap()
        NotificationCenter.default.addObserver(self, selector: #selector(getRSSI(rssi:)), name: .rssi, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getPeripheralState(notification:)), name: .peripheralState, object: nil)
    }
    
    @objc func getRSSI(rssi: NSNumber) {
    }
    
    @objc func getPeripheralState(notification: Notification) {
        guard let state = notification.userInfo?["state"] as? Bool else { return }
        
        if state {
            PeripheralInfo.currentDog = PeripheralInfo.currentMy
            
            alertButton.setImage(#imageLiteral(resourceName: "missingOff"), for: .normal)
        }
        else {
            alertButton.setImage(#imageLiteral(resourceName: "missingOn"), for: .normal)
        }
        if let currentDog = PeripheralInfo.currentDog {
            getAddressFromLatLon(lat: (currentDog.mapPointGeo().latitude), lon: (currentDog.mapPointGeo().longitude))
            self.mapView.add(poiItem(name: "복순이", location: currentDog, type: .dog))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let coordinate = locationManager.location?.coordinate {
            self.mapView.setMapCenter(MTMapPoint(geoCoord: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                , zoomLevel: 0, animated: true)
        }
    }
    
    @IBAction func missingAction(_ sender: UIButton) {
        if PeripheralInfo.peripheral != nil {
            PeripheralInfo.manager.cancelPeripheralConnection(PeripheralInfo.peripheral)
        }
    }
    
    @IBAction func moveToCurrent(_ sender: UIButton) {
        self.mapView.setMapCenter(PeripheralInfo.currentMy, zoomLevel: 0, animated: true)
    }
    
    @IBAction func moveToDog(_ sender: UIButton) {
        
        //        let center = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.4506395233017, longitude: 126.655187004005))
        if let currentDog = PeripheralInfo.currentDog {
            self.mapView.setMapCenter(currentDog, zoomLevel: 0, animated: true)
        }
    }
}

//MARK -: Extension
//MARK : Map
extension MapViewController: MTMapViewDelegate, CLLocationManagerDelegate {
    func setUpMap() {
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            
            self.mapView.delegate = self
            self.mapView.baseMapType = .standard
            self.mapView.setZoomLevel(0, animated: true)
            self.mapView.currentLocationTrackingMode = .onWithoutHeadingWithoutMapMoving
            let markerItem = MTMapLocationMarkerItem()
            markerItem.fillColor = UIColor.green.withAlphaComponent(0.1)
            markerItem.strokeColor = UIColor.green.withAlphaComponent(0.3)
            markerItem.radius = 30
            markerItem.customTrackingImageName = "map_present.png"
            self.mapView.updateCurrentLocationMarker(markerItem)
            self.mapAreaView.insertSubview(mapView, at: 0)
        }
    }
    
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        PeripheralInfo.currentMy = location
    }
    
    func removePOIFromTag(type: POIType) {
        for item in self.mapView.poiItems as! [MTMapPOIItem] {
            if item.tag == type.rawValue {
                self.mapView.remove(item)
            }
        }
    }
    
    func poiItem(name: String, location: MTMapPoint, type: POIType) -> MTMapPOIItem {
        let poiItem = MTMapPOIItem()
        poiItem.itemName = name
        poiItem.markerType = .customImage
        poiItem.mapPoint = location
        poiItem.showAnimationType = .springFromGround
        poiItem.showDisclosureButtonOnCalloutBalloon = false
        removePOIFromTag(type: type)
        switch type {
        case .dog:
            poiItem.tag = POIType.dog.rawValue
            poiItem.customImage = getPinImage(topImage: Profile.getProfile().circleMasked!)
            poiItem.customImageAnchorPointOffset = .init(offsetX: Int32(poiItem.customImage.size.width / 2) , offsetY: 0)
        case .home:
            poiItem.tag = POIType.home.rawValue
            poiItem.customImage = getImage(image: #imageLiteral(resourceName: "homeBig"), type: .home)
            poiItem.customImageAnchorPointOffset = .init(offsetX: Int32(poiItem.customImage.size.width / 2),
                                                         offsetY: Int32(poiItem.customImage.size.height / 2))
            break
        }
        return poiItem
    }
    
    func mapView(_ mapView: MTMapView!, longPressOn mapPoint: MTMapPoint!) {
        if flag {
            self.mapView.add(poiItem(name: "집", location: mapPoint, type: .home))
            flag = false
        }
        else {
            self.mapView.add(poiItem(name: "복순이", location: mapPoint, type: .dog))
            flag = true
        }
    }
    
    func getImage(image: UIImage, type: POIType) -> UIImage {
        let width = image.size.width * (type == POIType.home ? 1.5 : 1)
        let height = image.size.height * (type == POIType.home ? 1.5 : 1)
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        image.draw(in: areaSize)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func getPinImage(topImage: UIImage) -> UIImage {
        let image:UIImage = #imageLiteral(resourceName: "locationG")
        let size = CGSize(width: image.size.width * 2, height: image.size.height * 2)
        UIGraphicsBeginImageContext(size)
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        image.draw(in: areaSize)
        
        let width = size.width * 0.9
        topImage.draw(in: CGRect(x: (size.width - width) / 2, y: (size.width - width) / 2
            , width: width, height: width)
            , blendMode: CGBlendMode.normal, alpha: 1)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func getAddressFromLatLon(lat: Double, lon: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                if let pm = placemarks {
                    
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        var addressString : String = ""
                        
                        if pm.administrativeArea != nil {
                            addressString = addressString + pm.administrativeArea! + " "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + " "
                        }
                        
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality!
                        }
                        self.addressLabel.text = addressString
                    }
                }
        })
        
    }
}
