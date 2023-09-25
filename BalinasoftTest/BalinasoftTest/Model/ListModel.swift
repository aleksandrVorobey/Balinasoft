//
//  ListModel.swift
//  BalinasoftTest
//
//  Created by admin on 24.09.2023.
//

import Foundation

struct ListModel: Codable {
    let totalPages: Int
    let content: [Content]
}
struct Content: Codable {
    let id: Int
    let name: String
    let image: String?
}

struct ContentDTO: Codable {
    let id: Int
    let name: String
    let image: Data?
}
