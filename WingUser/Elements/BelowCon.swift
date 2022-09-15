//
//  BelowCon.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/18.
//

import UIKit

class BelowCon: UIControl {

  private var iconImageView: UIImageView!

  private var subscriptLabel: UILabel!

  private var icon: UIImage? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  private var script: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  init(
    icon: UIImage? = nil,
    subscript script: String? = nil
  ) {
    super.init(frame: .zero)

    commonInit()

    self.icon = icon
    self.script = script
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    iconImageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit
      $0.tintColor = .label
    }
    subscriptLabel = UILabel().then {
      $0.font = .systemFont(ofSize: 16)
    }

    addSubview(iconImageView)
    addSubview(subscriptLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateIconImage()
    updateSubscriptLabel()
    updatePin()
  }

  private func updateIconImage() {
    iconImageView.image = icon
  }

  private func updateSubscriptLabel() {
    subscriptLabel.text = script
  }

  private func updatePin() {
    subscriptLabel.pin.sizeToFit()
    iconImageView.pin
      .above(of: subscriptLabel, aligned: .center)
      .size(60)

    self.pin.wrapContent(padding: 5)

    invalidateIntrinsicContentSize()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()
    return intrinsicContentSize
  }

  override var intrinsicContentSize: CGSize {
    return bounds.size
  }

}
