//
//  SignUpWhereStandardViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/10.
//

import UIKit

class SignUpWhereStandardViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>충전규격 위치확인</s24b>".wsAttributed
  }

  private lazy var sampleImageView: UIImageView = UIImageView(image: .init(named: "charger.example")).then {
    $0.contentMode = .scaleAspectFit
  }

  private lazy var captionLabel: UILabel = UILabel().then {
    $0.text = "※ 상단은 예시 이미지입니다."
    $0.textColor = .tertiaryLabel
    $0.font = .systemFont(ofSize: 14)
  }

  private lazy var contentCoverView: UIView = UIView().then {
    $0.backgroundColor = .secondarySystemBackground
    $0.layer.cornerRadius = 8.0
    $0.layer.masksToBounds = true
  }

  private lazy var contentLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
    $0.textColor = .secondaryLabel
    $0.textAlignment = .center
    $0.attributedText = "<s16>소지하고 계신 기기의 충전기 뒷면에 표기된 <s16b>'정격출력'</s16b> 또는 <s16b>'OUTPUT'</s16b> 을 참고하여 등록해주세요.</s16>".wsAttributed
  }

  private lazy var compabilityButton: UIButton = UIButton().then {
    $0.setTitle("호환되는 킥보드 종류를 알고 싶어요!", for: .normal)
    $0.setTitleColor(.systemOrange, for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 14.0)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    contentCoverView.addSubview(contentLabel)

    view.addSubview(titleLabel)
    view.addSubview(sampleImageView)
    view.addSubview(captionLabel)
    view.addSubview(contentCoverView)
    view.addSubview(compabilityButton)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
      $0.centerX.equalToSuperview()
    }
    sampleImageView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(36)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(UIScreen.main.bounds.width * 0.78667)
      $0.height.equalTo(sampleImageView.snp.width).multipliedBy(1.10847)
    }
    captionLabel.snp.makeConstraints {
      $0.top.equalTo(sampleImageView.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
    }
    contentLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(20)
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
    }
    contentCoverView.snp.makeConstraints {
      $0.top.equalTo(captionLabel.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(contentLabel.snp.bottom).offset(20)
    }
    compabilityButton.snp.makeConstraints {
      $0.top.equalTo(contentCoverView.snp.bottom).offset(16)
      $0.centerX.equalTo(view.layoutMarginsGuide.snp.centerX)
    }

    compabilityButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.present(WebViewController(url: WSConst.compabilityAddress), animated: true)
      }).disposed(by: rx.disposeBag)
  }

}
