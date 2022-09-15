//
//  PortCell.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/10.
//

import UIKit

struct PortAttribute {
  static let reusableId: String = "PortCell"

  let isChecked: Bool?
  let portImage: UIImage?

  init(
    isChecked: Bool? = nil,
    portImage: UIImage? = nil
  ) {
    self.isChecked = isChecked
    self.portImage = portImage
  }
}

class PortCell: UICollectionViewCell {

  var checkButton: CheckButton!

  private var portImageView: UIImageView!

  var isChecked: Bool? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  var portImage: UIImage? = nil {
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
    checkButton = CheckButton()
    portImageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit
    }

    contentView.addSubview(checkButton)
    contentView.addSubview(portImageView)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateCheckButton()
    updatePortImageView()
    updatePin()
  }

  private func updateCheckButton() {
    guard let isChecked = isChecked else {
      checkButton.condition = .unchecked
      return
    }
    checkButton.condition = isChecked ? .checked : .unchecked
  }

  private func updatePortImageView() {
    portImageView.image = portImage
  }

  private func updatePin() {
    checkButton.pin.topCenter().size(32)
    portImageView.pin
      .top(to: checkButton.edge.bottom)
      .bottom()
      .hCenter()
      .marginTop(25)
      .sizeToFit(.height)
  }

  override var intrinsicContentSize: CGSize {
    return bounds.size
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()

    return intrinsicContentSize
  }

  func configure(with attribute: PortAttribute) {
    self.isChecked = attribute.isChecked
    self.portImage = attribute.portImage
  }

}
