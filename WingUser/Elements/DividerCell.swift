//
//  DividerCell.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/05.
//

import UIKit

struct DividerAttribute {

  static let reusableId: String = "DividerCell"

  let height: CGFloat?
  let color: UIColor?

  init(
    height: CGFloat? = nil,
    color: UIColor? = nil
  ) {
    self.height = height
    self.color = color
  }

}

class DividerCell: UICollectionViewCell {

  var height: CGFloat? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  var color: UIColor? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    commonInit()
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    contentView.backgroundColor = color
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateColor()
    updatePin()
  }

  private func updateColor() {
    contentView.backgroundColor = color ?? .separator
  }

  private func updatePin() {
  }

  override var intrinsicContentSize: CGSize {
    contentView.pin.width(bounds.width).height(height ?? 1.0)

    return contentView.bounds.size
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    intrinsicContentSize
  }

  func configure(with attribute: DividerAttribute) {
    self.height = attribute.height
    self.color = attribute.color
  }
}
