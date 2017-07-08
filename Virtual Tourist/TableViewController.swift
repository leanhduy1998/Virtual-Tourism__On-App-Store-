//
//  TableViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/2/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: CoreDataTableViewController {
    private var index: IndexPath!
    private var indexForEdit: IndexPath!
    private let delegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        view.addGestureRecognizer(longPressRecognizer)
        
        
        title = "Annotations"
        
        let stack = delegate?.stack
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotation")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false),NSSortDescriptor(key:"locationString",ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: (stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
    }
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
               onLongPressed(indexPath: indexPath)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let annotation = fetchedResultsController!.object(at: indexPath) as! Annotation
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell
        
        cell?.locationLabel.text = annotation.locationString
        
        if(annotation.images?.count == 1) {
            cell?.numberOfPicsLabel.text = "1 picture"
        }
        else if(annotation.images?.count == 0) {
            cell?.numberOfPicsLabel.text = "0 picture"
        }
        else {
            
            cell?.numberOfPicsLabel.text = "\(String(format: "%d pictures", (annotation.images?.count)!)) pictures"
        }
        
        let imageArr = annotation.images?.allObjects as? [Image]
        
        if imageArr?.count == 0 {
            let alertController = UIAlertController(title: "Error adding your picture", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let imageData = imageArr?[0].image
            cell?.imageV.image =  UIImage(data: imageData! as Data)
        }
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.index = indexPath
        performSegue(withIdentifier: "tableToShowImagesCollectionViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ShowImagesCollectionViewController {
            let annotation = fetchedResultsController!.object(at: index) as! Annotation
            
            let imageArr = annotation.images?.allObjects as? [Image]
            var imageDataArr = [Data]()
            for image in imageArr! {
                imageDataArr.append(image.image! as Data)
            }
    
            destination.imageDataArr = imageDataArr
            destination.annotationForDeleting = annotation
        }
    }
    
    private func onLongPressed(indexPath: IndexPath){
        indexForEdit = indexPath
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete Location and Pictures", style: UIAlertActionStyle.default, handler: deleteAnnotation))
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func deleteAnnotation(action: UIAlertAction){
        let annotation = fetchedResultsController!.object(at: indexForEdit) as! Annotation
        delegate?.stack.context.delete(annotation)

        do {
            try delegate?.stack.saveContext()
        }
        catch ((let error)){
            fatalError(error.localizedDescription)
        }
    }
    

}
