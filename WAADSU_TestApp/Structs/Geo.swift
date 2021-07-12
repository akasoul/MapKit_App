//
//  Structs.swift
//  WAADSU_TestApp
//
//  Created by Anton Voloshuk on 09.07.2021.
//

import Foundation


struct Geo: Codable{
    var type: String
    var features: [Feature]
}

struct Geometry: Codable{
    var coordinates: [[[[Double]]]]
}

struct Feature: Codable{
    var geometry: Geometry
}
