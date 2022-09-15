//
//  NoticeMoreCell.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/19.
//

import UIKit

struct NoticeMoreAttribute {

  static let reusableId: String = "NoticeMoreCell"

  let tapAction: (() -> Void)?

  init(tapAction tapBuilder: (() -> Void)? = nil) {
    self.tapAction = tapBuilder
  }

}

class NoticeMoreCell: UICollectionViewCell {

  private var centerLabel: UILabel!

  private var separatorLayer: CAShapeLayer!

  private var tapAction: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)

    commonInit()
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    centerLabel = UILabel().then {
      $0.text = "더보기"
      $0.textColor = .secondaryLabel
      $0.font = .systemFont(ofSize: 14)
    }
    separatorLayer = CAShapeLayer()

    contentView.addSubview(centerLabel)
    contentView.layer.addSublayer(separatorLayer)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateSeparatorLayer()
    updatePin()
  }

  private func updateSeparatorLayer() {
    separatorLayer.path = UIBezierPath().then {
      $0.move(to: .zero)
      $0.addLine(to: .init(x: bounds.width, y: .zero))
    }.cgPath
    separatorLayer.lineWidth = 1.0
    separatorLayer.lineCap = .round
    separatorLayer.strokeColor = UIColor.systemGray5.cgColor
  }

  private func updatePin() {
    centerLabel.pin.center().sizeToFit()
    separatorLayer.pin.bottomStart(separatorLayer.lineWidth)
  }

  func configure(with attribute: NoticeMoreAttribute) {
    self.tapAction = attribute.tapAction

    var mutatingSelf = self
    mutatingSelf.rx.disposeBag = DisposeBag()

    if let tapAction = self.tapAction {
      self.rx
        .tapGesture()
        .when(.recognized)
        .withUnretained(self)
        .subscribe(onNext: { owner, _ in
          tapAction()
        }).disposed(by: rx.disposeBag)
    }
  }
}
