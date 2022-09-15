//
//  UserStore.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/23.
//

class UserStore: Object {

  @Persisted var token: String = ""

  @Persisted var identifier: String = ""

}
