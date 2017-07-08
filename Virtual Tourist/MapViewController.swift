//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 6/28/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    private var imageDataArrForSegue = [Data]()
    private var annotationForSegue = Annotation()
    
    func initializeFetchedResultsController() {
        let stack = delegate.stack
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotation")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false),NSSortDescriptor(key:"locationString",ascending: false)]
        
        delegate.fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try delegate.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    private func deletaAllDataDebug(){
        do {
            try delegate.stack.dropAllData()
        }
        catch {
            fatalError()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  deletaAllDataDebug()
        self.tabBarController?.tabBar.isHidden = false
        initializeFetchedResultsController()
        findAndDeleteEmptyData()
        loadAnnotation()
    }
    
    private func findAndDeleteEmptyData() {
        let annotationArr = (delegate.fetchedResultsController.fetchedObjects as? [Annotation])!
        for annotation in annotationArr {
            if annotation.images?.allObjects.count == 0 {
                delegate.stack.context.delete(annotation)
            }
        }
        do {
            try delegate.stack.saveContext()
        }
        catch ((let error)){
            fatalError(error.localizedDescription)
        }
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
        
        let image = UIImage(data: (cpa?.imageData[0])!)!
        
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
        else {
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ShowImagesCollectionViewController {
            destination.imageDataArr = imageDataArrForSegue
            destination.annotationForDeleting = annotationForSegue
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}



