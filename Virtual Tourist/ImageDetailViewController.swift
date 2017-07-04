//
//  ImageDetailViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/1/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit


class ImageDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var imageURL: URL!
    var annotation = ImageAnnotation()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let imageData = try? Data(contentsOf: imageURL!) {
            imageView.image = UIImage(data: imageData)
        }
    }
    @IBAction func addToCollectionBtnPressed(_ sender: Any) {
        let title = annotation.title
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        
        if let imageData = try? Data(contentsOf: imageURL!) {
            let stack = CoreDataStack(modelName: "Model")!
            
            let annotationCoreData = Annotation(locationString: title!, latitude: Float(latitude), longitude: Float(longitude), context: stack.context)
            let image = Image(imageData: imageData,locationString: title!, context: stack.context)
            image.annotation = annotationCoreData
            
            do {
                try stack.saveContext()
            }
            catch ((let error)){
                print(error)
            }
            
        }
    
        
        
        navigationController?.popToRootViewController(animated: true)
    }
}
