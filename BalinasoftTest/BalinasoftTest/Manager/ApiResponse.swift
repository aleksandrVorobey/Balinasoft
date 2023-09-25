//
//  ApiResponse.swift
//  BalinasoftTest
//
//  Created by admin on 24.09.2023.
//

import Foundation

enum Path: String {
    case post = "/api/v2/photo"
    case get = "/api/v2/photo/type"
}

struct URLFactory {
    static func url(paramPage: Int = 0, path: Path.RawValue) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "junior.balinasoft.com"
        components.path = path
        components.queryItems = [URLQueryItem(name: "page", value: "\(paramPage)")]
        return components.url!
    }
}
