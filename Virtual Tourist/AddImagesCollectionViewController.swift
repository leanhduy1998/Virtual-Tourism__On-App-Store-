//
//  ImagesCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 6/30/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "AddImageCollectionCell"

class AddImagesCollectionViewController: UICollectionViewController {
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    

    var imageIndex = Int()
    var annotation = ImageAnnotation()
    private let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var imageUrlArr = [String]()
    
    private var hasImages = false
    
    var annotationCoreData = Annotation()
    
    var timer = Timer()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let latitude = Float(annotation.coordinate.latitude)
        let longitude = Float(annotation.coordinate.longitude)

        delegate.initializeFetchedResultsController()
        let annotationArr = (delegate.fetchedResultsController.fetchedObjects as? [Annotation])!
        for temp in annotationArr {
            if temp.latitude == latitude && temp.longitude == longitude {
                annotationCoreData = temp
                if (annotationCoreData.images?.count)! > 0 {
                    hasImages = true
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        
        let space = 2
        let itemSize = (Double(view.frame.width) - (Double(space) * 2))/3
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.minimumInteritemSpacing = CGFloat(space)
        flowLayout.minimumLineSpacing = CGFloat(space)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hasImages {
            return (annotationCoreData.images?.count)!
        }
        return imageUrlArr.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? AddImageCollectionViewCell
        cell?.imageView.image = nil
        
        cell?.activityIndicator.isHidden = false
        cell?.activityIndicator.startAnimating()
        
        if hasImages  {
            let imageDataArr = annotationCoreData.images?.allObjects as? [Image]
            if indexPath.row < ((annotationCoreData.images?.count)!) {
                if let imageData = imageDataArr?[indexPath.row].image {
                    cell?.imageView.image =  UIImage(data: imageData as Data)
                    cell?.activityIndicator.stopAnimating()
                }
            }
        }
        
        else {
            HttpRequest.downloadImage(imagePath: imageUrlArr[indexPath.row], completionHandler: { (imageData, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        cell?.imageView.image =  UIImage(data: imageData!)
                        cell?.activityIndicator.stopAnimating()
                        
                        let image = Image(imageData: imageData!, locationString: self.annotation.title!, context: self.delegate.stack.context)
                        image.annotation = self.annotationCoreData
                        
                        do {
                            try self.delegate.stack.saveContext()
                        }
                        catch {
                            fatalError()
                        }
                    }
                }
            })
        }
        
        return cell!
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            imageUrlArr.remove(at: indexPath.row)
            let image = annotationCoreData.images?.allObjects[indexPath.row] as? Image
            delegate.stack.context.delete(image!)
            do {
                try delegate.stack.saveContext()
            }
            catch {
                fatalError()
            }
            collectionView.reloadData()
    }
    
    @IBAction func moreOptionBtnPressed(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction(title: "Replace with new images", style: UIAlertActionStyle.default, handler: replaceWithNewImages))
        alertController.addAction(UIAlertAction(title: "Add new images", style: UIAlertActionStyle.default, handler: addNewImages))
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addNewImages(action: UIAlertAction){
        hasImages = false
        HttpRequest.downloadURLs(title: annotationCoreData.locationString!, latitude: annotationCoreData.latitude, longitude: annotationCoreData.longitude, page: Int(annotationCoreData.page!)!+1, completeHandler: {(result) in
            DispatchQueue.main.async {
                self.imageUrlArr = result
                self.collectionView?.reloadData()
            }
            
        })
    }
    
    func replaceWithNewImages(action: UIAlertAction){
        imageUrlArr.removeAll()
        for image in (annotationCoreData.images?.allObjects)! {
            delegate.stack.context.delete((image as? Image)!)
        }
        do {
            try delegate.stack.saveContext()
        }
        catch {
            fatalError()
        }
        
        collectionView?.reloadData()
        
        hasImages = false
        HttpRequest.downloadURLs(title: annotationCoreData.locationString!, latitude: annotationCoreData.latitude, longitude: annotationCoreData.longitude, page: Int(annotationCoreData.page!)!+1, completeHandler: {(result) in
            DispatchQueue.main.async {
                self.imageUrlArr = result
                self.collectionView?.reloadData()
            }
            
        })

    }
}
