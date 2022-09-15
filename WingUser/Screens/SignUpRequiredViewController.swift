//
//  SignUpRequiredViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/08.
//

import UIKit

class SignUpRequiredViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>개인정보 입력</s24b>".wsAttributed
  }

  private lazy var lastNameTextField: UnderlineTextField = UnderlineTextField(placeholder: "성").then {
    $0.textField.textContentType = .familyName
  }

  private lazy var firstNameTextField: UnderlineTextField = UnderlineTextField(placeholder: "이름").then {
    $0.textField.textContentType = .givenName
  }

  private lazy var emailTextField: UnderlineTextField = UnderlineTextField(placeholder: "이메일",
                                                                           keyboardType: .emailAddress)

  private lazy var nextButton: CTAButton = CTAButton(text: "다음")

  let viewModel = SignUpRequiredViewModel(input: SignUpRequiredInput(), output: SignUpRequiredOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    view.addSubview(titleLabel)
    view.addSubview(lastNameTextField)
    view.addSubview(firstNameTextField)
    view.addSubview(emailTextField)
    view.addSubview(nextButton)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(57)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    lastNameTextField.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
    }
    firstNameTextField.snp.makeConstraints {
      $0.top.equalTo(lastNameTextField.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
    }
    emailTextField.snp.makeConstraints {
      $0.top.equalTo(firstNameTextField.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
    }
    nextButton.snp.makeConstraints {
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
      $0.height.equalTo(60)
    }

    nextButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapNextButton.accept(owner.nextButton.condition ?? .inactive)
      }).disposed(by: rx.disposeBag)

    lastNameTextField.textField.rx
      .text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.input.injectLastName)
      .disposed(by: rx.disposeBag)

    firstNameTextField.textField.rx
      .text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.input.injectFirstName)
      .disposed(by: rx.disposeBag)

    emailTextField.textField.rx
      .text.orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.input.injectEmail)
      .disposed(by: rx.disposeBag)

    viewModel.output.changeNextButtonCondition
      .bind(to: nextButton.rx.condition)
      .disposed(by: rx.disposeBag)

    viewModel.output.didTapNextButton
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.navigationController?.pushViewController(SignUpPortRegisterViewController().then { [weak owner = owner] in
          if let owner = owner,
             let userCache = owner.viewModel.userCache {
            $0.viewModel.userCache = userCache.move(lastName: owner.lastNameTextField.textField.text ?? "",
                                                    firstName: owner.firstNameTextField.textField.text ?? "",
                                                    email: owner.emailTextField.textField.text ?? "")
          }
        }, animated: true)
      }).disposed(by: rx.disposeBag)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

}
