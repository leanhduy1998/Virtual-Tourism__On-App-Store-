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
        
        // This method must be implemented by our subclass. There's no way
        // CoreDataTableViewController can know what type of cell we want to
        // use.
        
        // Find the right notebook for this indexpath
        let annotation = fetchedResultsController!.object(at: indexPath) as! Annotation
        
        // Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell
        
        // Sync notebook -> cell
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

}
