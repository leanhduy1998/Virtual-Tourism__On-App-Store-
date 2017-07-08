//
//  ShowImageDetailViewController.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/7/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class ShowImageDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var imageData = Data()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = UIImage(data: imageData)
    }


}
