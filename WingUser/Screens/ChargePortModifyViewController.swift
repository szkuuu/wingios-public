//
//  ChargePortModifyViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/06.
//

import UIKit

class ChargePortModifyViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>충전포트 수정</s24b>".wsAttributed
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

  let viewModel = ChargePortModifyViewModel(input: ChargePortModifyInput(), output: ChargePortModifyOutput())

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
      navigationItem.title = "충전포트 수정"
    }

    portStackView.addArrangedSubview(gxPortCell)
    portStackView.addArrangedSubview(dc8PortCell)

    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(portStackView)
    view.addSubview(nextButton)

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
      .subscribe(onNext: { owner, pack in
        owner.navigationController?.pushViewController(ChargeStandardModifyViewController().then {
          $0.viewModel.portStream.accept(pack)
        }, animated: true)
      }).disposed(by: rx.disposeBag)
  }

}
