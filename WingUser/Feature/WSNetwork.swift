//
//  WSNetwork.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/22.
//

import Moya

enum WSNetwork {

  static fileprivate let privateKey: String = WSSecret.wingstationPrivateKey

  /// AppDelegate 에서 로그인 시도
  case login(token: String, identifier: String)

  /// 스테이션 검색
  case getMain(minLat: Double,
               minLong: Double,
               maxLat: Double,
               maxLong: Double,
               type: WSPortTypeIdentifier? = nil)

  /// 스테이션 설치 요청
  case requestStationInstall(token: String,
                             latitude: Double,
                             longitude: Double,
                             address: String)

  /// 스테이션 정보와 충전 정보 제공
  case portList(stationId: String)

  /// 인증번호 보내기
  case loginGetCert(phone: String)

  /// 로그인 요청
  case loginNew(phone: String, identifier: String)

  /// 회원 가입
  case loginJoin(identifier: String,
                 phone: String,
                 lastName: String,
                 firstName: String,
                 email: String,
                 portType: WSPortTypeIdentifier?,
                 portVoltage: Double?,
                 portAmpere: Double?)

  ///카드 등록
  case cardNew(token: String, cardNumber: String, validMonth: String, validYear: String, password: String)

  /// 사용자 사용 가능 여부
  case chargeUserCheck(token: String)

  /// 스테이션 정보 조회
  case chargeStationCheck(stationId: String)

  /// 스테이션 충전 조회
  case chargeStatus(token: String)

  /// 결제 시작
  case chargePayment(token: String, price: Int)

  /// 개인 정보 받아오기
  case getMyInfo(token: String)

  /// 충전정보 변경
  case userInfoChargeSpec(token: String, portType: WSPortTypeIdentifier?, portVoltage: Double?, portAmpere: Double?)

  /// 공지사항 리스트 불러오기
  case noticeGetList(page: Int = 1, noticeType: WSNoticeTypeIdentifier)

  /// 공지사항 내용 불러오기
  case noticeGetDetail(id: Int)

}

extension WSNetwork: TargetType {

  var baseURL: URL {
    if let url = URL(string: "https://api.wingstation.co.kr") {
      return url
    } else {
      return URL(fileURLWithPath: "/")
    }
  }

  var path: String = WSSecret.getPath(networkApplication: self)

  var method: Moya.Method {
    switch self {
    case .login:
      return .post
    case .getMain:
      return .get
    case .requestStationInstall:
      return .post
    case .portList:
      return .get
    case .loginGetCert:
      return .post
    case .loginNew:
      return .post
    case .loginJoin:
      return .post
    case .cardNew:
      return .post
    case .chargeUserCheck:
      return .get
    case .chargeStationCheck:
      return .get
    case .chargeStatus:
      return .get
    case .chargePayment:
      return .post
    case .getMyInfo:
      return .get
    case .userInfoChargeSpec:
      return .post
    case .noticeGetList:
      return .get
    case .noticeGetDetail:
      return .get
    }
  }

  var task: Task {
    switch self {
    case .login(let token, let identifier):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "token": token,
                                             "identifier": identifier
                                            ], encoding: URLEncoding.default)
    case .getMain(let minLat, let minLong, let maxLat, let maxLong, let type):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "min_lat": minLat,
                                             "min_long": minLong,
                                             "max_lat": maxLat,
                                             "max_long": maxLong,
                                             "type": type?.rawValue ?? "null"
                                            ], encoding: URLEncoding.default)

    case .requestStationInstall(let token, let latitude, let longitude, let address):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "token": token,
                                             "lat": latitude,
                                             "lng": longitude,
                                             "address": address], encoding: URLEncoding.default)
      
    case .portList(let stationId):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "station_id": stationId
                                            ], encoding: URLEncoding.default)
    case .loginGetCert(let phone):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "phone": phone
                                            ], encoding: URLEncoding.default)
    case .loginNew(let phone, let identifier):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "phone": phone,
                                             "identifier": identifier
                                            ], encoding: URLEncoding.default)
    case .loginJoin(let identifier,
                    let phone,
                    let lastName,
                    let firstName,
                    let email,
                    let portType,
                    let portVoltage,
                    let portAmpere):
      return .requestParameters(parameters: ["api_key": WSNetwork.privateKey,
                                             "identifier": identifier,
                                             "phone": phone,
                                             "last_name": lastName,
                                             "first_name": firstName,
                                             "email": email,
                                             "marketing": 0,
                                             "port_type": (portType?.rawValue) ?? "null",
                                             "port_voltage": portVoltage ?? "null",
                                             "port_ampere": portAmpere ?? "null"
                                            ], encoding: URLEncoding.default)
    case .cardNew(let token, let cardNumber, let validMonth, let validYear, let password):
      return .requestParameters(parameters: ["token": token,
                                             "numb": cardNumber,
                                             "month": validMonth,
                                             "year": validYear,
                                             "password": password
                                            ], encoding: URLEncoding.default)
    case .chargeUserCheck(let token):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "token": token
                                            ], encoding: URLEncoding.default)
    case .chargeStationCheck(let stationId):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "port": stationId
                                            ], encoding: URLEncoding.default)
    case .chargeStatus(let token):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "token": token
                                            ], encoding: URLEncoding.default)
    case .chargePayment(let token, let price):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "user_token": token,
                                             "price": price
                                            ], encoding: URLEncoding.default)
    case .getMyInfo(let token):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "token": token
                                            ], encoding: URLEncoding.default)
    case .userInfoChargeSpec(let token, let portType, let portVoltage, let portAmpere):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "token": token,
                                             "port_type": (portType?.rawValue) ?? "null",
                                             "port_voltage": portVoltage ?? "null",
                                             "port_ampere": portAmpere ?? "null"
                                            ], encoding: URLEncoding.default)
    case .noticeGetList(let page, let noticeType):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "page": page,
                                             "type": noticeType.rawValue
                                            ], encoding: URLEncoding.default)
    case .noticeGetDetail(let id):
      return .requestParameters(parameters: ["key": WSNetwork.privateKey,
                                             "id": id], encoding: URLEncoding.default)
    }
  }

  var headers: [String: String]? {
    nil
  }

}

extension WSNetwork {

  static func request(target: Self, _ completionHandler: @escaping (Result<SwiftyJSON.JSON, Moya.MoyaError>) -> Void) {
    MoyaProvider<WSNetwork>().request(target) {
      switch $0 {
      case .success(let response):
        completionHandler(.success(JSON(response.data)))
      case .failure(let error):
        completionHandler(.failure(error))
      }
    }
  }

}
