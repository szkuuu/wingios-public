//
//  WSAnnotation.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/25.
//

import MapKit

class WSAnnotation: MKPointAnnotation {

  var property: WSStructure.MarkerProperty

  init(property: WSStructure.MarkerProperty,
       subtitle: String? = nil) {
    self.property = property

    super.init()

    self.coordinate = property.coordinate
    self.title = property.name
    self.subtitle = subtitle
  }

}
