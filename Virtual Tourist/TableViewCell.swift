//
//  TableViewCell.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/2/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
 


    @IBOutlet var imageV: UIImageView!

    @IBOutlet var locationLabel: UILabel!

    @IBOutlet var numberOfPicsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
