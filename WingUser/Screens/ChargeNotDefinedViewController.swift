//
//  ChargeNotDefinedViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/19.
//

import UIKit

class ChargeNotDefinedViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>Please register charge spec.</s24b>".wsAttributed
  }

  private lazy var chargerImageView: UIImageView = UIImageView(image: .init(named: "charger")).then {
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .systemGray4
  }

  private lazy var portImageView: UIImageView = UIImageView(image: .init(named: "port.head.none")).then {
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .systemGray4
  }

  private lazy var subtitleLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
    $0.font = .systemFont(ofSize: 14)
    $0.text = """
Charge spec. is NOT registered
Please register the charge spec for using WING station.
"""
  }

  private lazy var registerButton: CTAButton = CTAButton(text: "Register", condition: .normal)

  private lazy var laterButton: CTAButton = CTAButton(text: "Cancel", condition: .option(lightForced: false))

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    view.addSubview(titleLabel)
    view.addSubview(chargerImageView)
    view.addSubview(portImageView)
    view.addSubview(subtitleLabel)
    view.addSubview(registerButton)
    view.addSubview(laterButton)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    chargerImageView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(48)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.width.equalTo(view.snp.width).multipliedBy(0.56)
    }
    portImageView.snp.makeConstraints {
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(chargerImageView.snp.height)
      $0.centerY.equalTo(chargerImageView.snp.centerY)
    }
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(chargerImageView.snp.bottom).offset(40)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
    }
    registerButton.snp.makeConstraints {
      $0.bottom.equalTo(laterButton.snp.top).offset(-16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(60)
    }
    laterButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(60)
    }
  }

}
