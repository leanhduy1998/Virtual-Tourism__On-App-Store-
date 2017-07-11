//
//  Image+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/10/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var locationString: String?
    @NSManaged public var annotation: Annotation?

}
