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
    
    
    
    
    
    
    
    var imageDataArr = [Data]()
    var imageIndex = Int()
    var annotation = ImageAnnotation()
    static var downloadingImageComplete = true
    private let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var annotationCoreData : Annotation! = nil
    
    var timer = Timer()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.hidesBackButton = true
        fireTimerCheckingDownloadStatus()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
    }
    
    private func fireTimerCheckingDownloadStatus(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AddImagesCollectionViewController.checkingImageDownload),userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func checkingImageDownload() {
        let latitude = Float(annotation.coordinate.latitude)
        let longitude = Float(annotation.coordinate.longitude)
        
        if AddImagesCollectionViewController.downloadingImageComplete {
            navigationItem.hidesBackButton = false
            let annotationArr = (delegate.fetchedResultsController.fetchedObjects as? [Annotation])!
            for temp in annotationArr {
                if temp.latitude == latitude && temp.longitude == longitude {
                    if((temp.images?.count)! > 0 ){
                        annotationCoreData = temp
                        collectionView?.reloadData()
                        timer.invalidate()
                    }
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !AddImagesCollectionViewController.downloadingImageComplete {
            return 30
        }
        
        if annotationCoreData != nil {
            return (annotationCoreData.images?.count)!
        }
        
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? AddImageCollectionViewCell
        

       if AddImagesCollectionViewController.downloadingImageComplete {
            if annotationCoreData != nil {
                let imageDataArr = annotationCoreData.images?.allObjects as? [Image]
                if let imageData = imageDataArr?[indexPath.row].image {
                    cell?.imageView.image =  UIImage(data: imageData as Data)
                }
            }
        }
        return cell!
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        CoreDataDownloadImage.downloadURLs(title: annotationCoreData.locationString!, latitude: annotationCoreData.latitude, longitude: annotationCoreData.longitude, page: Int(annotationCoreData.page!)!+1)
        AddImagesCollectionViewController.downloadingImageComplete = false
        
        fireTimerCheckingDownloadStatus()
    }
    
    func replaceWithNewImages(action: UIAlertAction){
        for image in (annotationCoreData.images?.allObjects)! {
            delegate.stack.context.delete((image as? Image)!)
        }
        do {
            try delegate.stack.saveContext()
        }
        catch {
            fatalError()
        }
        CoreDataDownloadImage.downloadURLs(title: annotationCoreData.locationString!, latitude: annotationCoreData.latitude, longitude: annotationCoreData.longitude, page: Int(annotationCoreData.page!)!+1)
        AddImagesCollectionViewController.downloadingImageComplete = false
        
        fireTimerCheckingDownloadStatus()
    }
}
