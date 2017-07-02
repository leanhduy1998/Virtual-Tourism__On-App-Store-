//
//  Annotation+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/2/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import CoreData


extension Annotation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Annotation> {
        return NSFetchRequest<Annotation>(entityName: "Annotation")
    }

    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var image: Image?

}
