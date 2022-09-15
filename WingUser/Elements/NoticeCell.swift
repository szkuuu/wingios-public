//
//  NoticeCell.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/19.
//

import SwiftDate
import UIKit

struct NoticeAttribute {

  static let reusableId: String = "NoticeCell"

  let pinned: Bool?
  let category: NoticeCell.Category?
  let title: String?
  let date: Date?
  let tapAction: (() -> Void)?

  init(
    isPinned pinned: Bool? = nil,
    category: NoticeCell.Category? = nil,
    title: String? = nil,
    date: Date? = nil,
    tapAction tapBuilder: (() -> Void)? = nil
  ) {
    self.pinned = pinned
    self.category = category
    self.title = title
    self.date = date
    self.tapAction = tapBuilder
  }

}

class NoticeCell: UICollectionViewCell {

  enum Category: Int {

    case notice = 1

    case event

    case partner

  }

  private var categoryLabel: UILabel!

  private var titleLabel: UILabel!

  private var dateLabel: UILabel!

  private var separatorLayer: CAShapeLayer!

  private var category: NoticeCell.Category? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  private var pinned: Bool? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  private var title: String? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  private var date: Date? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  private var tapAction: (() -> Void)? = nil

  override init(frame: CGRect) {
    super.init(frame: frame)

    commonInit()
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    categoryLabel = UILabel().then {
      $0.font = .systemFont(ofSize: 12)
    }
    titleLabel = UILabel().then {
      $0.font = .systemFont(ofSize: 14)
    }
    dateLabel = UILabel().then {
      $0.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
      $0.textColor = .secondaryLabel
    }
    separatorLayer = CAShapeLayer()

    contentView.addSubview(categoryLabel)
    contentView.addSubview(titleLabel)
    contentView.addSubview(dateLabel)
    contentView.layer.addSublayer(separatorLayer)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateCategoryLabel()
    updateTitleLabel()
    updateDateLabel()
    updateSeparatorLayer()
    updatePin()
  }

  private func updateCategoryLabel() {
    if let category = category {
      switch category {
      case .notice:
        categoryLabel.text = "공지"
      case .event:
        categoryLabel.text = "이벤트"
      case .partner:
        categoryLabel.text = "제휴"
      }
    } else {
      categoryLabel.text = "Null"
    }

    categoryLabel.textColor = (self.pinned ?? false) ? .systemOrange : .label
  }

  private func updateTitleLabel() {
    titleLabel.text = title
  }

  private func updateDateLabel() {
    let dateValue = self.date ?? Date(timeIntervalSince1970: 0)

    dateLabel.text = dateValue.toFormat("yy.MM.dd", locale: Locales.koreanSouthKorea)
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
    categoryLabel.pin
      .start(16)
      .vCenter()
      .width(15%)
      .sizeToFit(.width)
    dateLabel.pin
      .end(16)
      .vCenter()
      .sizeToFit()
    titleLabel.pin
      .horizontallyBetween(categoryLabel, and: dateLabel, aligned: .center)
      .marginEnd(16)
      .sizeToFit(.width)
    separatorLayer.pin.bottomStart(separatorLayer.lineWidth)
  }

  func configure(with attribute: NoticeAttribute) {
    self.pinned = attribute.pinned
    self.category = attribute.category
    self.title = attribute.title
    self.date = attribute.date
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
