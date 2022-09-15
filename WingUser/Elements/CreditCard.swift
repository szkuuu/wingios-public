//
//  CreditCard.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/09.
//

import UIKit

class CreditCard: UIView {

  enum Condition {

    case disabled

    case enabled

  }

  struct Appearance {

    let backgroundColor: CGColor

    let shadowColor: CGColor

    let nameLabelColor: UIColor

    let numberLabelColor: UIColor

    let dateLabelColor: UIColor

    init(backgroundColor: UIColor, shadowColor: UIColor, nameColor: UIColor, numberColor: UIColor, dateColor: UIColor) {
      self.backgroundColor = backgroundColor.cgColor
      self.shadowColor = shadowColor.cgColor
      self.nameLabelColor = nameColor
      self.numberLabelColor = numberColor
      self.dateLabelColor = dateColor
    }

  }

  private var chipImageView: UIImageView!

  private var nameLabel: UILabel!

  private var numberLabel: UILabel!

  private var dateLabel: UILabel!

  private var condition: CreditCard.Condition? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var name: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  private var number: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  private var date: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    commonInit()
    setCondition(self.condition ?? .disabled)
    setName(self.name ?? "John")
    setNumber(self.number ?? "0000 0000 0000 0000")
    setDate(self.date ?? "MM/YY")
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  func setCondition(_ condition: CreditCard.Condition) {
    self.condition = condition
  }

  func setName(_ name: String) {
    self.name = name
  }

  func setNumber(_ cardNumber: String) {
    self.number = cardNumber
  }

  func setDate(_ date: String) {
    self.date = date
  }

  private func commonInit() {
    chipImageView = UIImageView(image: .init(named: "icchip")).then {
      $0.contentMode = .scaleAspectFill
    }
    nameLabel = UILabel()
    numberLabel = UILabel()
    dateLabel = UILabel()

    addSubview(chipImageView)
    addSubview(nameLabel)
    addSubview(numberLabel)
    addSubview(dateLabel)

    layer.cornerRadius = 8.0
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateContentView()
    updateLabelView()
    updatePin()
  }

  private func updateContentView() {
    layer.backgroundColor = condition?.appearance().backgroundColor
    layer.shadowOffset = .init(width: 0, height: 10)
    layer.shadowRadius = 20
    layer.shadowColor = condition?.appearance().shadowColor
    layer.shadowOpacity = 0.4
  }

  private func updateLabelView() {
    updateNameLabel()
    updateNumberLabel()
    updateDateLabel()
  }

  private func updateNameLabel() {
    guard let name = name else {
      return
    }
    nameLabel.textColor = condition?.appearance().nameLabelColor
    nameLabel.attributedText = "<s16><s16b>\(name)</s16b> 님의 카드</s16>".wsAttributed
  }

  private func updateNumberLabel() {
    guard let number = number else {
      return
    }
    numberLabel.textColor = condition?.appearance().numberLabelColor
    numberLabel.attributedText = "<s16mn>\(number)</s16mn>".wsAttributed
  }

  private func updateDateLabel() {
    guard let date = date else {
      return
    }
    dateLabel.textColor = condition?.appearance().dateLabelColor
    dateLabel.attributedText = "<s16mn>\(date)</s16mn>".wsAttributed
  }

  private func updatePin() {
    chipImageView.pin.centerStart(25).sizeToFit()
    numberLabel.pin.start(25).bottom(20).sizeToFit()
    nameLabel.pin.above(of: numberLabel, aligned: .start).marginBottom(4).sizeToFit()
    dateLabel.pin.end(25).bottom(20).sizeToFit()
  }

}

extension CreditCard.Condition {

  func appearance() -> CreditCard.Appearance {
    switch self {
    case .enabled:
      return .init(backgroundColor: .systemYellow, shadowColor: .systemYellow, nameColor: .black, numberColor: .black, dateColor: .black)
    case .disabled:
      return .init(backgroundColor: .init(displayP3Red: 0.2, green: 0.2, blue: 0.2, alpha: 1), shadowColor: .clear, nameColor: .white, numberColor: .init(displayP3Red: 0.46667, green: 0.46667, blue: 0.46667, alpha: 1), dateColor: .init(displayP3Red: 0.46667, green: 0.46667, blue: 0.46667, alpha: 1))
    }
  }

}
