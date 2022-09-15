//
//  BillViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/17.
//

import UIKit

class BillViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b><black>결제가 완료되었습니다!</black></s24b>".wsAttributed
  }

  private lazy var subtitleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s14><black>윙스테이션을 이용해주셔서 감사합니다 :)</black></s14>".wsAttributed
  }

  private lazy var billPaper: BillPaper = BillPaper(place: "-",
                                                    port: -1,
                                                    start: Date(),
                                                    end: Date(),
                                                    howMuch: 0,
                                                    unit: "원")

  private lazy var homeButton: CTAButton = CTAButton(text: "흠으로 가기", condition: .option(lightForced: true))

  let viewModel = BillViewModel(input: BillInput(), output: BillOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemYellow

    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(billPaper)
    view.addSubview(homeButton)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(4)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    billPaper.snp.makeConstraints {
      $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(billPaper.snp.width).multipliedBy(1.2274)
    }
    homeButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(60)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    homeButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.dismiss(animated: true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.place
      .bind(to: self.billPaper.rx.whereis)
      .disposed(by: rx.disposeBag)

    viewModel.output.port
      .bind(to: self.billPaper.rx.port)
      .disposed(by: rx.disposeBag)

    viewModel.output.startDate
      .bind(to: self.billPaper.rx.startTime)
      .disposed(by: rx.disposeBag)

    viewModel.output.endDate
      .bind(to: self.billPaper.rx.endTime)
      .disposed(by: rx.disposeBag)

    viewModel.output.amount
      .bind(to: self.billPaper.rx.amount)
      .disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithNothingBill
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "결제 에러", message: "결제 정보를 불러오지 못했습니다. 이전 화면으로 이동합니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.dismiss(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.input.appearSignal.accept(())
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    var mutatingSelf = self
    mutatingSelf.rx.disposeBag = DisposeBag()
  }

}
