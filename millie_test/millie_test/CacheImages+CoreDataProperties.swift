//
//  CacheImages+CoreDataProperties.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/19.
//
//

import Foundation
import CoreData


extension CacheImages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CacheImages> {
        return NSFetchRequest<CacheImages>(entityName: "CacheImages")
    }

    @NSManaged public var image: Data?
    @NSManaged public var url: String?

}

extension CacheImages : Identifiable {

}
