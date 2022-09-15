//
//  UserCache.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/30.
//

struct UserCache {

  let lastName: String
  let firstName: String
  let phoneNumber: String
  let email: String
  let marketing: Bool
  let portType: WSPortTypeIdentifier
  let portVoltage: Double
  let portAmpere: Double

  init(lastName: String = "",
       firstName: String = "",
       phoneNumber: String = "",
       email: String = "",
       marketing: Bool = false,
       portType: WSPortTypeIdentifier = .none,
       portVoltage: Double = 0.0,
       portAmpere: Double = 0.0) {
    self.lastName = lastName
    self.firstName = firstName
    self.phoneNumber = phoneNumber
    self.email = email
    self.marketing = marketing
    self.portType = portType
    self.portVoltage = portVoltage
    self.portAmpere = portAmpere
  }

  func move(lastName: String? = nil,
            firstName: String? = nil,
            phoneNumber: String? = nil,
            email: String? = nil,
            marketing: Bool? = nil,
            portType: WSPortTypeIdentifier? = nil,
            portVoltage: Double? = nil,
            portAmpere: Double? = nil) -> UserCache {
    UserCache(lastName: lastName ?? self.lastName,
              firstName: firstName ?? self.firstName,
              phoneNumber: phoneNumber ?? self.phoneNumber,
              email: email ?? self.email,
              marketing: marketing ?? self.marketing,
              portType: portType ?? self.portType,
              portVoltage: portVoltage ?? self.portVoltage,
              portAmpere: portAmpere ?? self.portAmpere)
  }

}
