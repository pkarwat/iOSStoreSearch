//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Patryk on 04.12.2016.
//  Copyright © 2016 Patryk. All rights reserved.
//

import Foundation

class SearchResult {
    
    var name = ""
    var artistName = ""
    var artworkSmallURL = ""
    var artworkLargeURL = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
