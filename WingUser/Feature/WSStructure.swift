//
//  WSStructure.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/25.
//

import MapKit

enum WSStructure {

  struct MarkerProperty {

    var address: String?
    var stationId: Int
    var available: Bool
    var name: String
    var coordinate: CLLocationCoordinate2D

  }

  struct PortStateProperty {

    var portId: Int // Unique
    var portNumber: Int
    var type: WSPortTypeIdentifier
    var state: Int
    
  }

  struct MyPageProperty {

    var lastName: String
    var firstName: String
    var cardInfo: String?
    var email: String
    var type: WSPortTypeIdentifier
    var ampere: Double?
    var voltage: Double?

  }

  struct NoticeContentProperty {

    var title: String
    var date: Date
    var content: String
    var pictureURL: URL?

  }

  struct StationInformationProperty {

    var portId: Int
    var stationId: Int
    var stationCode: String
    var portNumber: Int
    var stationName: String
    var identifier: String

  }

  struct UsageProperty {

    var id: Int
    var userType: Int
    var userId: Int
    var stationId: Int
    var stationName: String
    var stationAddress: String
    var portId: Int
    var code: Int
    var date: Date?
    var start: Date?
    var chargeComplete: Date?
    var end: Date?
    var kickboard: Int?
    var status: Int

  }

  struct BillProperty {

    var stationName: String
    var port: Int
    var startTime: Date
    var endTime: Date
    var standardVoltage: Int
    var amount: CGFloat

  }

}
