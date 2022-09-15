//
//  Array+ElementRepeat.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/09.
//

extension Array {

  public init(count: Int, element creator: @autoclosure () -> Element) {
    self = (0 ..< count).map { _ in creator() }
  }

}
