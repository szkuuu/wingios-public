//
//  FakeSearchBar.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/10.
//

import UIKit

class FakeSearchBar: UIControl {

  private var leftCircle: UIView!

  private var magnifyingglassImage: UIImageView!

  private var fakePlaceholder: UILabel!

  var fakeText: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  private var fakeTextColor: UIColor? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  private let circleMargin: CGFloat = 7.0

  init(
    fakeText text: String? = nil,
    textColor fakeTextColor: UIColor = .placeholderText
  ) {
    super.init(frame: .zero)

    commonInit()
    self.fakeText = text
    self.fakeTextColor = fakeTextColor
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    leftCircle = UIView().then {
      $0.backgroundColor = .systemYellow
    }
    magnifyingglassImage = UIImageView(image: .init(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))).then {
      $0.contentMode = .scaleAspectFit
      $0.tintColor = .black
    }
    fakePlaceholder = UILabel().then {
      $0.font = .systemFont(ofSize: 14)
      $0.textColor = .placeholderText
    }

    leftCircle.addSubview(magnifyingglassImage)

    addSubview(leftCircle)
    addSubview(fakePlaceholder)

    backgroundColor = .systemGray6
    layer.shadowOffset = .init(width: .zero, height: 5)
    layer.shadowRadius = 16
    layer.shadowColor = UIColor(displayP3Red: 0.27059, green: 0.35686, blue: 0.38824, alpha: 1.0).cgColor
    layer.shadowOpacity = 0.15
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateContentView()
    updateCircle()
    updateFakeLabel()
    updatePin()
  }

  private func updateContentView() {
    layer.cornerRadius = bounds.height / 2
  }

  private func updateCircle() {
    leftCircle.layer.cornerRadius = (bounds.height - (circleMargin * 2)) / 2
  }

  private func updateFakeLabel() {
    fakePlaceholder.text = fakeText
    fakePlaceholder.textColor = fakeTextColor
  }

  private func updatePin() {
    leftCircle.pin.start(circleMargin).vertically(circleMargin).width(leftCircle.bounds.height)
    magnifyingglassImage.pin.width(50%).center().aspectRatio()
    fakePlaceholder.pin
      .centerStart(to: leftCircle.anchor.centerEnd)
      .vCenter()
      .marginHorizontal(8)
      .sizeToFit()
  }
  
}
