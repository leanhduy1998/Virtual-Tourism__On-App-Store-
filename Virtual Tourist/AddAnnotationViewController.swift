//
//  AddAnnotationViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 6/29/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import MapKit

class AddAnnotationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var getImageBtn: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private var annotation = ImageAnnotation()
    private var imageUrlArr = [String]()
    private var goingForward: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        uilgr.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(uilgr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLoading(isLoading: false)
        getImageBtn.isEnabled = false
    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            annotation = ImageAnnotation()
            annotation.coordinate = newCoordinates
            annotation.title = String(format: "Latitude: %f, Longitude: %f", Float(newCoordinates.latitude),Float(newCoordinates.longitude))
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            
            getImageBtn.isEnabled = true
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AddAnnotationViewController")
        pinAnnotationView.isDraggable = false
        pinAnnotationView.canShowCallout = true
        pinAnnotationView.animatesDrop = true
    
        return pinAnnotationView
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchTF.text
        
        let localSearch = MKLocalSearch(request: localSearchRequest)
        
        localSearch.start { (localSearchResponse, error) -> Void in
            if localSearchResponse == nil {
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            self.annotation.title = self.searchTF.text
            self.annotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            self.mapView.addAnnotation(self.annotation)
            
            DispatchQueue.main.async {
                self.getImageBtn.isEnabled = true
                self.refreshMapView()
            }
        }
    }

    func refreshMapView(){
        let arr = mapView.annotations
        mapView.removeAnnotations(arr)
        mapView.addAnnotations(arr)
    }
    @IBAction func getImageBtnPressed(_ sender: Any) {
        isLoading(isLoading: true)
        let latitude = Float(annotation.coordinate.latitude)
        let longitude = Float(annotation.coordinate.longitude)
        
        let request = NSMutableURLRequest(url: FlickrClient.searchImage(latitude: latitude, longitude: longitude))
        let session = URLSession.shared
        
        let task = session.dataTask(with: (request as? URLRequest)!, completionHandler: { (data, respond, error) in
            if error == nil {
                var parsedData: [String:AnyObject] = [:]
                do {
                    try parsedData = (JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject])!
                }
                catch {
                    print("parse data err")
                    print(error.localizedDescription)
                }
                guard let photos = parsedData["photos"] as? [String:AnyObject] else {
                    print("photos err")
                    return
                }
                guard let photoArr = photos["photo"] as? [[String:AnyObject]] else {
                    print("photoArr err")
                    return
                }
                
                for photo in photoArr {
                    guard let url = photo["url_m"] as? String else {
                        print("url err")
                        return
                    }
                    self.imageUrlArr.append(url)
                }
            
                self.isLoading(isLoading: false)
                self.displayImageCollectionViewController()
            }
            else {
                print("task err")
            }
        })
        task.resume()
    }
    private func displayImageCollectionViewController(){
        goingForward = true
        performSegue(withIdentifier: "ImagesCollectionViewController", sender: self)

    }
    private func isLoading(isLoading: Bool){
        activityIndicator.isHidden = !isLoading
        searchTF.isEnabled = !isLoading
        getImageBtn.isEnabled = !isLoading
        view.isUserInteractionEnabled = !isLoading
        
        if isLoading {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddImagesCollectionViewController {
            let destination = segue.destination as? AddImagesCollectionViewController
            destination?.imageUrlArr = imageUrlArr
            destination?.annotation = annotation
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchTF.resignFirstResponder()
    }
    
}
