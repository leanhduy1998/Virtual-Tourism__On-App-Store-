//
//  ImagesCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 6/30/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

private let reuseIdentifier = "AddImageCollectionCell"

class AddImagesCollectionViewController: UICollectionViewController {
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var imageUrlArr = [String]()
    var imageIndex = Int()
    var annotation = ImageAnnotation()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        
    }
    func loadData(){
        let latitude = Float(annotation.coordinate.latitude)
        let longitude = Float(annotation.coordinate.longitude)
        
        let request = NSMutableURLRequest(url: FlickrClient.searchImage(latitude: latitude, longitude: longitude))
        let session = URLSession.shared
        
        let task = session.dataTask(with: (request as? URLRequest)!, completionHandler: { (data, respond, error) in
            if error == nil {
                var parsedData: [String:AnyObject] = [:]
                do {
                    try parsedData = (JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject])!
                }
                catch {
                    print("parse data err")
                    print(error.localizedDescription)
                }
                guard let photos = parsedData["photos"] as? [String:AnyObject] else {
                    print("photos err")
                    return
                }
                guard let photoArr = photos["photo"] as? [[String:AnyObject]] else {
                    print("photoArr err")
                    return
                }
                
                for photo in photoArr {
                    guard let url = photo["url_m"] as? String else {
                        print("url err")
                        return
                    }
                    self.imageUrlArr.append(url)
                }
                
                self.collectionView?.reloadData()
            }
            else {
                print("task err")
            }
        })
        task.resume()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrlArr.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? AddImageCollectionViewCell
        
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
        if let destination = segue.destination as? AddImageDetailViewController {
            let imageURL = URL(string: imageUrlArr[imageIndex])
            destination.imageURL = imageURL
            destination.annotation = annotation
        }
        
    }
}
