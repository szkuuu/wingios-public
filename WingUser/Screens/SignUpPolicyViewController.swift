//
//  SignUpPolicyViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/08.
//

import UIKit

class SignUpPolicyViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>약관동의</s24b>".wsAttributed
    $0.setContentHuggingPriority(.required, for: .vertical)
    $0.setContentCompressionResistancePriority(.required, for: .vertical)
  }

  private lazy var allAcceptCell: PolicyRowCell = PolicyRowCell().then {
    $0.configure(with: .init(attributedString: "<s18b>전체 약관동의</s18b>".wsAttributed))
  }

  private lazy var dividerCell: DividerCell = DividerCell().then {
    $0.configure(with: .init())
  }

  private lazy var serviceCell: PolicyRowCell = PolicyRowCell().then {
    $0.configure(with: .init(attributedString: "<s16>서비스 이용약관 동의</s16>".wsAttributed, rightView: {
      UIButton().then { button in
        button.setTitle("보기", for: .normal)
        button.setTitleColor(.systemOrange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0)
      }
    }))
  }

  private lazy var personalCell: PolicyRowCell = PolicyRowCell().then {
    $0.configure(with: .init(attributedString: "<s16>개인정보 취급 정책 동의</s16>".wsAttributed, rightView: {
      UIButton().then { button in
        button.setTitle("보기", for: .normal)
        button.setTitleColor(.systemOrange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0)
      }
    }))
  }

  private lazy var locationCell: PolicyRowCell = PolicyRowCell().then {
    $0.configure(with: .init(attributedString: "<s16>위치기반 서비스 이용약관 동의</s16>".wsAttributed, rightView: {
      UIButton().then { button in
        button.setTitle("보기", for: .normal)
        button.setTitleColor(.systemOrange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0)
      }
    }))
  }

  private lazy var cellStackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 20.0
    $0.distribution = .fill
    $0.setContentHuggingPriority(.defaultLow, for: .vertical)
  }

  private lazy var nextButton: CTAButton = CTAButton(text: "다음", condition: .inactive)

  let viewModel = SignUpPolicyViewModel(input: SignUpPolicyInput(), output: SignUpPolicyOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    cellStackView.addArrangedSubview(allAcceptCell)
    cellStackView.addArrangedSubview(dividerCell)
    cellStackView.addArrangedSubview(serviceCell)
    cellStackView.addArrangedSubview(personalCell)
    cellStackView.addArrangedSubview(locationCell)

    view.addSubview(titleLabel)
    view.addSubview(cellStackView)
    view.addSubview(nextButton)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(57)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    cellStackView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(locationCell.snp.bottom)
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
    
    allAcceptCell.checkButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapOptionAll.accept(owner.allAcceptCell.isChecked ?? false)
      }).disposed(by: rx.disposeBag)

    serviceCell.checkButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapOption0.accept(owner.serviceCell.isChecked ?? false)
      }).disposed(by: rx.disposeBag)

    serviceCell.rightView?.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapRightView.accept(URL(string: "about:blank"))
      }).disposed(by: rx.disposeBag)

    personalCell.checkButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapOption1.accept(owner.personalCell.isChecked ?? false)
      }).disposed(by: rx.disposeBag)

    personalCell.rightView?.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapRightView.accept(URL(string: "about:blank"))
      }).disposed(by: rx.disposeBag)

    locationCell.checkButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapOption2.accept(owner.locationCell.isChecked ?? false)
      }).disposed(by: rx.disposeBag)

    locationCell.rightView?.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapRightView.accept(URL(string: "about:blank"))
      }).disposed(by: rx.disposeBag)

    viewModel.output.changeAllOption
      .bind(to: self.allAcceptCell.rx.isChecked)
      .disposed(by: rx.disposeBag)

    viewModel.output.changeSubOptions
      .map { $0.0 }
      .bind(to: self.serviceCell.rx.isChecked)
      .disposed(by: rx.disposeBag)

    viewModel.output.changeSubOptions
      .map { $0.1 }
      .bind(to: self.personalCell.rx.isChecked)
      .disposed(by: rx.disposeBag)

    viewModel.output.changeSubOptions
      .map { $0.2 }
      .bind(to: self.locationCell.rx.isChecked)
      .disposed(by: rx.disposeBag)

    viewModel.output.changeNextButtonCondition
      .bind(to: self.nextButton.rx.condition)
      .disposed(by: rx.disposeBag)

    viewModel.output.didTapNextButton
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.navigationController?.pushViewController(SignUpRequiredViewController().then { [weak self] in
          if let userCache = self?.viewModel.userCache {
            $0.viewModel.userCache = userCache.move(marketing: false)
          }
        }, animated: true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTapRightView
      .withUnretained(self)
      .subscribe(onNext: { owner, url in
        owner.present(WebViewController(url: url), animated: true)
      }).disposed(by: rx.disposeBag)

  }

}
