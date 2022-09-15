//
//  WSConst.swift
//  WingUser
//
//  Created by 차상호 on 2022/01/05.
//

public enum WSConst {

  public static let voltageLimit: Double = 54.6

  public static let ampereLimit: Double = 5.0

  public static let compabilityAddress = URL(string: WSSecret.compabilityNotionUrlString)!

  public enum WarningCategory {

    case voltage

    case ampere

  }

}
