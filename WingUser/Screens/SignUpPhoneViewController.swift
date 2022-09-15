//
//  SignUpPhoneViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/05.
//

import UIKit

class SignUpPhoneViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>휴대폰 번호 입력</s24b>".wsAttributed
  }

  private lazy var phoneNumberTextField: UnderlineTextField = UnderlineTextField(placeholder: "'-' 구분없이 입력",
                                                                                 keyboardType: .phonePad)

  private lazy var nextButton: CTAButton = CTAButton(text: "인증번호 보내기")

  let viewModel = SignUpPhoneViewModel(input: SignUpPhoneViewInput(), output: SignUpPhoneViewOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    view.addSubview(titleLabel)
    view.addSubview(phoneNumberTextField)
    view.addSubview(nextButton)

    if presentingViewController != nil {
      navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil), animated: true)
      navigationItem.leftBarButtonItem?.rx
        .tap
        .withUnretained(self)
        .subscribe(onNext: { owner, _ in
          owner.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
    }

    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(57)
    }
    phoneNumberTextField.snp.makeConstraints {
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.top.equalTo(titleLabel.snp.bottom).offset(80)
    }
    nextButton.snp.makeConstraints {
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
      $0.height.equalTo(60)
    }

    phoneNumberTextField.textField.rx
      .text.orEmpty
      .distinctUntilChanged()
      .bind(to: self.viewModel.input.phoneNumber)
      .disposed(by: rx.disposeBag)

    nextButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapNextButton.accept(owner.nextButton.condition ?? .inactive)
      }).disposed(by: rx.disposeBag)

    viewModel.output.phoneNumberFormatted
      .bind(to: phoneNumberTextField.textField.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.phoneNumberEditingForceEnd
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.view.endEditing(true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.changeNextButtonCondition
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] isFull in
        if isFull {
          self?.nextButton.condition = .normal
        } else {
          self?.nextButton.condition = .inactive
        }
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTapNextButton
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.viewModel.input.fetchVerifyCode.accept(self?.phoneNumberTextField.textField.text)
      }).disposed(by: rx.disposeBag)

    viewModel.output.didFetchVerifyCode
      .asObservable()
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let code):
          owner.navigationController?.pushViewController(SignUpVerifyViewController().then {
            $0.viewModel.input.injectVerifyCode.accept(code)
            $0.viewModel.input.injectPhoneNumber.accept(owner.phoneNumberTextField.textField.text)
          }, animated: true)
          WSLoadingIndicator.stopLoad()
        case .failure(let error):
          owner.alert(title: "에러 발생", message: error.errorDescription, style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            WSLoadingIndicator.stopLoad()
          })])
        }
      }).disposed(by: rx.disposeBag)

  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
