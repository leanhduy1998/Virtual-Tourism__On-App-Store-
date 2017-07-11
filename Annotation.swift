//
//  Annotation+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/2/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import CoreData

@objc(Annotation)
public class Annotation: NSManagedObject {
    convenience init(locationString: String, latitude: Float, longitude: Float, page: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Annotation", in: context){
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.locationString = locationString
            self.page = page
            
        }
        else {
            fatalError("unable to find Annotation Entity name")
        }
    }
}
