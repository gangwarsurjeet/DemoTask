//
//  RequestManager.swift
//  FortuneToken
//
//  Created by Vishwajeet on 5/22/21.
//

import Foundation

public struct RequestKey {
    // declare all key which is used for api request
    static let query = "q"
    
    static let breedId = "breed_id"
    static let pageNum = "page"
    static let limit = "limit"
    
}


public let baseURL = "https://api.thedogapi.com/v1/"

public struct API {
    static let searchBreeds       = baseURL + "breeds/search"
    static let fetchImages        =  baseURL + "images/search"
}

class RequestManager {
    
    static func searchBreeds(_ searchText: String) -> [String: Any] {
        return [RequestKey.query: searchText]
    }
    
    static func fetchImages(_ breedId: String, pageNum: Int, limit: Int) -> [String: Any] {
        return [RequestKey.pageNum: pageNum,
                RequestKey.limit: limit,
                RequestKey.breedId: breedId]
    }
}
