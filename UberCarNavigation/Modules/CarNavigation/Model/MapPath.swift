//
//  MapPath.swift
//  UberCarNavigation
//
//  Created by Muhammad Usman on 10/05/2021.
//  
//

import Foundation

struct MapPath : Codable{
    var routes : [Route]?
}

struct Route : Codable{
    var overview_polyline : OverView?
    var legs: [Legs]?
}

struct Legs: Codable{
    var distance: Distance?
    var duration: Duration?
}

struct Distance: Codable {
    var value: Int?
    var text: String?
}

struct Duration: Codable {
    var value: Int?
    var text: String?
}

struct OverView : Codable {
    var points : String?
}

struct MapCoordinate {
    let latitude: Double
    let longitude: Double
}
