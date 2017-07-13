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
                            AddImagesCollectionViewController.imageUrlArr.append(url)
                            let imageURL = URL(string: url)

                            let imageData = try? Data(contentsOf: imageURL!)
                            
                            DispatchQueue.main.async {
                                let image = Image(imageData: imageData!, locationString: title, context: delegate.stack.context)
                                imageArr.append(image)
                            }
                        }
                    
                    DispatchQueue.main.async {
                        delegate.initializeFetchedResultsController()
                        let annotationArr = delegate.fetchedResultsController.fetchedObjects as? [Annotation]
                        
                        for annotationCoreData in annotationArr! {
                            if annotationCoreData.latitude == latitude && annotationCoreData.longitude == longitude {
                                for image in imageArr {
                                    image.annotation = annotationCoreData
                                    
                                    print("Download compltete")
                                }
                            }
                        }
                        
                        do {
                            try delegate.stack.saveContext()
                        }
                        catch {
                            fatalError()
                        }
                    }

                    AddImagesCollectionViewController.downloadingImageComplete = true
                }
                else {
                    fatalError()
                }
            }
    }


}

