//
//  StateTimeCard.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/16.
//

import UIKit

class StateTimeCard: UIView {

  private var batteryImageView: UIImageView!

  private var titleLabel: UILabel!

  private var detailLabel: UILabel!

  var upperImage: UIImage? = nil {
    didSet {
      setNeedsLayout()
    }
  }

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
    image upperImage: UIImage? = nil,
    title titleText: String? = nil,
    detail detailText: String? = nil
  ) {
    super.init(frame: .zero)

    commonInit()

    self.upperImage = upperImage
    self.titleText = titleText
    self.detailText = detailText
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    batteryImageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit
    }
    titleLabel = UILabel().then {
      $0.textColor = .systemGray
      $0.font = .systemFont(ofSize: 16)
    }
    detailLabel = UILabel().then {
      $0.font = .monospacedDigitSystemFont(ofSize: 20, weight: .regular)
    }

    addSubview(batteryImageView)
    addSubview(titleLabel)
    addSubview(detailLabel)

    layer.cornerRadius = 8.0
    layer.borderColor = UIColor.systemGray5.cgColor
    layer.borderWidth = 1
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateBatteryImageView()
    updateTitleLabel()
    updateDetailLabel()
    updatePin()
  }

  private func updateBatteryImageView() {
    batteryImageView.image = self.upperImage
  }

  private func updateTitleLabel() {
    titleLabel.text = titleText
  }

  private func updateDetailLabel() {
    detailLabel.text = detailText
  }

  private func updatePin() {
    batteryImageView.pin
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
  }

}
