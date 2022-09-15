//
//  StateChargeCard.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/16.
//

import UIKit

class StateChargeCard: UIView {

  var upperCircle: CircleTemplate!

  private var titleLabel: UILabel!

  private var detailLabel: UILabel!

  var titleText: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var detailText: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  init(
    circle upperCircle: () -> CircleTemplate,
    title titleText: String? = nil,
    detail detailText: String? = nil
  ) {
    self.upperCircle = upperCircle()
    super.init(frame: .zero)

    commonInit()

    self.titleText = titleText
    self.detailText = detailText
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    titleLabel = UILabel().then {
      $0.textColor = .systemGray
      $0.font = .systemFont(ofSize: 16)
    }
    detailLabel = UILabel().then {
      $0.font = .systemFont(ofSize: 16)
    }

    addSubview(upperCircle)
    addSubview(titleLabel)
    addSubview(detailLabel)

    layer.cornerRadius = 8.0
    layer.borderColor = UIColor.systemGray5.cgColor
    layer.borderWidth = 1
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateTitleLabel()
    updateDetailLabel()
    updatePin()
  }

  private func updateTitleLabel() {
    titleLabel.text = titleText
  }

  private func updateDetailLabel() {
    detailLabel.text = detailText
  }

  private func updatePin() {
    upperCircle.pin
      .topCenter()
      .height(42.86%)
      .marginTop(12%)
      .sizeToFit(.height)
    detailLabel.pin
      .bottomCenter()
      .marginBottom(12%)
      .sizeToFit()
    titleLabel.pin
      .above(of: detailLabel, aligned: .center)
      .marginBottom(3)
      .sizeToFit()
//    upperCircle.pin.width(upperCircle.bounds.height)
  }
  
}
