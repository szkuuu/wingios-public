//
//  WSAttributed.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/05.
//

import Atributika

enum WSAttributed {

  enum Family: CaseIterable {

    case s24

    case s22

    case s20

    case s18

    case s16

    case s14

    case s24b

    case s22b

    case s20b

    case s18b

    case s16b

    case s14b

    case s10b

    case s24mn

    case s22mn

    case s20mn

    case s18mn

    case s16mn

    case s14mn

  }

  enum Color: CaseIterable {

    case yellow

    case orange

    case gray1

    case gray2

    case gray3

    case gray4

    case gray5

    case gray6

    case white

    case black

  }

}

extension WSAttributed.Family {

  static let styles: [Style] = {
    var result: [Style] = []

    Self.allCases.forEach { familyOption in
      let font: UIFont

      switch familyOption {
      case .s24:
        font = .systemFont(ofSize: 24)
      case .s22:
        font = .systemFont(ofSize: 22)
      case .s20:
        font = .systemFont(ofSize: 20)
      case .s18:
        font = .systemFont(ofSize: 18)
      case .s16:
        font = .systemFont(ofSize: 16)
      case .s14:
        font = .systemFont(ofSize: 14)
      case .s24b:
        font = .systemFont(ofSize: 24, weight: .bold)
      case .s22b:
        font = .systemFont(ofSize: 22, weight: .bold)
      case .s20b:
        font = .systemFont(ofSize: 20, weight: .bold)
      case .s18b:
        font = .systemFont(ofSize: 18, weight: .semibold)
      case .s16b:
        font = .systemFont(ofSize: 16, weight: .semibold)
      case .s14b:
        font = .systemFont(ofSize: 14, weight: .semibold)
      case .s10b:
        font = .systemFont(ofSize: 10, weight: .semibold)
      case .s24mn:
        font = .monospacedSystemFont(ofSize: 24, weight: .regular)
      case .s22mn:
        font = .monospacedSystemFont(ofSize: 22, weight: .regular)
      case .s20mn:
        font = .monospacedSystemFont(ofSize: 20, weight: .regular)
      case .s18mn:
        font = .monospacedSystemFont(ofSize: 18, weight: .regular)
      case .s16mn:
        font = .monospacedSystemFont(ofSize: 16, weight: .regular)
      case .s14mn:
        font = .monospacedSystemFont(ofSize: 14, weight: .regular)
      }

      result.append(Style("\(familyOption)").font(font))
    }

    return result
  }()

}

extension WSAttributed.Color {

  static let styles: [Style] = {
    var result: [Style] = []

    Self.allCases.forEach { colorOption in
      let color: UIColor

      switch colorOption {
      case .yellow:
        color = .systemYellow
      case .orange:
        color = .systemOrange
      case .gray1:
        color = .systemGray
      case .gray2:
        color = .systemGray2
      case .gray3:
        color = .systemGray3
      case .gray4:
        color = .systemGray4
      case .gray5:
        color = .systemGray5
      case .gray6:
        color = .systemGray6
      case .white:
        color = .white
      case .black:
        color = .black
      }

      result.append(Style("\(colorOption)").foregroundColor(color))
    }
    
    return result
  }()

}
