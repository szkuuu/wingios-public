//
//  String+WSAttributed.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/05.
//

import Atributika

extension String {

  var wsAttributed: NSAttributedString {
    self
      .style(tags: WSAttributed.Family.styles + WSAttributed.Color.styles)
      .attributedString
  }

}
