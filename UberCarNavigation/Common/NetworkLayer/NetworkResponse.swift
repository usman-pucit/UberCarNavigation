//
//  NetworkResponse.swift
//  TemplateApp
//
//  Created by Muhammad Usman on 05/02/2021.
//

import Foundation

struct NetworkResponse<Wrapped: Decodable>: Decodable {
    var result: Wrapped?
    
    // MARK: - Model Keys
    enum CodingKeys: String, CodingKey{
        case result
    }
    
    // MARK: - Model mapping
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent(Wrapped.self, forKey: .result)
    }
}
