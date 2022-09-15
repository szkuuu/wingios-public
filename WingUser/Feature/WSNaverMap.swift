//
//  WSNaverMap.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/13.
//

import Moya

enum WSNaverMap {

  static fileprivate let apiKeyId = WSSecret.naverMapApiKeyId

  static fileprivate let apiKey = WSSecret.naverMapApiKey

  /// Reverse Geocoding; 위경도 -> 도로명주소
  case rgc(lat: Double, long: Double)

}

extension WSNaverMap: TargetType {
  var baseURL: URL {
    if let url = URL(string: WSSecret.naverMapApiUrlString) {
      return url
    } else {
      return URL(fileURLWithPath: "/")
    }
  }

  var path: String {
    switch self {
    case .rgc:
      return WSSecret.naverMapApiRgcPathString
    }
  }

  var method: Moya.Method {
    switch self {
    case .rgc:
      return .get
    }
  }

  var task: Task {
    switch self {
    case .rgc(let latitude, let longitude):
      return .requestParameters(parameters: ["coords": "\(longitude),\(latitude)",
                                             "output": "json",
                                             "orders": "addr,roadaddr"
                                            ], encoding: URLEncoding.default)
    }
  }

  var headers: [String: String]? {
    switch self {
    case .rgc:
      return [
        "X-NCP-APIGW-API-KEY-ID": WSNaverMap.apiKeyId,
        "X-NCP-APIGW-API-KEY": WSNaverMap.apiKey,
      ]
    }
  }


}

extension WSNaverMap {

  static func request(target: Self, _ completionHandler: @escaping (Result<SwiftyJSON.JSON, Moya.MoyaError>) -> Void) {
    MoyaProvider<WSNaverMap>().request(target) {
      switch $0 {
      case .success(let response):
        completionHandler(.success(JSON(response.data)))
      case .failure(let error):
        completionHandler(.failure(error))
      }
    }
  }

}
