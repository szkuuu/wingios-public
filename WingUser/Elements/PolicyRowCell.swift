//
//  PolicyRowCell.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/05.
//

import UIKit

struct PolicyRowAttribute {

  static let reusableId: String = "PolicyRowCell"

  let isChecked: Bool?
  let attributedString: NSAttributedString?
  let rightView: UIControl?

  init(
    isChecked: Bool? = nil,
    attributedString: NSAttributedString? = nil,
    rightView builder: (() -> UIControl)? = nil
  ) {
    self.isChecked = isChecked
    self.attributedString = attributedString
    self.rightView = builder?()
  }

}

class PolicyRowCell: UICollectionViewCell {

  var checkButton: CheckButton!

  var descriptionLabel: UILabel!

  var isChecked: Bool? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  var attributedString: NSAttributedString? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  var rightView: UIControl? = nil {
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
    descriptionLabel = UILabel()

    contentView.addSubview(checkButton)
    contentView.addSubview(descriptionLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateCheckButton()
    updateDescriptionLabel()
    updateRightView()
    updatePin()
  }

  private func updateCheckButton() {
    guard let isChecked = isChecked else {
      checkButton.condition = .unchecked
      return
    }
    checkButton.condition = isChecked ? .checked : .unchecked
  }

  private func updateDescriptionLabel() {
    descriptionLabel.attributedText = attributedString
  }

  private func updateRightView() {
    guard let rightView = rightView else {
      rightView?.removeFromSuperview()
      return
    }
    if !contentView.subviews.contains(rightView) {
      contentView.addSubview(rightView)
    }
  }

  private func updatePin() {
    checkButton.pin.centerStart().size(24)
    if let rightView = rightView {
      rightView.pin.centerEnd().sizeToFit()
      descriptionLabel.pin
        .centerStart(to: checkButton.anchor.centerEnd)
        .end(to: rightView.edge.start)
        .marginHorizontal(16)
        .sizeToFit()
    } else {
      descriptionLabel.pin
        .start(to: checkButton.edge.end)
        .end()
        .vCenter()
        .marginHorizontal(16)
        .sizeToFit()
    }
    contentView.pin.wrapContent(.vertically)

//    invalidateIntrinsicContentSize()
  }

  override var intrinsicContentSize: CGSize {
    contentView.pin.width(bounds.width)

    return contentView.frame.size
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()

    return intrinsicContentSize
  }

  func configure(with attribute: PolicyRowAttribute) {
    self.isChecked = attribute.isChecked
    self.attributedString = attribute.attributedString
    self.rightView = attribute.rightView
  }

}
