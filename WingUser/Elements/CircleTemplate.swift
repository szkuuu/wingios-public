//
//  CircleTemplate.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/16.
//

import UIKit

class CircleTemplate: UIView {

  private var backgroundImageView: UIImageView!

  private var subscriptLabel: UILabel!

  var backgroundImage: UIImage? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var backgroundTintColor: UIColor? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var `subscript`: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  init(
    background image: UIImage? = nil,
    tintColor color: UIColor? = .systemGray4,
    text: String? = nil
  ) {
    super.init(frame: .zero)

    commonInit()
    self.backgroundImage = image
    self.backgroundTintColor = color
    self.subscript = text
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    backgroundImageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit
    }
    subscriptLabel = UILabel().then {
      $0.font = .boldSystemFont(ofSize: 16.0)
    }

    addSubview(backgroundImageView)
    addSubview(subscriptLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateBackgroundImageView()
    updateSubscriptLabel()
    updatePin()
  }

  private func updateBackgroundImageView() {
    backgroundImageView.image = backgroundImage
    backgroundImageView.tintColor = backgroundTintColor
  }

  private func updateSubscriptLabel() {
    subscriptLabel.text = `subscript`
  }

  private func updatePin() {
    backgroundImageView.pin.all()
    subscriptLabel.pin.bottomCenter(18).sizeToFit()

    invalidateIntrinsicContentSize()
  }

  override var intrinsicContentSize: CGSize {
    backgroundImageView.intrinsicContentSize
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()

    return intrinsicContentSize
  }

}
