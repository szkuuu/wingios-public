//
//  CardModifyViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/09.
//

import UIKit

class CardModifyViewController: UIViewController {

  private lazy var cardView: CreditCard = CreditCard()

  private lazy var nextButton: CTAButton = CTAButton(condition: .normal)

  private let dateField = DateFormattedField()

  private let passwordField = PasswordFormattedField()

  private let cardNumberField = CardNumberFormattedField()

  private lazy var validDateFormRow: TitleFormRow = TitleFormRow(title: "유효기간",
                                                                 formattedView: dateField)

  private lazy var passwordFormRow: TitleFormRow = TitleFormRow(title: "비밀번호 앞 2자리",
                                                                formattedView: passwordField)

  private lazy var cardNumberFormRow: TitleFormRow = TitleFormRow(title: "카드번호",
                                                                  formattedView: cardNumberField)

  private lazy var verticalStack: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
  }

  private lazy var horizontalStack: UIStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 6
    $0.distribution = .fillEqually
  }

  let viewModel = CardModifyViewModel(input: CardModifyInput(), output: CardModifyOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    if presentingViewController != nil {
      navigationItem.setLeftBarButton(.init(barButtonSystemItem: .close, target: self, action: nil), animated: true)
      navigationItem.leftBarButtonItem?.rx
        .tap
        .withUnretained(self)
        .subscribe(onNext: { owner, _ in
          owner.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
      navigationItem.title = "카드 등록/수정"
    }

    horizontalStack.addArrangedSubview(validDateFormRow)
    horizontalStack.addArrangedSubview(passwordFormRow)
    verticalStack.addArrangedSubview(cardNumberFormRow)
    verticalStack.addArrangedSubview(horizontalStack)

    view.addSubview(cardView)
    view.addSubview(verticalStack)
    view.addSubview(nextButton)

    cardView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(cardView.snp.width).multipliedBy(0.64526)
    }

    verticalStack.snp.makeConstraints {
      $0.top.equalTo(cardView.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
    }

    nextButton.snp.makeConstraints {
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
      $0.height.equalTo(60)
    }

    viewModel.output.name
      .bind(to: self.cardView.rx.name)
      .disposed(by: rx.disposeBag)

    viewModel.output.ctaButtonText
      .bind(to: self.nextButton.textLabel.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithValidDate
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "유효기간 에러", message: "입력값이 올바르지 않습니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithPassword
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "비밀번호 에러", message: "입력값이 올바르지 않습니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didSaveSuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "카드등록 성공", message: "카드가 정상적으로 등록되었습니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.dismiss(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didSaveUnsuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "카드등록 실패", message: "카드 등록 중 문제가 발생하였습니다. 다시 시도해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
      }).disposed(by: rx.disposeBag)

    nextButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.requestValidate.accept((cardNumber: owner.cardNumberField.cardNumber(),
                                                      validMonth: owner.dateField.validDate().month,
                                                      validYear: owner.dateField.validDate().year,
                                                      password: owner.passwordField.password()))
      }).disposed(by: rx.disposeBag)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

}
