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

class AddAnnotationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate,NSFetchedResultsControllerDelegate {
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    private var annotation = ImageAnnotation()
    private var imageUrlArr = [String]()
    private var goingForward: Bool = false
    let delegate = UIApplication.shared.delegate as! AppDelegate
    private var imageDataArrForSegue = [Data]()
    private var annotationForSegue = Annotation()
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLoading(isLoading: false)
        //  deletaAllDataDebug()
        initializeFetchedResultsController()
        loadAnnotation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
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
        
        var haveImage = false
        
        let cpa = annotation as? ImageAnnotation
        
        var image = UIImage()
        if (cpa?.imageData != nil && ( cpa?.imageData.count)! > 0) {
            image = UIImage(data: (cpa?.imageData[0])!)!
            haveImage = true
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
        
        if haveImage == true {
            pinAnnotationView.detailCalloutAccessoryView = imageView
            
            let collectionBtn = UIButton()
            collectionBtn.frame.size.width = 30
            collectionBtn.frame.size.height = 30
            collectionBtn.setImage(UIImage(named: "table_30x30"), for: .normal)
            
            let deleteBtn = UIButton()
            deleteBtn.frame.size.width = 30
            deleteBtn.frame.size.height = 30
            deleteBtn.setImage(UIImage(named: "delete"), for: .normal)
            
            pinAnnotationView.rightCalloutAccessoryView = collectionBtn
            pinAnnotationView.leftCalloutAccessoryView = deleteBtn
        }
        else {
            let addBtn = UIButton()
            addBtn.frame.size.width = 30
            addBtn.frame.size.height = 30
            addBtn.setTitle("Add Image", for: .normal)
            addBtn.setImage(UIImage(named: "camera"), for: .normal)
            
            pinAnnotationView.rightCalloutAccessoryView = addBtn
        }
        
        return pinAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotationArr = (delegate.fetchedResultsController.fetchedObjects as? [Annotation])!
        let currentAnnotation = view.annotation
        
        // if collection Btn clicked
        if (control as? UIButton)?.currentImage == UIImage(named: "table_30x30") {
            let annotation = view.annotation as? ImageAnnotation
            imageDataArrForSegue = (annotation?.imageData)!
            
            for annotation in annotationArr {
                if annotation.latitude == Float((currentAnnotation?.coordinate.latitude)!) && annotation.longitude == Float((currentAnnotation?.coordinate.longitude)!)  {
                    annotationForSegue = annotation
                }
            }
            performSegue(withIdentifier: "mapToShowImagesCollectionViewController", sender: self)
        }
            // if delete btn clicked
        else if (control as? UIButton)?.currentImage == UIImage(named: "delete") {
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
            annotation = currentAnnotation as! ImageAnnotation
            displayAddImageCollectionViewController()
        }
    }

    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            annotation = ImageAnnotation()
            annotation.coordinate = newCoordinates
            
            annotation.title = String(format: "Latitude: %f, Longitude: %f", Float(newCoordinates.latitude),Float(newCoordinates.longitude))
            mapView.addAnnotation(annotation)
            
            let annotationCoreData = Annotation(locationString: annotation.title!, latitude: Float(annotation.coordinate.latitude), longitude: Float(annotation.coordinate.longitude), context: (delegate.stack.context))
            self.delegate.stack.context.insert(annotationCoreData)
            self.saveToCoreData()
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
                let annotationCoreData = Annotation(locationString: self.searchTF.text!, latitude: Float(self.annotation.coordinate.latitude), longitude: Float(self.annotation.coordinate.longitude), context: (self.delegate.stack.context))
                self.delegate.stack.context.insert(annotationCoreData)
                self.saveToCoreData()
                self.refreshMapView()
            }
        }
    }

    func displayAddImageCollectionViewController(){
        goingForward = true
        performSegue(withIdentifier: "AddImagesCollectionViewController", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ShowImagesCollectionViewController {
            destination.imageDataArr = imageDataArrForSegue
            destination.annotationForDeleting = annotationForSegue
        }
        else if segue.destination is AddImagesCollectionViewController {
            let destination = segue.destination as? AddImagesCollectionViewController
            destination?.imageUrlArr = imageUrlArr
            destination?.annotation = annotation
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
