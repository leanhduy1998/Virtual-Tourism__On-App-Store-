//
//  Annotation+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/10/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import CoreData


extension Annotation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Annotation> {
        return NSFetchRequest<Annotation>(entityName: "Annotation")
    }

    @NSManaged public var latitude: Float
    @NSManaged public var locationString: String?
    @NSManaged public var longitude: Float
    @NSManaged public var page: String?
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for images
extension Annotation {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Image)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Image)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}
