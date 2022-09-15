//
//  StateViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/03.
//

import UIKit

class StateViewController: UIViewController {

  private lazy var indicatorLabel: UILabel = UILabel().then {
    $0.text = "Not found"
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .black.withAlphaComponent(0.45)
  }

  private lazy var batteryImageView: UIImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = .init(named: "")
  }

  private lazy var bottomContainerView: UIView = UIView().then {
    $0.layer.cornerRadius = 24.0
    $0.backgroundColor = .systemBackground
  }

  private lazy var addressRow: AddressCell = AddressCell().then {
    $0.configure(with: .init(logo: .init(named: "pin.yellow"), road: "Wing 1st Station", lotNumber: "Lorem Ipsum"))
  }

  private lazy var stateTimeCard: StateTimeCard = StateTimeCard(image: .init(named: "charge.battery.off"), title: "이용시간", detail: "00:00:00")

  private lazy var stateChargeCard: StateChargeCard = StateChargeCard(circle: {
    CircleTemplate(background: .init(named: "circle.volt"), text: "0 V")
  }, title: "충전상태", detail: "-")

  private lazy var cardStack: UIStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 18.0
    $0.distribution = .fillEqually
  }

  private lazy var completeButton: CTAButton = CTAButton(text: "충전 완료")

  let viewModel = StateViewModel(input: StateInput(), output: StateOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemYellow

    cardStack.addArrangedSubview(stateTimeCard)
    cardStack.addArrangedSubview(stateChargeCard)

    bottomContainerView.addSubview(addressRow)
    bottomContainerView.addSubview(cardStack)
    bottomContainerView.addSubview(completeButton)

    view.addSubview(bottomContainerView)
    view.addSubview(indicatorLabel)
    view.addSubview(batteryImageView)

    bottomContainerView.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(view.snp.height).multipliedBy(0.628079)
    }
    addressRow.snp.makeConstraints {
      $0.top.equalToSuperview().offset(24)
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.height.equalTo(addressRow.sizeThatFits(.init(width: addressRow.bounds.width,
                                                      height: .greatestFiniteMagnitude)))
    }
    cardStack.snp.makeConstraints {
      $0.top.equalTo(addressRow.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.height.equalTo(cardStack.snp.width).multipliedBy(0.59939)
    }
    completeButton.snp.makeConstraints {
      $0.top.equalTo(cardStack.snp.bottom).offset(24)
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.height.equalTo(60)
    }
    indicatorLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
      $0.centerX.equalToSuperview()
    }
    batteryImageView.snp.makeConstraints {
      $0.top.equalTo(indicatorLabel.snp.bottom).offset(28)
      $0.height.equalTo(view.snp.height).multipliedBy(0.0936)
      $0.centerX.equalToSuperview()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    completeButton.rx
      .tapGesture()
      .when(.recognized)
      .map { [weak self] _ in self?.completeButton.condition ?? .inactive }
      .bind(to: viewModel.input.tapCompleteButton)
      .disposed(by: rx.disposeBag)
    
    viewModel.output.voltage
      .bind(to: self.stateChargeCard.upperCircle.rx.subscript)
      .disposed(by: rx.disposeBag)

    viewModel.output.circleTintColor
      .bind(to: self.stateChargeCard.upperCircle.rx.backgroundTintColor)
      .disposed(by: rx.disposeBag)

    viewModel.output.indicator
      .bind(to: self.indicatorLabel.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.batteryImage
      .bind(to: self.batteryImageView.rx.image)
      .disposed(by: rx.disposeBag)

    viewModel.output.addressHidden
      .withUnretained(self)
      .subscribe(onNext: { owner, isHidden in
        owner.addressRow.isHidden = isHidden
        owner.cardStack.snp.remakeConstraints {
          if isHidden {
            $0.top.equalToSuperview().offset(40)
          } else {
            $0.top.equalTo(owner.addressRow.snp.bottom).offset(16)
          }
          $0.leading.equalToSuperview().offset(24)
          $0.trailing.equalToSuperview().offset(-24)
          $0.height.equalTo(owner.cardStack.snp.width).multipliedBy(0.59939)
        }
      }).disposed(by: rx.disposeBag)

    viewModel.output.timeCardImage
      .bind(to: self.stateTimeCard.rx.upperImage)
      .disposed(by: rx.disposeBag)

    viewModel.output.stationName
      .bind(to: self.addressRow.rx.roadAddress)
      .disposed(by: rx.disposeBag)

    viewModel.output.stationAddress
      .bind(to: self.addressRow.rx.lotNumberAddress)
      .disposed(by: rx.disposeBag)

    viewModel.output.useTime
      .distinctUntilChanged()
      .bind(to: self.stateTimeCard.rx.detailText)
      .disposed(by: rx.disposeBag)

    viewModel.output.chargeDetail
      .bind(to: self.stateChargeCard.rx.detailText)
      .disposed(by: rx.disposeBag)

    viewModel.output.completeButtonCondition
      .bind(to: self.completeButton.rx.condition)
      .disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithNetworking
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "충전상태 에러", message: "네트워크 상태를 다시 한 번 확인해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithPayment
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "결제 에러", message: "결제가 완료되지 않았습니다. 다시 시도해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTapCompleteButton
      .withUnretained(self)
      .subscribe(onNext: { owner, property in
        owner.present(BillViewController().then {
          $0.viewModel.billProperty = property
          $0.modalPresentationStyle = .fullScreen
        }, animated: true)
      }).disposed(by: rx.disposeBag)

    viewModel.input.appearSignal.accept(())
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    viewModel.input.disappearSignal.accept(())

    var mutatingSelf = self
    mutatingSelf.rx.disposeBag = DisposeBag()
  }

}
