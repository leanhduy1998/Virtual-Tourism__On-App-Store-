//
//  AddAnnotationViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 6/29/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate,NSFetchedResultsControllerDelegate {
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    private var annotation = ImageAnnotation()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    private var annotationForSegue = Annotation()
    

    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLoading(isLoading: false)
      
        self.tabBarController?.tabBar.isHidden = false
        delegate.initializeFetchedResultsController()
        loadAnnotation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // deletaAllDataDebug()
        self.tabBarController?.tabBar.isHidden = true
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationFromHold(gestureRecognizer:)))
        uilgr.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(uilgr)
    }
    

    private func loadAnnotation(){
        mapView.removeAnnotations(mapView.annotations)
        
        let annotationArr = (delegate.fetchedResultsController.fetchedObjects as? [Annotation])!
        
        for annotation in annotationArr {
            let cpa = ImageAnnotation()
            cpa.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(annotation.latitude), longitude: CLLocationDegrees(annotation.longitude))
            cpa.title = annotation.locationString
            
            
            let imageArr = annotation.images?.allObjects as? [Image]
            
            var imageDataArr = [Data]()
            
            if (imageArr?.count)! > 0 {
                for image in imageArr! {
                    imageDataArr.append(image.image! as Data)
                }
            }
            
            cpa.imageData = imageDataArr
            mapView.addAnnotation(cpa)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let cpa = annotation as? ImageAnnotation
        
        var image = UIImage()
        if (cpa?.imageData != nil && ( cpa?.imageData.count)! > 0) {
            image = UIImage(data: (cpa?.imageData[0])!)!
        }
        
        
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MapViewController")
        
        UIGraphicsBeginImageContext(CGSize(width: 150, height: 150))
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 150, height: 150
        ))
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        let imageView = UIImageView(image: newImage)
        
        pinAnnotationView.isDraggable = false
        pinAnnotationView.canShowCallout = true
        pinAnnotationView.animatesDrop = true
        pinAnnotationView.detailCalloutAccessoryView = imageView
        
        let addBtn = UIButton()
        addBtn.frame.size.width = 30
        addBtn.frame.size.height = 30
        addBtn.setTitle("Add Image", for: .normal)
        addBtn.setImage(UIImage(named: "camera"), for: .normal)
        
        let deleteBtn = UIButton()
        deleteBtn.frame.size.width = 30
        deleteBtn.frame.size.height = 30
        deleteBtn.setImage(UIImage(named: "delete"), for: .normal)
        
        
        pinAnnotationView.rightCalloutAccessoryView = addBtn
        pinAnnotationView.leftCalloutAccessoryView = deleteBtn
        
        return pinAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotationArr = (delegate.fetchedResultsController.fetchedObjects as? [Annotation])!
        let currentAnnotation = view.annotation as? ImageAnnotation
        
            // if delete btn clicked
        if (control as? UIButton)?.currentImage == UIImage(named: "delete") {
            for annotation in annotationArr {
                if annotation.latitude == Float((currentAnnotation?.coordinate.latitude)!) && annotation.longitude == Float((currentAnnotation?.coordinate.longitude)!)  {
                    delegate.stack.context.delete(annotation)
                    mapView.removeAnnotation(view.annotation!)
                }
            }
            do {
                try delegate.stack.saveContext()
            }
            catch ((let error)){
                fatalError(error.localizedDescription)
            }
        }
        else {
            annotation = currentAnnotation!
            performSegue(withIdentifier: "AddImagesCollectionViewController", sender: self)
        }
    }

    func addAnnotationFromHold(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began  {
            
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            mapView.removeAnnotation(annotation)
            annotation = ImageAnnotation()
            annotation.coordinate = newCoordinates
            
            annotation.title = String(format: "Latitude: %f, Longitude: %f", Float(newCoordinates.latitude),Float(newCoordinates.longitude))
            mapView.addAnnotation(annotation)
        }
        if gestureRecognizer.state == UIGestureRecognizerState.changed  {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            annotation.coordinate = newCoordinates
            annotation.title = String(format: "Latitude: %f, Longitude: %f", Float(newCoordinates.latitude),Float(newCoordinates.longitude))
        }
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            addAnnotationToCoreData()
        }
    }
    
    private func addAnnotationToCoreData(){
        let annotationArr = (delegate.fetchedResultsController.fetchedObjects as? [Annotation])!
        
        var found = false
        for annotionData in annotationArr {
            if annotionData.latitude == Float(annotation.coordinate.latitude) && annotionData.longitude == Float(annotation.coordinate.longitude){
                found = true
                break
            }
        }
        
        if !found {
            _ = Annotation(locationString: annotation.title!, latitude: Float(annotation.coordinate.latitude), longitude: Float(annotation.coordinate.longitude), page: "1", context: (delegate.stack.context))
            saveToCoreData {
                
            }
            
    
        }
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
                self.addAnnotationToCoreData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddImagesCollectionViewController {
            let destination = segue.destination as? AddImagesCollectionViewController
            destination?.annotation = annotation
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func isLoading(isLoading: Bool){
        searchTF.isEnabled = !isLoading
        view.isUserInteractionEnabled = !isLoading
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchTF.resignFirstResponder()
    }
    
    func deletaAllDataDebug(){
        do {
            try delegate.stack.dropAllData()
        }
        catch {
            fatalError()
        }
    }
    
    func saveToCoreData(completeHandler: @escaping ()-> Void){
        do {
            try delegate.stack.saveContext()
        }
        catch ((let error)){
            fatalError(error.localizedDescription)
        }
        print("done saving")
    }
    
}
