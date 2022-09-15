//
//  Bubble.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/10.
//

import UIKit

class Bubble: UIControl {

  private var imageView: UIImageView!

  private var image: UIImage? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var backColor: UIColor = .systemBackground {
    didSet {
      setNeedsLayout()
    }
  }

  var imageColor: UIColor? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  private let size: CGFloat

  init(
    size: CGFloat = 0,
    image: UIImage? = nil,
    color: UIColor? = nil
  ) {
    self.size = size
    super.init(frame: .zero)

    commonInit()
    self.image = image
    self.imageColor = color
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    imageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit
    }

    addSubview(imageView)

    layer.shadowOffset = .init(width: .zero, height: 10)
    layer.shadowRadius = 6
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.1
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateContentView()
    updateImageView()
    updatePin()
  }

  private func updateContentView() {
    backgroundColor = self.backColor
    layer.cornerRadius = bounds.width / 2
  }

  private func updateImageView() {
    imageView.image = self.image
    imageView.tintColor = self.imageColor ?? .label
  }

  private func updatePin() {
    imageView.pin.width(80%).center().sizeToFit(.width)

    invalidateIntrinsicContentSize()
  }

  override var intrinsicContentSize: CGSize {
    .init(width: size, height: size)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()
    return intrinsicContentSize
  }

}
