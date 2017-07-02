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
    var annotationTitle = String()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let imageData = try? Data(contentsOf: imageURL!) {
            imageView.image = UIImage(data: imageData)
        }
    }
    @IBAction func addToCollectionBtnPressed(_ sender: Any) {
        //MapViewController.annotationsDic[annotationTitle]?.imageName =
        navigationController?.popToRootViewController(animated: true)
    }
}
