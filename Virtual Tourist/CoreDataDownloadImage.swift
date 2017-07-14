//
//  DownloadImages.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/9/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataDownloadImage {
    private static let delegate = UIApplication.shared.delegate as! AppDelegate
    
    static func downloadURLs(title: String, latitude: Float, longitude: Float, page: Int){
            FlickrClient.downloadLocationImagesUrls(page: page, latitude: latitude, longitude: longitude) { (imageUrlsArr, error) in
                if error.isEmpty {
                    
                    AddImagesCollectionViewController.imageUrlArr = imageUrlsArr
                    var annotation = Annotation()
                    
                    DispatchQueue.main.async {
                        delegate.initializeFetchedResultsController()
                        let annotationArr = delegate.fetchedResultsController.fetchedObjects as? [Annotation]
                        
                        for annotationCoreData in annotationArr! {
                            if annotationCoreData.latitude == latitude && annotationCoreData.longitude == longitude {
                                annotation = annotationCoreData
                            }
                        }
                    }
                    
                    for url in imageUrlsArr {
                        HttpRequest.downloadImage(imagePath: url, completionHandler: { (imageData, error) in
                            DispatchQueue.main.async {
                                let image = Image(imageData: imageData!, locationString: title, context: delegate.stack.context)
                                image.annotation = annotation
                                
                                do {
                                    try delegate.stack.saveContext()
                                }
                                catch {
                                    fatalError()
                                }
                                
                                if annotation.images?.count == imageUrlsArr.count {
                                    print("download complete")
                                    AddImagesCollectionViewController.downloadingImageComplete = true
                                }
                            }
                        })
                    }
                    
                    }
                else {
                    fatalError(error)
                }
            }
    }


}

