//
//  BillPaper.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/17.
//

import EFCountingLabel
import SwiftDate

import UIKit

class BillPaper: UIView {

  private let edgePadding: CGFloat = 18.0

  /// 분 당 요금
  private let amountPerMinute: Int = 150

  /// 요금 단위
  private let payUnit: String

  private var scrollView: UIScrollView!

  /// scrollView 의 컨테이너 뷰
  private let contentView: UIView = UIView().then {
    $0.backgroundColor = .white
  }

  private var titleLabels: [UILabel]!

  private var subtitleLabels: [UILabel]!

  private var detailLabels: [UILabel]!

  private var dividers: [UIView]!

  private var yellowDivider: DividerCell!

  private var payTitleLabel: UILabel!

  private var payUnitLabel: UILabel!

  private var amountLabel: EFCountingLabel!

  var whereis: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var port: Int? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var startTime: Date? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var endTime: Date? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var standardVoltage: Int? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var amount: CGFloat? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  init(
    place wheris: String? = nil,
    port portNumber: Int? = nil,
    start startTime: Date? = nil,
    end endTime: Date? = nil,
    standard standardVoltage: Int? = nil,
    howMuch amount: CGFloat? = nil,
    unit payUnit: String = "원"
  ) {
    self.payUnit = payUnit
    super.init(frame: .zero)

    commonInit()

    self.whereis = wheris
    self.port = portNumber
    self.startTime = startTime
    self.endTime = endTime
    self.standardVoltage = standardVoltage
    self.amount = amount
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    scrollView = UIScrollView().then {
      $0.backgroundColor = .white
    }
    titleLabels = [
      UILabel().then {
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .systemOrange
        $0.text = "이용정보"
      },
      UILabel().then {
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .systemOrange
        $0.text = "이용요금"
      }
    ]
    subtitleLabels = [
      UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .black
        $0.text = "이용위치"
      },
      UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .black
        $0.text = "포트정보"
      },
      UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .black
        $0.text = "시작시간"
      },
      UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .black
        $0.text = "종료시간"
      },
      UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .black
        $0.text = "이용시간"
      },
      UILabel().then {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
      },
    ]
    detailLabels = .init(count: subtitleLabels.count, element: UILabel().then {
      $0.numberOfLines = 0
      $0.lineBreakMode = .byWordWrapping
      $0.font = .systemFont(ofSize: 14)
      $0.textColor = .gray
    })
    dividers = .init(count: 2, element: UIView())
    yellowDivider = .init().then {
      $0.configure(with: .init(height: 2, color: .systemYellow))
    }
    payTitleLabel = UILabel().then {
      $0.text = "결제금액"
      $0.textColor = .black
      $0.font = .boldSystemFont(ofSize: 18)
    }
    payUnitLabel = UILabel().then {
      $0.text = payUnit
      $0.textColor = .black
      $0.font = .boldSystemFont(ofSize: 24)
    }
    amountLabel = EFCountingLabel().then {
      $0.font = .monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
      $0.textAlignment = .right
      $0.textColor = .black
      $0.counter.timingFunction = EFTimingFunction.easeOut(easingRate: 5)
      $0.setUpdateBlock { floatValue, countingLabel in
        countingLabel.text = NumberFormatter().then {
          $0.numberStyle = .decimal
        }.string(from: NSNumber(value: Int(floatValue)))
      }
      $0.countFromZeroTo(0)
    }

    titleLabels.forEach { contentView.addSubview($0) }
    subtitleLabels.forEach { contentView.addSubview($0) }
    detailLabels.forEach { contentView.addSubview($0) }
    dividers.forEach { contentView.addSubview($0) }
    scrollView.addSubview(contentView)
    addSubview(scrollView)
    addSubview(yellowDivider)
    addSubview(payTitleLabel)
    addSubview(payUnitLabel)
    addSubview(amountLabel)

    backgroundColor = .white
    layer.cornerRadius = 8.0
    layer.masksToBounds = true
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateDividers()
    updateSubtitleLabels()
    updateDetailLabels()
    updateAmountLabel()
    updatePin()
  }

  private func updateDividers() {
    dividers.forEach { divider in
      divider.frame = .init(origin: .zero, size: .init(width: contentView.bounds.width - (edgePadding * 2), height: 1))
      divider.layer.addSublayer(CAShapeLayer().then { lineLayer in
        lineLayer.path = UIBezierPath().then { path in
          path.move(to: .zero)
          path.addLine(to: .init(x: contentView.bounds.width, y: .zero))
          path.lineCapStyle = .round
        }.cgPath
        lineLayer.lineDashPattern = [2, 2]
        lineLayer.lineWidth = 1
        lineLayer.strokeColor = UIColor.lightGray.cgColor
      })
    }
  }

  private func updateSubtitleLabels() {
    subtitleLabels[5].attributedText = """
<s14b>분당요금</s14b>
<s10b>(\(standardVoltage ?? 36)V 기준)</s10b>
""".wsAttributed
  }

  private func updateDetailLabels() {
    detailLabels[0].text = whereis
    if let port = port {
      detailLabels[1].text = "포트 \(port)번"
    } else {
      detailLabels[1].text = "포트 정보를 불러올 수 없음"
    }
    if let startTime = startTime,
       let endTime = endTime {
      detailLabels[2].text = DateInRegion(startTime, region: .current).toFormat("yyyy-MM-dd a hh:mm:ss", locale: Locales.koreanSouthKorea)
      detailLabels[3].text = DateInRegion(endTime, region: .current).toFormat("yyyy-MM-dd a hh:mm:ss", locale: Locales.koreanSouthKorea)
    } else {
      detailLabels[2].text = "-"
      detailLabels[3].text = "-"
    }
    if let startTime = startTime,
       let endTime = endTime,
       startTime < endTime {
      detailLabels[4].text = (endTime - startTime).timeInterval.toString {
        $0.unitsStyle = .short
        $0.locale = Locales.koreanSouthKorea
      }
    } else {
      detailLabels[4].text = "#N/A"
    }
    detailLabels[5].text = "\(amountPerMinute) \(payUnit)"
  }

  private func updateAmountLabel() {
    guard let amount = amount else {
      return
    }

    amountLabel.countFromCurrentValueTo(amount, withDuration: 2)
  }

  private func updatePin() {
    yellowDivider.pin
      .bottom(21.37%)
      .horizontally(edgePadding)
      .height(yellowDivider.height ?? 1.0)

    scrollView.pin
      .top(edgePadding)
      .bottom(to: yellowDivider.edge.top)
      .horizontally(edgePadding)

    contentView.pin.top().horizontally()

    titleLabels[0].pin
      .topStart()
      .sizeToFit()

    subtitleLabels[0].pin
      .below(of: titleLabels[0], aligned: .start)
      .marginTop(12)
      .sizeToFit()

    detailLabels[0].pin
      .topStart(to: subtitleLabels[0].anchor.topEnd)
      .end()
      .sizeToFit(.width)

    subtitleLabels[1].pin
      .top(to: detailLabels[0].edge.bottom)
      .start()
      .marginTop(8)
      .sizeToFit()

    detailLabels[1].pin
      .topStart(to: subtitleLabels[1].anchor.topEnd)
      .end()
      .sizeToFit(.width)

    dividers[0].pin
      .top(to: subtitleLabels[1].edge.bottom)
      .horizontally()
      .height(1)
      .marginTop(16)

    titleLabels[1].pin
      .topStart(to: dividers[0].anchor.bottomStart)
      .marginTop(16)
      .sizeToFit()

    subtitleLabels[2].pin
      .below(of: titleLabels[1], aligned: .start)
      .marginTop(12)
      .sizeToFit()

    detailLabels[2].pin
      .topStart(to: subtitleLabels[2].anchor.topEnd)
      .end()
      .sizeToFit(.width)

    subtitleLabels[3].pin
      .top(to: detailLabels[2].edge.bottom)
      .start()
      .marginTop(8)
      .sizeToFit()

    detailLabels[3].pin
      .topStart(to: subtitleLabels[3].anchor.topEnd)
      .end()
      .sizeToFit(.width)

    dividers[1].pin
      .top(to: subtitleLabels[3].edge.bottom)
      .start()
      .end()
      .marginTop(16)

    subtitleLabels[4].pin
      .topStart(to: dividers[1].anchor.bottomStart)
      .marginTop(16)
      .sizeToFit()

    detailLabels[4].pin
      .topStart(to: subtitleLabels[4].anchor.topEnd)
      .end()
      .sizeToFit(.width)

    subtitleLabels[5].pin
      .top(to: detailLabels[4].edge.bottom)
      .start()
      .marginTop(8)
      .sizeToFit()

    detailLabels[5].pin
      .topStart(to: subtitleLabels[5].anchor.topEnd)
      .end()
      .sizeToFit(.width)

    if let maxWidth = subtitleLabels.map({ $0.bounds.width }).max() {
      subtitleLabels.forEach { $0.pin.width(maxWidth) }
    }

    detailLabels.enumerated().forEach { index, label in
      label.pin
        .topStart(to: subtitleLabels[index].anchor.topEnd)
        .marginStart(24)
        .sizeToFit(.width)
        .end()
    }

    contentView.pin.wrapContent(.vertically)
    // auto-layout
    contentView.snp.makeConstraints {
      $0.edges.equalTo(scrollView.contentLayoutGuide.snp.edges)
      $0.center.equalTo(scrollView.contentLayoutGuide.snp.center)
      $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
      $0.height.equalTo(contentView.bounds.height + edgePadding)
    }

    payTitleLabel.pin
      .bottom(9.5%)
      .start(edgePadding)
      .sizeToFit()

    payUnitLabel.pin
      .vCenter(to: payTitleLabel.edge.vCenter)
      .end(edgePadding)
      .sizeToFit()

    amountLabel.pin
      .horizontallyBetween(payTitleLabel, and: payUnitLabel, aligned: .center)
      .height(payUnitLabel.bounds.height)
      .marginHorizontal(8)
  }

}
