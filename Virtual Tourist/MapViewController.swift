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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func refreshData(){
        let tempData = mapView.annotations
        mapView.removeAnnotations(tempData)
        mapView.addAnnotations(tempData)
    }
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    func initializeFetchedResultsController() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotation")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false),NSSortDescriptor(key:"locationString",ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        initializeFetchedResultsController()
        loadAnnotation()
    }
    private func loadAnnotation(){
        let annotationArr = fetchedResultsController.fetchedObjects as? [Annotation]
        for annotation in annotationArr! {
            let cpa = ImageAnnotation()
            let imageData = annotation.images?.allObjects
            cpa.imageData =  imageData as? [Data]
            cpa.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(annotation.latitude), longitude: CLLocationDegrees(annotation.longitude))
            cpa.title = annotation.locationString
            mapView.addAnnotation(cpa)
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let cpa = annotation as? ImageAnnotation else {
            return nil
        }
        
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
        
        let image = UIImage(data: (cpa.imageData[0]))
        
        UIGraphicsBeginImageContext(CGSize(width: 150, height: 150))
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 150, height: 150
        ))
        image?.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        let imageView = UIImageView(image: newImage)
        
        pinAnnotationView.isDraggable = true
        pinAnnotationView.canShowCallout = true
        pinAnnotationView.animatesDrop = true
        pinAnnotationView.detailCalloutAccessoryView = imageView
        
        let collectionBtn = UIButton()
        collectionBtn.frame.size.width = 30
        collectionBtn.frame.size.height = 30
        collectionBtn.setImage(UIImage(named: "table_30x30"), for: .normal)
        
        pinAnnotationView.rightCalloutAccessoryView = collectionBtn

        return pinAnnotationView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as? ImageAnnotation
        
    }
    private func showCollection(){
        
    }
    

    
    

}



