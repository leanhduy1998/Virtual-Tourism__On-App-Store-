//
//  AddAnnotationViewControllerExtension.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/8/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import CoreData

extension AddAnnotationViewController {
    
    
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
    func refreshMapView(){
        let arr = mapView.annotations
        mapView.removeAnnotations(arr)
        mapView.addAnnotations(arr)
    }
    private func deletaAllDataDebug(){
        do {
            try delegate.stack.dropAllData()
        }
        catch {
            fatalError()
        }
    }
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
     func saveToCoreData(){
        do {
            try delegate.stack.saveContext()
        }
        catch ((let error)){
            fatalError(error.localizedDescription)
        }
    }
    
    
}
