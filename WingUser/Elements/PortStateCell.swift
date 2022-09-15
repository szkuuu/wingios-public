//
//  PortStateCell.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/19.
//

import UIKit

struct PortStateAttribute {

  static let reusableId: String = "PortStateCell"

  let port: PortStateCell.Port?

  let portName: String?

  let portState: PortStateCell.State?

  init(
    port: PortStateCell.Port? = nil,
    portName name: String? = nil,
    portState state: PortStateCell.State? = nil
  ) {
    self.port = port
    self.portName = name
    self.portState = state
  }

}

class PortStateCell: UICollectionViewCell {

  enum Port {

    /// DC 8mm 규격
    case dc8

    /// 항공 단자 규격
    case gx

    /// 없음
    case none

    /// 사용자 커스텀
    case custom(portImage: UIImage?)

  }

  enum State {

    case available

    case unavailable

  }

  private var portImageView: UIImageView!

  private var portNameLabel: UILabel!

  private var stateButton: CTAButton!

  var port: PortStateCell.Port? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  private var portName: String? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  var portState: PortStateCell.State = .unavailable {
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
    portImageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit
      $0.tintColor = .systemGray4
    }
    portNameLabel = UILabel().then {
      $0.font = .boldSystemFont(ofSize: 14)
      $0.textAlignment = .center
    }
    stateButton = CTAButton().then {
      $0.textLabel.font = .systemFont(ofSize: 12, weight: .semibold)
    }

    contentView.addSubview(portImageView)
    contentView.addSubview(portNameLabel)
    contentView.addSubview(stateButton)

    backgroundColor = .systemBackground
    layer.cornerRadius = 8.0
    layer.masksToBounds = true
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updatePortImageView()
    updatePortNameLabel()
    updateStateButton()
    updatePin()
  }

  private func updatePortImageView() {
    if let port = port {
      switch port {
      case .dc8:
        portImageView.image = .init(named: "port.head.dc8")
      case .gx:
        portImageView.image = .init(named: "port.head.gx")
      case .none:
        portImageView.image = .init(named: "port.head.none")
      case .custom(let image):
        portImageView.image = image
      }
    } else {
      portImageView.image = nil
    }
  }

  private func updatePortNameLabel() {
    portNameLabel.text = portName
  }

  private func updateStateButton() {
    stateButton.condition = portState == .unavailable ? .inactive : .normal
    stateButton.textLabel.text = portState == .unavailable ? "사용불가" : "사용가능"
  }

  private func updatePin() {
    portImageView.pin.topStart(16).width(25%).aspectRatio()
    portNameLabel.pin.centerStart(to: portImageView.anchor.centerEnd).end().marginStart(8).marginEnd(16).sizeToFit(.width)
    stateButton.pin.below(of: [portImageView, portNameLabel]).horizontally(16).marginVertical(16).sizeToFit(.width)
  }

  func configure(with attribute: PortStateAttribute) {
    self.port = attribute.port
    self.portName = attribute.portName
    self.portState = attribute.portState ?? .unavailable
  }

}
