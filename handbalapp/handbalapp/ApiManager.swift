//
//  ApiManager.swift
//  handbalapp
//
//  Created by Marko Heijnen on 2/2/17.
//  Copyright © 2017 CodeKitchen B.V. All rights reserved.
//

import Foundation
import Moya

let HandbalProvider = MoyaProvider<HandbalService>()

enum HandbalService {
    case getClubs
    case getNews
}

extension HandbalService: TargetType {
    var baseURL: URL { return URL(string: "https://api.handbal.org")! }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
            case .getClubs:
                return "/clubs"
            case .getNews:
                return "/news"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var parameters: [String: Any]? {
        switch self {
            default:
                return nil
        }
    }

    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    public var task: Task {
        return .request
    }

    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }

}
