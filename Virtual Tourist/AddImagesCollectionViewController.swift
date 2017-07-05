//
//  ImagesCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 6/30/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class AddImagesCollectionViewController: UICollectionViewController {
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var imageUrlArr = [String]()
    var imageIndex = Int()
    var annotation = ImageAnnotation()

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrlArr.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell
        
        let imageURL = URL(string: imageUrlArr[indexPath.row])
        if let imageData = try? Data(contentsOf: imageURL!) {
            cell?.imageView.image =  UIImage(data: imageData)
        }
        
        return cell!
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageIndex = indexPath.row
        performSegue(withIdentifier: "ImageDetailViewController", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ImageDetailViewController {
            let imageURL = URL(string: imageUrlArr[imageIndex])
            destination.imageURL = imageURL
            destination.annotation = annotation
        }
        
    }
}
