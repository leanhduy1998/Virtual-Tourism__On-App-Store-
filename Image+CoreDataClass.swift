//
//  Image+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/2/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {
    convenience init(imageURL: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Image", in: context){
            self.init(entity: ent, insertInto: context)
            self.imageURL = imageURL
        }
        else {
            fatalError("unable to find Image Entity name")
        }
    }
}
