//
//  ImageDetailViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/1/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit


class AddImageDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var imageURL: URL!
    var annotation = ImageAnnotation()
    
    let delegate = UIApplication.shared.delegate as? AppDelegate
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let imageData = try? Data(contentsOf: imageURL!) {
            imageView.image = UIImage(data: imageData)
        }
    }
    @IBAction func addToCollectionBtnPressed(_ sender: Any) {
        let title = annotation.title
        let latitude = Float(annotation.coordinate.latitude)
        let longitude = Float(annotation.coordinate.longitude)
        
        if let imageData = try? Data(contentsOf: imageURL!) {
            let stack = delegate?.stack
            
            let annotationArr = (delegate?.fetchedResultsController.fetchedObjects as? [Annotation])!
            
            let image = Image(imageData: imageData,locationString: title!, context: (stack?.context)!)
            
   
                for tempAnnotation in annotationArr {
                    if tempAnnotation.latitude == latitude && tempAnnotation.longitude == longitude {
                        image.annotation = tempAnnotation
                        break
                    }
                    else {
                        let annotationCoreData = Annotation(locationString: title!, latitude: Float(latitude), longitude: Float(longitude), context: (stack?.context)!)
                        image.annotation = annotationCoreData
                        break
                    }
                }
            
            
            
            do {
                try stack?.saveContext()
            }
            catch ((let error)){
                fatalError(error.localizedDescription)
            }
        }
    
        navigationController?.popToRootViewController(animated: true)
    }
}
