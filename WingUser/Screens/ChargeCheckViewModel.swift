//
//  ChargeCheckViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/06.
//

protocol ChargeCheckInputable: ViewModelInputable {

  var appearSignal: PublishRelay<Void> { get }
  var tapCheckButton: PublishRelay<Void> { get }
  var tapChangeButton: PublishRelay<Void> { get }
  var tapCompabilityButton: PublishRelay<Void> { get }

}

protocol ChargeCheckOutputable: ViewModelOutputable {

  var didFetchUserPortSuccessfully: PublishRelay<(WSPortTypeIdentifier, Double, Double)> { get }
  var didFetchUserPortUnsuccessfully: PublishRelay<Void> { get }
  var didOccurErrorWithNetworking: PublishRelay<Void> { get }
  var didTapCheckButton: PublishRelay<(property: WSStructure.StationInformationProperty?, portType: WSPortTypeIdentifier)> { get }
  var didTapChageButton: PublishRelay<(WSPortTypeIdentifier, Double, Double)> { get }
  var didTapCompabilityButton: PublishRelay<Void> { get }

}

class ChargeCheckInput: ChargeCheckInputable {

  var appearSignal = PublishRelay<Void>()
  var tapCheckButton = PublishRelay<Void>()
  var tapChangeButton = PublishRelay<Void>()
  var tapCompabilityButton = PublishRelay<Void>()

}

class ChargeCheckOutput: ChargeCheckOutputable {

  var didFetchUserPortSuccessfully = PublishRelay<(WSPortTypeIdentifier, Double, Double)>()
  var didFetchUserPortUnsuccessfully = PublishRelay<Void>()
  var didOccurErrorWithNetworking = PublishRelay<Void>()
  var didTapCheckButton = PublishRelay<(property: WSStructure.StationInformationProperty?, portType: WSPortTypeIdentifier)>()
  var didTapChageButton = PublishRelay<(WSPortTypeIdentifier, Double, Double)>()
  var didTapCompabilityButton = PublishRelay<Void>()

}

class ChargeCheckViewModel: ViewModel<ChargeCheckInput, ChargeCheckOutput> {

  var stationProperty: WSStructure.StationInformationProperty?

  private let userPortStream = BehaviorRelay<(WSPortTypeIdentifier, Double, Double)>(value: (.none, 0.0, 0.0))

  override func bind() {
    self.input.appearSignal
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let realm = try! Realm()
        let token = realm.objects(UserStore.self).first?.token ?? ""

        WSLoadingIndicator.startLoad()
        WSNetwork.request(target: .getMyInfo(token: token)) { result in
          switch result {
          case .success(let json):
            if let result = json["result"].bool,
               let portType = WSPortTypeIdentifier(rawValue: json["charge"]["type"].int ?? -1),
               let chargeVoltage = json["charge"]["voltage"].double,
               let chargeAmpere = json["charge"]["ampere"].double,
               result {
              WSLoadingIndicator.stopLoad()
              owner.userPortStream.accept((portType, chargeVoltage, chargeAmpere))
            } else {
              WSLoadingIndicator.stopLoad()
              owner.output.didFetchUserPortUnsuccessfully.accept(())
            }
          case .failure:
            WSLoadingIndicator.stopLoad()
            owner.output.didOccurErrorWithNetworking.accept(())
          }
        }
      }).disposed(by: rx.disposeBag)

    self.input.tapCheckButton
      .map { [weak self] _ in self?.userPortStream.value.0 }
      .map { $0 ?? .none }
      .map { [weak self] in (property: self?.stationProperty, portType: $0) }
      .bind(to: self.output.didTapCheckButton)
      .disposed(by: rx.disposeBag)

    self.input.tapChangeButton
      .map { [weak self] _ in self?.userPortStream.value }
      .map { $0 ?? (.none, 0.0, 0.0) }
      .bind(to: self.output.didTapChageButton)
      .disposed(by: rx.disposeBag)

    self.input.tapCompabilityButton
      .bind(to: self.output.didTapCompabilityButton)
      .disposed(by: rx.disposeBag)

    self.userPortStream
      .bind(to: self.output.didFetchUserPortSuccessfully)
      .disposed(by: rx.disposeBag)
  }

}
