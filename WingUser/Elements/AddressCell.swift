//
//  AddressCell.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/15.
//

import UIKit

struct AddressAttribute {

  static let reusableId: String = "AddressCell"

  let logoImage: UIImage?
  let roadAddress: String?
  let lotNumberAddress: String?

  init(
    logo image: UIImage? = nil,
    road roadAddress: String? = nil,
    lotNumber lotNumberAddress: String? = nil
  ) {
    self.logoImage = image
    self.roadAddress = roadAddress
    self.lotNumberAddress = lotNumberAddress
  }

}

class AddressCell: UICollectionViewCell {

  private var logoImageView: UIImageView!

  private var roadLabel: UILabel!

  private var lotLabel: UILabel!

//  private let verticalPadding: CGFloat = 5.0

  var logoImage: UIImage? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  var roadAddress: String? = nil {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  var lotNumberAddress: String? = nil {
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
    logoImageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit
    }
    roadLabel = UILabel().then {
      $0.font = .systemFont(ofSize: 16)
      $0.textColor = .label
      $0.numberOfLines = 0
      $0.lineBreakMode = .byWordWrapping
    }
    lotLabel = UILabel().then {
      $0.font = .systemFont(ofSize: 14)
      $0.textColor = .secondaryLabel
      $0.numberOfLines = 0
      $0.lineBreakMode = .byWordWrapping
    }

    contentView.addSubview(logoImageView)
    contentView.addSubview(roadLabel)
    contentView.addSubview(lotLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateLogoImageView()
    updateRoadLabel()
    updateLotLabel()
    updatePin()
  }

  private func updateLogoImageView() {
    logoImageView.image = self.logoImage
  }

  private func updateRoadLabel() {
    roadLabel.text = self.roadAddress
  }

  private func updateLotLabel() {
    lotLabel.text = self.lotNumberAddress
  }

  private func updatePin() {
    logoImageView.pin
      .topStart(2)
      .sizeToFit()
    roadLabel.pin
      .start(to: logoImageView.edge.end)
      .end()
      .marginStart(12)
      .marginEnd(16)
      .sizeToFit(.width)
    lotLabel.pin
      .below(of: roadLabel, aligned: .start)
      .end()
      .marginTop(2)
      .marginEnd(16)
      .sizeToFit(.width)
    contentView.pin.wrapContent(.vertically)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    contentView.pin.width(size.width)
    updatePin()
    return contentView.frame.size
  }

  func configure(with attribute: AddressAttribute) {
    self.logoImage = attribute.logoImage
    self.roadAddress = attribute.roadAddress
    self.lotNumberAddress = attribute.lotNumberAddress
  }

}
