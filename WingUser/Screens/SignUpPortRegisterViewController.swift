//
//  SignUpPortRegisterViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/10.
//

import UIKit

class SignUpPortRegisterViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>충전포트 등록</s24b>".wsAttributed
  }

  private lazy var subtitleLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.attributedText = "<s14>소지하고 계신 충전기의 포트를 선택해 주세요.</s14>".wsAttributed
  }

  private lazy var gxPortCell: PortCell = PortCell().then {
    $0.configure(with: .init(portImage: .init(named: "port.gx")))
  }

  private lazy var dc8PortCell: PortCell = PortCell().then {
    $0.configure(with: .init(portImage: .init(named: "port.dc8")))
  }

  private lazy var portStackView: UIStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 0
    $0.distribution = .fillEqually
  }

  private lazy var nextButton: CTAButton = CTAButton(text: "다음")

  private lazy var laterButton: CTAButton = CTAButton(text: "나중에 등록할게요", condition: .option(lightForced: false))

  let viewModel = SignUpPortRegisterViewModel(input: SignUpPortRegisterInput(), output: SignUpPortRegisterOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    portStackView.addArrangedSubview(gxPortCell)
    portStackView.addArrangedSubview(dc8PortCell)

    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(portStackView)
    view.addSubview(nextButton)
    view.addSubview(laterButton)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(57)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(5)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    portStackView.snp.makeConstraints {
      $0.top.equalTo(subtitleLabel.snp.bottom).offset(50)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(UIScreen.main.bounds.height * 0.21)
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

    gxPortCell.checkButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapOption0.accept(())
      }).disposed(by: rx.disposeBag)

    dc8PortCell.checkButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapOption1.accept(())
      }).disposed(by: rx.disposeBag)

    nextButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapNextButton.accept(owner.nextButton.condition ?? .inactive)
      }).disposed(by: rx.disposeBag)

    laterButton.rx
      .tapGesture()
      .when(.recognized)
      .map { _ in () }
      .bind(to: self.viewModel.input.tapLaterButton)
      .disposed(by: rx.disposeBag)

    viewModel.output.changeOption
      .map { $0.0 }
      .bind(to: self.gxPortCell.rx.isChecked)
      .disposed(by: rx.disposeBag)

    viewModel.output.changeOption
      .map { $0.1 }
      .bind(to: self.dc8PortCell.rx.isChecked)
      .disposed(by: rx.disposeBag)

    viewModel.output.changeNextButtonCondition
      .bind(to: self.nextButton.rx.condition)
      .disposed(by: rx.disposeBag)

    viewModel.output.didTapNextButton
      .withUnretained(self)
      .subscribe(onNext: { owner, portType in
        owner.navigationController?.pushViewController(SignUpPortStandardViewController().then { [weak owner = owner] in
          if let userCache = owner?.viewModel.userCache {
            $0.viewModel.userCache = userCache.move(portType: portType)
          }
        }, animated: true)
      }).disposed(by: rx.disposeBag)

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
  }

}
