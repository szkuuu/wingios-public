//
//  SignUpPortStandardViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/10.
//

import UIKit

class SignUpPortStandardViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>충전규격 등록</s24b>".wsAttributed
  }

  private lazy var subtitleLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.attributedText = "<s14>소지하신 충전기의 뒷면을 확인하고,\n충전규격을 등록해주세요.</s14>".wsAttributed
  }

  private lazy var contentBackgroundView: UIView = UIView().then {
    $0.backgroundColor = .systemGray6
    $0.layer.cornerRadius = 16.0
    $0.layer.masksToBounds = true
  }

  private lazy var contentTitleLabel: UILabel = UILabel().then {
    $0.text = "정격출력 (OUTPUT)"
    $0.textColor = .label
    $0.font = .systemFont(ofSize: 18, weight: .bold)
  }

  private lazy var voltageDigitTextField: DigitTextField = DigitTextField(caption: "V", placeholder: "0.00")

  private lazy var currentDigitTextField: DigitTextField = DigitTextField(caption: "A", placeholder: "0.0")

  private lazy var horizontalStack: UIStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 12
    $0.distribution = .fillEqually
  }

  private lazy var contentSubtitleLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
    $0.text = """
충전기 뒷면에 표기된
'정격출력' 또는 'OUTPUT' 을 참고해주세요.

충전 규격을 올바르게 입력하지 않을 시,
기기 고장이 발생할 수 있습니다.
"""
    $0.textColor = .secondaryLabel
    $0.font = .systemFont(ofSize: 14)
  }

  private lazy var chargeImageView: UIImageView = UIImageView(image: .init(named: "charge.mini")).then {
    $0.contentMode = .scaleAspectFit
  }

  private lazy var guideButton: UIButton = UIButton().then {
    $0.titleLabel?.font = .systemFont(ofSize: 14)
    $0.setAttributedTitle("충전규격은 어디서 확인하나요?".styleAll(.underlineStyle(.single)).attributedString, for: .normal)
  }

  private lazy var nextButton: CTAButton = CTAButton(text: "완료")

  private lazy var laterButton: CTAButton = CTAButton(text: "나중에 등록할게요", condition: .option(lightForced: false))

  let viewModel = SignUpPortStandardViewModel(input: SignUpPortStandardInput(), output: SignUpPortStandardOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    horizontalStack.addArrangedSubview(voltageDigitTextField)
    horizontalStack.addArrangedSubview(currentDigitTextField)

    contentBackgroundView.addSubview(contentTitleLabel)
    contentBackgroundView.addSubview(horizontalStack)
    contentBackgroundView.addSubview(contentSubtitleLabel)

    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(contentBackgroundView)
    view.addSubview(chargeImageView)
    view.addSubview(guideButton)
    view.addSubview(nextButton)
    view.addSubview(laterButton)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(5)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    contentBackgroundView.snp.makeConstraints {
      $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(contentSubtitleLabel.snp.bottom).offset(24)
    }
    contentTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(30)
      $0.leading.equalToSuperview().offset(30)
    }
    horizontalStack.snp.makeConstraints {
      $0.top.equalTo(contentTitleLabel.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(30)
      $0.trailing.equalToSuperview().offset(-30)
    }
    contentSubtitleLabel.snp.makeConstraints {
      $0.top.equalTo(horizontalStack.snp.bottom).offset(32)
      $0.leading.equalToSuperview().offset(30)
      $0.trailing.equalToSuperview().offset(-30)
    }
    guideButton.snp.makeConstraints {
      $0.top.equalTo(contentBackgroundView.snp.bottom).offset(8)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
    }
    chargeImageView.snp.makeConstraints {
      $0.centerY.equalTo(guideButton.snp.centerY)
      $0.trailing.equalTo(guideButton.snp.leading).offset(-4)
      $0.size.equalTo(guideButton.titleLabel?.snp.height ?? 0)
    }
    nextButton.snp.makeConstraints {
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(laterButton.snp.top).offset(-16)
      $0.height.equalTo(60)
    }
    laterButton.snp.makeConstraints {
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
      $0.height.equalTo(60)
    }

    guideButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.present(SignUpWhereStandardViewController(), animated: true)
      }).disposed(by: rx.disposeBag)

    nextButton.rx
      .tapGesture()
      .when(.recognized)
      .map { [weak self] _ in self?.nextButton.condition ?? .inactive }
      .bind(to: self.viewModel.input.tapNextButton)
      .disposed(by: rx.disposeBag)

    laterButton.rx
      .tapGesture()
      .when(.recognized)
      .map { _ in () }
      .bind(to: self.viewModel.input.tapLaterButton)
      .disposed(by: rx.disposeBag)

    self.voltageDigitTextField.textfield.rx
      .controlEvent([.editingDidEnd])
      .map { self.voltageDigitTextField.textfield.text ?? "" }
      .bind(to: viewModel.input.injectVoltage)
      .disposed(by: rx.disposeBag)

    self.currentDigitTextField.textfield.rx
      .controlEvent([.editingDidEnd])
      .map { self.currentDigitTextField.textfield.text ?? "" }
      .bind(to: viewModel.input.injectAmpere)
      .disposed(by: rx.disposeBag)

    viewModel.output.formattedVoltage
      .bind(to: self.voltageDigitTextField.textfield.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.formattedAmpere
      .bind(to: self.currentDigitTextField.textfield.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.changeNextButtonCondition
      .bind(to: self.nextButton.rx.condition)
      .disposed(by: rx.disposeBag)

    viewModel.output.didDoInvalid
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "잘못된 접근", message: "올바른 접근이 아닙니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didSignUpSuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "회원가입 완료", message: "회원가입이 완료되었습니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.navigationController?.dismiss(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didSignUpUnsuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "회원가입 에러", message: "에러가 발생하였습니다. 다시 한 번 시도해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurWarningWithOutOfRange
      .withUnretained(self)
      .subscribe(onNext: { owner, pack in
        switch pack.category {
        case .voltage:
          owner.alert(title: "전압 범위 초과", message: pack.message, style: .alert, actions: [
            UIAlertAction(title: "확인", style: .cancel)
          ]) {
            owner.viewModel.input.injectVoltage.accept("\(WSConst.voltageLimit)")
          }
        case .ampere:
          owner.alert(title: "전류 범위 초과", message: pack.message, style: .alert, actions: [
            UIAlertAction(title: "확인", style: .cancel)
          ]) {
            owner.viewModel.input.injectAmpere.accept("\(WSConst.ampereLimit)")
          }
        }
      }).disposed(by: rx.disposeBag)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

}
