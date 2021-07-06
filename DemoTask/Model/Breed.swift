//
//  Breed.swift
//  DemoTask
//
//  Created by Surjeet on 06/07/21.
//

import UIKit

struct Breed: Codable {

    var id: Int?
    var bredFor: String?
    var breedGroup: String?
    var lifeSpan: String?
    var name: String?
    var referenceImageID: String?
    var temperament: String?
    var height: BodyMetrix?
    var weight: BodyMetrix?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case bredFor = "bred_for"
        case breedGroup = "breed_group"
        case lifeSpan = "life_span"
        case referenceImageID = "reference_image_id"
        case temperament, height, weight
    }
}

struct BodyMetrix: Codable {
    var imperial: String?
    var metric: String?
}
