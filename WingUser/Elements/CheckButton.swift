//
//  CheckButton.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/05.
//

import UIKit

class CheckButton: UIControl {

  enum Condition {

    case checked

    case unchecked

  }

  struct Appearance {

    let circleLineColor: CGColor

    let checkLineColor: CGColor

    let circleFillColor: CGColor

    init(borderColor: UIColor, checkColor: UIColor, fillColor: UIColor) {
      self.circleLineColor = borderColor.cgColor
      self.checkLineColor = checkColor.cgColor
      self.circleFillColor = fillColor.cgColor
    }

  }

  var condition: CheckButton.Condition? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  private var circleLayer: CAShapeLayer!

  private var checkLayer: CAShapeLayer!

  private let circleLineWidth: CGFloat = 2.0

  private let checkLineWidth: CGFloat = 2.0

  override init(frame: CGRect) {
    super.init(frame: frame)

    commonInit()
    condition = self.condition ?? .unchecked
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    circleLayer = CAShapeLayer().then {
      $0.lineWidth = circleLineWidth
    }
    checkLayer = CAShapeLayer().then {
      $0.lineWidth = checkLineWidth
    }

    layer.addSublayer(circleLayer)
    layer.addSublayer(checkLayer)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard let condition = condition else {
      return
    }
    let appearance = condition.appearance()

    updateCircleLayer(appearance)
    updateCheckLayer(appearance)
    updatePin()
  }

  private func updateCircleLayer(_ appearance: CheckButton.Appearance) {
    circleLayer.do { layer in
      layer.path = UIBezierPath(arcCenter: .init(x: bounds.midX, y: bounds.midY), radius: (frame.height - circleLineWidth) / 2, startAngle: .zero, endAngle: .pi * 2, clockwise: true).cgPath
      layer.fillColor = appearance.circleFillColor
      layer.strokeColor = appearance.circleLineColor
    }
  }

  private func updateCheckLayer(_ appearance: CheckButton.Appearance) {
    checkLayer.do { layer in
      layer.path = UIBezierPath().then { path in
        path.move(to: .init(x: frame.width / 4.1298, y: frame.height / 2.9167))
        path.addLine(to: .init(x: frame.width / 2.0618, y: frame.height / 1.57894))
        path.addLine(to: .init(x: frame.width / 1.1553, y: frame.height / 5.9272))
        path.lineCapStyle = .round
      }.cgPath
      layer.fillColor = UIColor.clear.cgColor
      layer.strokeColor = appearance.checkLineColor
    }
  }

  private func updatePin() {
    circleLayer.pin.all()
  }

}

extension CheckButton.Condition {

  func appearance() -> CheckButton.Appearance {
    switch self {
    case .checked:
      return .init(borderColor: .systemYellow, checkColor: .white, fillColor: .systemYellow)
    case .unchecked:
      return .init(borderColor: .systemGray4, checkColor: .clear, fillColor: .clear)
    }
  }

}
