//
//  Cities+CoreDataProperties.swift
//  Weather
//
//  Created by Vitalii Havryliuk on 7/11/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//
//

import Foundation
import CoreData


extension Cities {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cities> {
        return NSFetchRequest<Cities>(entityName: "Cities")
    }

    @NSManaged public var id: String

}
