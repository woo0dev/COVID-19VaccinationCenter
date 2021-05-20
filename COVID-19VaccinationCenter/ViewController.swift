//
//  ViewController.swift
//  COVID-19VaccinationCenter
//
//  Created by Woo0 on 2021/04/12.
//

import UIKit
import NMapsMap
import CoreLocation

let key = "g4CVdFveh5eMEiCUuZtycJ2FiYeYVhwfFXURiUZ2Kex4vl4MemZRTtifCWHhwXy59GzlUQj9ICPvXYIgCkn7Dg%3D%3D"
let urlString = "https://api.odcloud.kr/api/15077586/v1/centers?page=1&perPage=10000&serviceKey=g4CVdFveh5eMEiCUuZtycJ2FiYeYVhwfFXURiUZ2Kex4vl4MemZRTtifCWHhwXy59GzlUQj9ICPvXYIgCkn7Dg%3D%3D"

let url = URL(string: urlString)

let jsonData = try! String(contentsOf: url!).data(using: .utf8)

struct CenterData: Codable {
    let currentCount: Int
    let data: [Datum]
    let matchCount, page, perPage, totalCount: Int
}

struct Datum: Codable {
    let address, centerName: String
    let centerType: CenterType
    let facilityName: String
    let id: Int
    let lat, lng, org, sido: String
    let sigungu, zipCode: String
}

enum CenterType: String, Codable {
    case 중앙권역 = "중앙/권역"
    case 지역 = "지역"
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {
    
    var address: String!
    var city = "전국"
    var locationManager: CLLocationManager!
    var bMarker = false
    
    var markerList = Array<NMFMarker>()
    
    @IBOutlet weak var mapView: NMFMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func infoBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "infoSegue", sender: address)
    }
    @IBAction func peopleInfoBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "peopleSegue", sender: city)
    }
    
    @IBOutlet weak var popupBtn: UIButton!
    @IBOutlet weak var citySelect: UITextField!
    
    let pickerView = UIPickerView()
    var selectCity = ""
    let pickerData = ["전국", "서울특별시" , "경기도" , "인천광역시" , "부산광역시" , "대구광역시" , "광주광역시" , "대전광역시" , "울산광역시", "세종특별자치시", "강원도", "충청북도", "충청남도", "전라북도", "전라남도", "경상북도", "경상남도", "제주특별자치도"]
    var filterData = ["서울특별시" , "경기도" , "인천광역시" , "부산광역시" , "대구광역시" , "광주광역시" , "대전광역시" , "울산광역시", "세종특별자치시", "강원도", "충청북도", "충청남도", "전라북도", "전라남도", "경상북도", "경상남도", "제주특별자치도"]
    var locationData = ["서울특별시" , "경기도" , "인천광역시" , "부산광역시" , "대구광역시" , "광주광역시" , "대전광역시" , "울산광역시", "세종특별자치시", "강원도", "충청북도", "충청남도", "전라북도", "전라남도", "경상북도", "경상남도", "제주특별자치도"]
    
    let centerData = try? JSONDecoder().decode(CenterData.self, from: jsonData!)
    
    
    var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
        self.searchBar.placeholder = "지역명을 검색하세요."
        
        //self.filterData = self.locationData
        
        mapView.zoomLevel = 10
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        let coor = locationManager.location!.coordinate
        let defaultLat = Double(coor.latitude)
        let defaultLng = Double(coor.longitude)

        let camPosition =  NMGLatLng(lat: defaultLat, lng: defaultLng)
        let cameraUpdate = NMFCameraUpdate(scrollTo: camPosition)
        mapView.moveCamera(cameraUpdate)
        
        mapView.positionMode = .direction
        
        popupBtn.addTarget(self, action: #selector(goAlert), for: .touchUpInside)

        address = centerData?.data[0].address
        
        let infoWindow = NMFInfoWindow()

        if bMarker == false {
            for data in centerData!.data {
                let lat = Double(data.lat)
                let lng = Double(data.lng)
                
                let marker = NMFMarker()
                marker.position = NMGLatLng(lat: lng!, lng: lat!)
                marker.iconImage = NMF_MARKER_IMAGE_BLACK
                marker.isHideCollidedMarkers = true
                marker.iconTintColor = UIColor.orange
                marker.captionText = data.centerName
                marker.captionMinZoom = 9
                marker.captionMaxZoom = 16
                marker.captionRequestedWidth = 100
                marker.width = 20
                marker.height = 30
                
                //marker.mapView = mapView
                
                marker.touchHandler = { (overlay) -> Bool in
                    let dataSource = NMFInfoWindowDefaultTextSource.data()
                    dataSource.title = data.centerName
                    infoWindow.dataSource = dataSource


                    infoWindow.position = NMGLatLng(lat: lng!, lng: lat!)
                    infoWindow.mapView = self.mapView
                    
                    if let marker = overlay as? NMFMarker {
                        if marker.infoWindow == nil {
                            self.address = data.address
                            infoWindow.open(with: marker)
                        } else {
                            infoWindow.close()
                        }
                    }
                    return true
                }
                
                markerList.append(marker)
                
                for m in markerList {
                    m.mapView = mapView
                }
            }
        }
        pickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 220)
        pickerView.delegate = self
        pickerView.dataSource = self

        let pickerToolbar : UIToolbar = UIToolbar()
        pickerToolbar.barStyle = .default
        pickerToolbar.isTranslucent = true
        pickerToolbar.backgroundColor = .lightGray
        pickerToolbar.sizeToFit()
        let btnDone = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancel))
        pickerToolbar.setItems([btnCancel , space , btnDone], animated: true)
        pickerToolbar.isUserInteractionEnabled = true
                
        citySelect.inputView = pickerView
        citySelect.inputAccessoryView = pickerToolbar

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue"{
            if let infoViewController = segue.destination as? infoViewController{ infoViewController.address = address } else { return }
        } else if segue.identifier == "peopleSegue"{
            if let numberPeopleInfoVC = segue.destination as? numberPeopleInfoVC{ numberPeopleInfoVC.citySelect = city } else { return }
        }
    }
    @objc func goAlert(){
        let alert = self.storyboard?.instantiateViewController(withIdentifier: "popupViewController") as! popupViewController
        alert.modalPresentationStyle = .overCurrentContext
        present(alert, animated: false, completion: nil)
    }
    @objc func onPickDone() {
        city = selectCity
        citySelect.text = "  " + selectCity
        citySelect.resignFirstResponder()
        selectCity = ""
    }

    @objc func onPickCancel() {
        citySelect.resignFirstResponder()
        selectCity = ""
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectCity = pickerData[row]
    }
    
    func searchBar( searcbar: UISearchBar, textDidChange searchText: String) {
        filterData = searchText.isEmpty ? locationData : locationData.filter({(dataString:String) -> Bool in return dataString.range(of: searchText, options: .caseInsensitive) != nil })
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if self.searchBar.text == "서현이" {
//            let refreshAlert = UIAlertController(title: "서현이짱", message: self.searchBar.text!, preferredStyle: UIAlertController.Style.alert)
//
//            refreshAlert.addAction(UIAlertAction(title: "❤︎", style: .default, handler: { (action: UIAlertAction!) in print("검색확인")
//                self.searchBar.showsCancelButton = false
//                self.searchBar.text = ""
//                self.searchBar.resignFirstResponder()
//
//            }))
//            present(refreshAlert, animated: true, completion: nil)
//        }

        for m in markerList {
            m.mapView = nil
        }
        markerList.removeAll()
        for data in centerData!.data {
            let infoWindow = NMFInfoWindow()

            let lat = Double(data.lat)
            let lng = Double(data.lng)

            let marker = NMFMarker()
                    
            var range: Range<String.Index>
                    
            let arr = Array(self.searchBar.text!)
            if self.searchBar.text?.count != 0 {
                
                let startRange = data.centerName.range(of: String(arr[0]))
                let endRange = data.centerName.range(of: String(arr[arr.count-1]))
                
                if startRange?.lowerBound != nil && endRange?.lowerBound != nil{
                    
                    let rangeCount = data.centerName.distance(from: data.centerName.startIndex, to: endRange!.lowerBound)
                    
                    let start = data.centerName.index(data.centerName.startIndex, offsetBy: 6)
                    let end = data.centerName.index(data.centerName.startIndex, offsetBy: rangeCount+1)
                    
                    if start < end {
                        range = start..<end
                                
                        if String(self.searchBar.text!) == data.centerName[range] {
                                    
                            marker.position = NMGLatLng(lat: lng!, lng: lat!)
                            marker.iconImage = NMF_MARKER_IMAGE_BLACK
                            marker.isHideCollidedMarkers = true
                            marker.iconTintColor = UIColor.red
                            marker.captionText = data.centerName
                            marker.captionMinZoom = 9
                            marker.captionMaxZoom = 16
                            marker.captionRequestedWidth = 100
                            marker.width = 20
                            marker.height = 30
                            marker.mapView = mapView

                            marker.touchHandler = { (overlay) -> Bool in
                                let dataSource = NMFInfoWindowDefaultTextSource.data()
                                dataSource.title = data.centerName
                                infoWindow.dataSource = dataSource

                                infoWindow.position = NMGLatLng(lat: lng!, lng: lat!)
                                infoWindow.mapView = self.mapView

                                if let marker = overlay as? NMFMarker {
                                    if marker.infoWindow == nil {
                                        self.address = data.address
                                        infoWindow.open(with: marker)
                                    } else {
                                        infoWindow.close()
                                    }
                                }
                                return true
                            }
                            let camPosition =  NMGLatLng(lat: lng!, lng: lat!)
                            let cameraUpdate = NMFCameraUpdate(scrollTo: camPosition)
                            mapView.moveCamera(cameraUpdate)
                            mapView.zoomLevel = 7
                        }
                    }
                    else {
                        let range = end..<start
                            
                        if String(self.searchBar.text!) == data.centerName[range] {
                            
                            marker.position = NMGLatLng(lat: lng!, lng: lat!)
                            marker.iconImage = NMF_MARKER_IMAGE_BLACK
                            marker.isHideCollidedMarkers = true
                            marker.iconTintColor = UIColor.red
                            marker.captionText = data.centerName
                            marker.captionMinZoom = 9
                            marker.captionMaxZoom = 16
                            marker.captionRequestedWidth = 100
                            marker.width = 20
                            marker.height = 30
                            marker.mapView = mapView

                            marker.touchHandler = { (overlay) -> Bool in
                                let dataSource = NMFInfoWindowDefaultTextSource.data()
                                dataSource.title = data.centerName
                                infoWindow.dataSource = dataSource
                                infoWindow.position = NMGLatLng(lat: lng!, lng: lat!)
                                infoWindow.mapView = self.mapView

                                if let marker = overlay as? NMFMarker {
                                    if marker.infoWindow == nil {
                                        self.address = data.address
                                        infoWindow.open(with: marker)
                                    } else {
                                        infoWindow.close()
                                    }
                                }
                                return true
                            }
                            let camPosition =  NMGLatLng(lat: lng!, lng: lat!)
                            let cameraUpdate = NMFCameraUpdate(scrollTo: camPosition)
                            mapView.moveCamera(cameraUpdate)
                            mapView.zoomLevel = 7
                            
                        }
                    }
                    markerList.append(marker)
                }
            } else {
                for m in markerList {
                    m.mapView = nil
                }
                markerList.removeAll()
                for data in centerData!.data {
                    let lat = Double(data.lat)
                    let lng = Double(data.lng)
                    
                    let marker = NMFMarker()
                    marker.position = NMGLatLng(lat: lng!, lng: lat!)
                    marker.iconImage = NMF_MARKER_IMAGE_BLACK
                    marker.isHideCollidedMarkers = true
                    marker.iconTintColor = UIColor.orange
                    marker.captionText = data.centerName
                    marker.captionMinZoom = 9
                    marker.captionMaxZoom = 16
                    marker.captionRequestedWidth = 100
                    marker.width = 20
                    marker.height = 30
                    
                    //marker.mapView = mapView
                    
                    marker.touchHandler = { (overlay) -> Bool in
                        let dataSource = NMFInfoWindowDefaultTextSource.data()
                        dataSource.title = data.centerName
                        infoWindow.dataSource = dataSource

                        infoWindow.position = NMGLatLng(lat: lng!, lng: lat!)
                        infoWindow.mapView = self.mapView
                                
                        if let marker = overlay as? NMFMarker {
                            if marker.infoWindow == nil {
                                self.address = data.address
                                infoWindow.open(with: marker)
                            } else {
                                infoWindow.close()
                            }
                        }
                        return true
                    }
                    
                    markerList.append(marker)
                }
            }
            for m in markerList {
                m.mapView = mapView
            }
        }
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
    
}

extension StringProtocol {
    func distance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func distance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}
extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}
extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}
