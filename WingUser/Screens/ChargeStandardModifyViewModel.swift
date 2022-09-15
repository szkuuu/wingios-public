//
//  ChargeStandardModifyViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/06.
//

protocol ChargeStandardModifyInputable: ViewModelInputable {

  var injectVoltage: PublishRelay<String> { get }
  var injectAmpere: PublishRelay<String> { get }
  var tapNextButton: PublishRelay<CTAButton.Condition> { get }

}

protocol ChargeStandardModifyOutputable: ViewModelOutputable {

  var formattedVoltage: BehaviorRelay<String> { get }
  var formattedAmpere: BehaviorRelay<String> { get }
  var changeNextButtonCondition: BehaviorRelay<CTAButton.Condition> { get }
  var didSaveSuccessfully: PublishRelay<Void> { get }
  var didSaveUnsuccessfully: PublishRelay<Void> { get }
  var didOccurWarningWithOutOfRange: PublishRelay<(category: WSConst.WarningCategory, message: String)> { get }
  
}

class ChargeStandardModifyInput: ChargeStandardModifyInputable {

  var injectVoltage = PublishRelay<String>()
  var injectAmpere = PublishRelay<String>()
  var tapNextButton = PublishRelay<CTAButton.Condition>()

}

class ChargeStandardModifyOutput: ChargeStandardModifyOutputable {

  var formattedVoltage = BehaviorRelay<String>(value: "")
  var formattedAmpere = BehaviorRelay<String>(value: "")
  var changeNextButtonCondition = BehaviorRelay<CTAButton.Condition>(value: .inactive)
  var didSaveSuccessfully = PublishRelay<Void>()
  var didSaveUnsuccessfully = PublishRelay<Void>()
  var didOccurWarningWithOutOfRange = PublishRelay<(category: WSConst.WarningCategory, message: String)>()

}

class ChargeStandardModifyViewModel: ViewModel<ChargeStandardModifyInput, ChargeStandardModifyOutput> {

  let portStream = BehaviorRelay<(port: WSPortTypeIdentifier, voltage: Double, ampere: Double)>(value: (port: .none, voltage: 0.0, ampere: 0.0))
  
  override func bind() {
    let satisfiedObservable = Observable.combineLatest(self.input.injectVoltage,
                                                       self.input.injectAmpere) {
      ((Double($0) ?? 0.0) > 0) && ((Double($1) ?? 0.0) > 0)
    }

    self.input.injectVoltage
      .filter { !$0.isEmpty }
      .map { Double($0) ?? 0.0 }
      .map { (($0 * 100).rounded(.up)) / 100 }
      .map { String(format: "%.2f", $0) }
      .bind(to: self.output.formattedVoltage)
      .disposed(by: rx.disposeBag)

    self.input.injectAmpere
      .filter { !$0.isEmpty }
      .map { Double($0) ?? 0.0 }
      .map { (($0 * 10).rounded(.up)) / 10 }
      .map { String(format: "%.1f", $0) }
      .bind(to: self.output.formattedAmpere)
      .disposed(by: rx.disposeBag)

    self.input.injectVoltage
      .filter { !$0.isEmpty }
      .map { Double($0) ?? 0.0 }
      .filter { $0 > WSConst.voltageLimit }
      .map { _ in (WSConst.WarningCategory.voltage, "\(WSConst.voltageLimit) V 를 초과하는 전압은 지원하지 않습니다. 양해 바랍니다.") }
      .bind(to: self.output.didOccurWarningWithOutOfRange)
      .disposed(by: rx.disposeBag)

    self.input.injectAmpere
      .filter { !$0.isEmpty }
      .map { Double($0) ?? 0.0 }
      .filter { $0 > WSConst.ampereLimit }
      .map { _ in (WSConst.WarningCategory.ampere, "\(WSConst.ampereLimit) A 를 초과하는 전류는 지원하지 않습니다. 양해 바랍니다.") }
      .bind(to: self.output.didOccurWarningWithOutOfRange)
      .disposed(by: rx.disposeBag)

    self.input.tapNextButton
      .withUnretained(self)
      .subscribe(onNext: { owner, condition in
        switch condition {
        case .normal:
          let realm = try! Realm()
          let token = realm.objects(UserStore.self).first?.token ?? ""
          let portType = owner.portStream.value.port

          WSLoadingIndicator.startLoad()
          WSNetwork.request(target: .userInfoChargeSpec(token: token,
                                                        portType: portType,
                                                        portVoltage: Double(owner.output.formattedVoltage.value),
                                                        portAmpere: Double(owner.output.formattedAmpere.value)
                                                       )) { result in
            switch result {
            case .success(let json):
              if let result = json["result"].bool,
                 result {
                WSLoadingIndicator.stopLoad()
                owner.output.didSaveSuccessfully.accept(())
              } else {
                WSLoadingIndicator.stopLoad()
                owner.output.didSaveUnsuccessfully.accept(())
              }
            case .failure:
              WSLoadingIndicator.stopLoad()
              owner.output.didSaveUnsuccessfully.accept(())
            }
          }
        default:
          break
        }
      }).disposed(by: rx.disposeBag)

    self.portStream
      .map { $0.voltage }
      .filter { $0 > 0.0 }
      .map { String($0) }
      .bind(to: self.input.injectVoltage)
      .disposed(by: rx.disposeBag)

    self.portStream
      .map { $0.ampere }
      .filter { $0 > 0.0 }
      .map { String($0) }
      .bind(to: self.input.injectAmpere)
      .disposed(by: rx.disposeBag)

    satisfiedObservable
      .map { (satisfied: Bool) -> CTAButton.Condition in
        satisfied ? .normal : .inactive
      }
      .bind(to: self.output.changeNextButtonCondition)
      .disposed(by: rx.disposeBag)
  }

}
