//
//  SignUpVerifyViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/05.
//

import UIKit

class SignUpVerifyViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>인증번호 입력</s24b>".wsAttributed
  }

  private lazy var subtitleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s14>아래 번호로 인증번호를 전송하였습니다.\n</s14>".wsAttributed
  }

  private lazy var phoneNumberLabel: UILabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14)
  }

  private lazy var codeTextField: UnderlineTextField = UnderlineTextField(placeholder: "인증번호 입력",
                                                                          keyboardType: .numberPad).then {
    $0.textField.textContentType = .oneTimeCode
  }

  private lazy var timeLabel: UILabel = UILabel().then {
    $0.attributedText = "<orange>--:--</orange>".wsAttributed
  }

  private lazy var resendButton: UIButton = UIButton().then {
    $0.setTitle("인증번호를 다시 받고 싶어요!", for: .normal)
    $0.setTitleColor(.systemOrange, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 14.0)
  }

  private lazy var verifyGuideLabel: UILabel = UILabel().then {
    $0.text = "SMS 연동 전까지 인증번호가 아래에 표시됩니다"
    $0.font = .boldSystemFont(ofSize: 12)
  }

  private lazy var verifyCodeLabel: UILabel = UILabel().then {
    $0.text = "-"
    $0.font = .monospacedDigitSystemFont(ofSize: 13, weight: .bold)
  }

  private lazy var nextButton: CTAButton = CTAButton(text: "인증하기")

  private let verificationTimeSeconds = 180

  let viewModel = SignUpVerifyViewModel(input: SignUpVerifyInput(), output: SignUpVerifyOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(phoneNumberLabel)
    view.addSubview(codeTextField)
    view.addSubview(timeLabel)
    view.addSubview(resendButton)
    view.addSubview(verifyGuideLabel)
    view.addSubview(verifyCodeLabel)
    view.addSubview(nextButton)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(57)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(5)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    phoneNumberLabel.snp.makeConstraints {
      $0.top.equalTo(subtitleLabel.snp.bottom)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    codeTextField.snp.makeConstraints {
      $0.top.equalTo(phoneNumberLabel.snp.bottom).offset(36)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
    }
    timeLabel.snp.makeConstraints {
      $0.centerY.equalTo(codeTextField.snp.centerY)
      $0.trailing.equalTo(codeTextField.snp.trailing).offset(-35)
    }
    resendButton.snp.makeConstraints {
      $0.top.equalTo(codeTextField.snp.bottom).offset(16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    verifyGuideLabel.snp.makeConstraints {
      $0.bottom.equalTo(verifyCodeLabel.snp.top)
      $0.centerX.equalTo(verifyCodeLabel.snp.centerX)
    }
    verifyCodeLabel.snp.makeConstraints {
      $0.bottom.equalTo(nextButton.snp.top).offset(-8)
      $0.centerX.equalTo(nextButton.snp.centerX)
    }
    nextButton.snp.makeConstraints {
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
      $0.height.equalTo(60)
    }

    #if DEBUG
    verifyGuideLabel.isHidden = false
    verifyCodeLabel.isHidden = false
    #else
    verifyGuideLabel.isHidden = true
    verifyCodeLabel.isHidden = true
    #endif
    
    codeTextField.textField.rx
      .text.orEmpty
      .distinctUntilChanged()
      .bind(to: self.viewModel.input.code)
      .disposed(by: rx.disposeBag)

    nextButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapNextButton.accept(owner.nextButton.condition ?? .inactive)
      }).disposed(by: rx.disposeBag)

    resendButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.restartTimer.accept((phoneNumber: owner.phoneNumberLabel.text, limitTime: owner.verificationTimeSeconds))
      }).disposed(by: rx.disposeBag)

    viewModel.input.startTimer.accept(verificationTimeSeconds)

    viewModel.output.timeString
      .bind(to: self.timeLabel.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.phoneNumber
      .withUnretained(self)
      .subscribe(onNext: { owner, phone in
        owner.phoneNumberLabel.text = phone
      }).disposed(by: rx.disposeBag)

    viewModel.output.codeFormatted
      .bind(to: codeTextField.textField.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.verifyCodeEditingForceEnd
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.view.endEditing(true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.changeNextButtonCondition
      .bind(to: self.nextButton.rx.condition)
      .disposed(by: rx.disposeBag)

    viewModel.output.didFetchVerifyCode
      .bind(to: self.verifyCodeLabel.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.didTapNextButton
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.fetchVerify.accept(Int(owner.codeTextField.textField.text ?? "") ?? 0)
      }).disposed(by: rx.disposeBag)

    viewModel.output.didChangeVerifyCode
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "인증번호 재발급", message: "인증번호가 다시 발급되었습니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          WSLoadingIndicator.stopLoad()
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurError
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "인증번호 발급 에러", message: "에러가 발생하였습니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          WSLoadingIndicator.stopLoad()
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTimeout
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "시간 초과", message: "인증할 수 없습니다. 인증번호를 다시 발급해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didVerify
      .withUnretained(self)
      .subscribe(onNext: { owner, isCorrect in
        if isCorrect {
          owner.timeLabel.text = "--:--"
          owner.navigationController?.pushViewController(SignUpPolicyViewController().then { [weak self] in
            if let phoneNumberString = self?.phoneNumberLabel.text {
              $0.viewModel.userCache = .init(phoneNumber: phoneNumberString.replacingOccurrences(of: " ", with: ""))
            }
          }, animated: true)
        } else {
          owner.alert(title: "인증번호 불일치", message: "입력하신 번호와 인증번호가 일치하지 않습니다. 인증번호를 다시 확인해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
        }
      }).disposed(by: rx.disposeBag)

    viewModel.output.didLogin
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "로그인 완료", message: "로그인 되었습니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.navigationController?.dismiss(animated: true)
        }])
      }).disposed(by: rx.disposeBag)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

}
