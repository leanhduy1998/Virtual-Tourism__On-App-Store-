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
             
                        var imageArr = [Image]()

                        for url in imageUrlsArr {
                            let imageURL = URL(string: url)
                            let imageData = try? Data(contentsOf: imageURL!)
                            
                            let image = Image(imageData: imageData!, locationString: title, context: delegate.stack.context)
                            imageArr.append(image)
                        }
                    
                    delegate.initializeFetchedResultsController()
                    let annotationArr = delegate.fetchedResultsController.fetchedObjects as? [Annotation]
                    
                    for annotationCoreData in annotationArr! {
                        print(annotationCoreData.latitude)
                        if annotationCoreData.latitude == latitude && annotationCoreData.longitude == longitude {
                            for image in imageArr {
                                image.annotation = annotationCoreData
                            }
                        }
                    }
                    
                    do {
                        try delegate.stack.saveContext()
                    }
                    catch {
                        fatalError()
                    }
                    print("Download compltete")
                    AddImagesCollectionViewController.downloadingImageComplete = true
                    
                    /*
                    
                        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                        privateContext.persistentStoreCoordinator = delegate.stack.context.persistentStoreCoordinator
                        
                        privateContext.perform {
                            
                            
                            do {
                                try privateContext.save()
                                delegate.stack.context.performAndWait {
                                    do {
                                        try delegate.stack.context.save()
                                    }
                                    catch ((let error)){
                                        fatalError(error.localizedDescription)
                                    }
                                }
                                AddImagesCollectionViewController.downloadingImageComplete = true
                                print("Download complete")
                            }
                            catch ((let error)){
                                fatalError(error.localizedDescription)
                            }
                        }
 */
                }
                else {
                    fatalError()
                }
            }
    }


}

