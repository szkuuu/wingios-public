//
//  TitleFormRow.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/09.
//

import UIKit

class TitleFormRow: UIView {

  private var titleLabel: UILabel!

  private var formattedTextField: UIView!

  private var formattedTextFieldTopPadding: CGFloat = 4.0

  private var title: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  init(
    title: String = "",
    formattedView builder: @autoclosure () -> UIView
  ) {
    self.formattedTextField = builder()
    super.init(frame: .zero)

    commonInit()
    setTitle(title)
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    titleLabel = UILabel()

    addSubview(titleLabel)
    addSubview(formattedTextField)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateTitleLabel()
    updatePin()
  }

  private func updateTitleLabel() {
    guard let title = title else {
      return
    }
    titleLabel.attributedText = "<s14>\(title)</s14>".wsAttributed
  }

  private func updatePin() {
    titleLabel.pin.topStart().sizeToFit()
    formattedTextField.pin
      .below(of: titleLabel, aligned: .start)
      .bottom()
      .horizontally()
      .marginTop(formattedTextFieldTopPadding)
      .sizeToFit(.width)
    
    invalidateIntrinsicContentSize()
  }

  func setTitle(_ title: String) {
    self.title = title
  }

  override var intrinsicContentSize: CGSize {
    .init(
      width: bounds.width,
      height: titleLabel.bounds.height + formattedTextField.bounds.height + formattedTextFieldTopPadding
    )
  }

}
