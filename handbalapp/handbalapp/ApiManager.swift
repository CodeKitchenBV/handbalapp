//
//  ApiManager.swift
//  handbalapp
//
//  Created by Marko Heijnen on 2/2/17.
//  Copyright © 2017 CodeKitchen B.V. All rights reserved.
//

import Foundation
import Moya

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

let HandbalProvider = MoyaProvider<HandbalService>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])


enum HandbalService {
    case getNews
}

extension HandbalService: TargetType {
    var baseURL: URL { return URL(string: "https://api.handbal.org")! }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
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
