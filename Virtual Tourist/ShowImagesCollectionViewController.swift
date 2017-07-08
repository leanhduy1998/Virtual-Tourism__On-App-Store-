//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ShowImageCollectionCell"


class ShowImagesCollectionViewController: UICollectionViewController {
    private let delegate = UIApplication.shared.delegate as? AppDelegate
    
    var annotationForDeleting = Annotation()
    var imageDataArr = [Data]()
    private var indexPathForEdit: IndexPath!
    private var imageDataForSegue = Data()
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let space = 2 
        let itemSize = (Double(view.frame.width) - (Double(space) * 2))/3
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.minimumInteritemSpacing = CGFloat(space)
        flowLayout.minimumLineSpacing = CGFloat(space)
        
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        view.addGestureRecognizer(longPressRecognizer)
    }
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.collectionView)
            if let indexPath = self.collectionView?.indexPathForItem(at: touchPoint){
                onLongPressed(indexPath: indexPath)
            }
        }
    }
    private func onLongPressed(indexPath: IndexPath){
        indexPathForEdit = indexPath
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete Picture", style: UIAlertActionStyle.default, handler: deletePicture))
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    private func deletePicture(action: UIAlertAction){
        if (annotationForDeleting.images?.allObjects.count)! > 1 {
            let imageForDelete = annotationForDeleting.images?.allObjects[indexPathForEdit.row] as? Image
            
            annotationForDeleting.removeFromImages(imageForDelete!)
            
            do {
                try delegate?.stack.saveContext()
            }
            catch ((let error)){
                fatalError(error.localizedDescription)
            }
        }
        else {
            let alertController = UIAlertController(title: "Cannot delete photo", message: "You need one picture to keep this location", preferredStyle: UIAlertControllerStyle.actionSheet)
            alertController.addAction(UIAlertAction(title: "Delete Location", style: UIAlertActionStyle.default, handler: deleteLocation))
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        
    }
    private func deleteLocation(action: UIAlertAction){
        delegate?.stack.context.delete(annotationForDeleting)
        do {
            try delegate?.stack.saveContext()
        }
        catch ((let error)){
            fatalError(error.localizedDescription)
        }
        collectionView?.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDataArr.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ShowImagesCollectionViewCell
        cell?.imageView.image = UIImage(data: imageDataArr[indexPath.row])

        return cell!
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageDataForSegue = imageDataArr[indexPath.row]
        performSegue(withIdentifier: "ShowImageDetailViewController", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination =  segue.destination as? ShowImageDetailViewController {
            destination.imageData = imageDataForSegue
        }
    }

}
