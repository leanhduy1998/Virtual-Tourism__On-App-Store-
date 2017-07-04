//
//  AddAnnotationViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 6/29/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import MapKit

class AddAnnotationViewController: UIViewController {
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var getImageBtn: UIBarButtonItem!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    private var annotation = ImageAnnotation()
    private var imageUrlArr = [String]()
    private var goingForward: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLoading(isLoading: false)
        getImageBtn.isEnabled = false
        
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
        loadingLabel.isHidden = !isLoading
        searchTF.isEnabled = !isLoading
        getImageBtn.isEnabled = !isLoading
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImagesCollectionViewController {
            let destination = segue.destination as? ImagesCollectionViewController
            destination?.imageUrlArr = imageUrlArr
            destination?.annotation = annotation
        }
    }
}
