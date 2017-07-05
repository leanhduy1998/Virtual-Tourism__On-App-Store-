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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the title
        title = "Annotations"
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotation")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false),NSSortDescriptor(key:"locationString",ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    // MARK: TableView Data Source
    
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
            cell?.numberOfPicsLabel.text = "\(String(describing: annotation.images?.count)) pictures"
        }
        
        let imageArr = annotation.images?.allObjects as? [Image]
        
        
        let imageData = imageArr?[0].image
        cell?.imageV.image =  UIImage(data: imageData! as Data)

        
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.index = indexPath
        performSegue(withIdentifier: "tableToShowImagesCollectionViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ShowImagesCollectionViewController {
            let annotation = fetchedResultsController!.object(at: index) as! Annotation
            destination.imageDataArr = (annotation.images?.allObjects as? [Data])!
        }
    }
    
    //

}
