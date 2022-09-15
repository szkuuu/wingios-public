//
//  ChargePortModifyViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/06.
//

protocol ChargePortModifyInputable: ViewModelInputable {

  var tapOption0: PublishRelay<Void> { get }
  var tapOption1: PublishRelay<Void> { get }
  var tapNextButton: PublishRelay<CTAButton.Condition> { get }

}

protocol ChargePortModifyOutputable: ViewModelOutputable {

  var changeOption: BehaviorRelay<(Bool, Bool)> { get }
  var changeNextButtonCondition: BehaviorRelay<CTAButton.Condition> { get }
  var didTapNextButton: PublishRelay<(port: WSPortTypeIdentifier, voltage: Double, ampere: Double)> { get }

}

class ChargePortModifyInput: ChargePortModifyInputable {

  var tapOption0 = PublishRelay<Void>()
  var tapOption1 = PublishRelay<Void>()
  var tapNextButton = PublishRelay<CTAButton.Condition>()

}

class ChargePortModifyOutput: ChargePortModifyOutputable {

  var changeOption = BehaviorRelay<(Bool, Bool)>(value: (false, false))
  var changeNextButtonCondition = BehaviorRelay<CTAButton.Condition>(value: .inactive)
  var didTapNextButton = PublishRelay<(port: WSPortTypeIdentifier, voltage: Double, ampere: Double)>()

}

class ChargePortModifyViewModel: ViewModel<ChargePortModifyInput, ChargePortModifyOutput> {

  private let optionStream = BehaviorRelay<(Bool, Bool)>(value: (false, false))

  let portStream = BehaviorRelay<(port: WSPortTypeIdentifier, voltage: Double, ampere: Double)>(value: (port: .none, voltage: 0.0, ampere: 0.0))

  override func bind() {
    self.input.tapOption0
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.optionStream.accept((true, false))
        owner.portStream.accept((port: .gx, voltage: owner.portStream.value.voltage, ampere: owner.portStream.value.ampere))
      }).disposed(by: rx.disposeBag)

    self.input.tapOption1
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.optionStream.accept((false, true))
        owner.portStream.accept((port: .dc8, voltage: owner.portStream.value.voltage, ampere: owner.portStream.value.ampere))
      }).disposed(by: rx.disposeBag)

    self.input.tapNextButton
      .withUnretained(self)
      .subscribe(onNext: { owner, condition in
        switch condition {
        case .normal:
          owner.output.didTapNextButton.accept((owner.portStream.value))
        default:
          break
        }
      }).disposed(by: rx.disposeBag)

    self.optionStream
      .bind(to: self.output.changeOption)
      .disposed(by: rx.disposeBag)

    self.optionStream
      .map { $0 || $1 }
      .map { (satisfied: Bool) -> CTAButton.Condition in
        satisfied ? .normal : .inactive
      }
      .bind(to: self.output.changeNextButtonCondition)
      .disposed(by: rx.disposeBag)

    self.portStream
      .map { $0.port }
      .withUnretained(self)
      .subscribe(onNext: { owner, portType in
        switch portType {
        case .gx:
          owner.optionStream.accept((true, false))
        case .dc8:
          owner.optionStream.accept((false, true))
        case .none:
          owner.optionStream.accept((false, false))
        }
      }).disposed(by: rx.disposeBag)
  }

}
