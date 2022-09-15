//
//  BubbleWithTitle.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/15.
//

import UIKit

class BubbleWithTitle: UIView {

  let bubble: Bubble!

  private var nameLabel: UILabel!

  private var name: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  private var color: UIColor? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  init(
    bubble builder: () -> Bubble,
    name: String? = nil,
    labelColor color: UIColor? = nil
  ) {
    self.bubble = builder()
    super.init(frame: .zero)

    commonInit()
    self.name = name
    self.color = color
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    nameLabel = UILabel()

    addSubview(bubble)
    addSubview(nameLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateNameLabel()
    updatePin()
  }

  private func updateNameLabel() {
//    nameLabel.attributedText = "<s16><gray4>\(name ?? "")</gray4></s16>".wsAttributed
    nameLabel.text = name
    nameLabel.textColor = self.color ?? .systemGray4
  }

  private func updatePin() {
    bubble.pin.topCenter().sizeToFit()
    nameLabel.pin.below(of: bubble, aligned: .center).marginTop(8).sizeToFit()

    self.pin.wrapContent()

    invalidateIntrinsicContentSize()
  }

  override var intrinsicContentSize: CGSize {
    bounds.size
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()
    return intrinsicContentSize
  }

}
