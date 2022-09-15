//
//  Bool+IntValue.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/02.
//

extension Bool {

  /// 참이면 `Int(1)`, 거짓이면 `Int(0)`으로 변환합니다.
  var asInt: Int {
    return self ? 1 : 0
  }

}
