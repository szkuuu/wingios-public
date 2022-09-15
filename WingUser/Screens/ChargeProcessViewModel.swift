//
//  ChargeProcessViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/06.
//

typealias ChargeConditionPack = (simpleGuide: String,
                                 simpleGuideColor: UIColor,
                                 portTintColor: UIColor,
                                 detailGuide: String,
                                 closeButtonHidden: Bool)

protocol ChargeProcessInputable: ViewModelInputable {

  var appearSignal: PublishRelay<Void> { get }
  var disappearSignal: PublishRelay<Void> { get }

}

protocol ChargeProcessOutputable: ViewModelOutputable {

  var fakeText: BehaviorRelay<String> { get }
  var portText: BehaviorRelay<String> { get }
  var portImage: BehaviorRelay<UIImage?> { get }
  var isChargeNow: BehaviorRelay<ChargeConditionPack> { get }
  var didChargeCancel: PublishRelay<Void> { get }
  var didOccurErrorWithNetworking: PublishRelay<Void> { get }
  var didOccurErrorWithPortReady: PublishRelay<Void> { get }
  var didOccurErrorWithPortCancel: PublishRelay<Void> { get }
  var didOccurErrorWithLoginFailure: PublishRelay<Void> { get }

}

class ChargeProcessInput: ChargeProcessInputable {

  var appearSignal = PublishRelay<Void>()
  var disappearSignal = PublishRelay<Void>()

}

class ChargeProcessOutput: ChargeProcessOutputable {

  var fakeText = BehaviorRelay<String>(value: "-")
  var portText = BehaviorRelay<String>(value: "-")
  var portImage = BehaviorRelay<UIImage?>(value: .init(named: "port.head.none"))
  var isChargeNow = BehaviorRelay<ChargeConditionPack>(value: (simpleGuide: "-",
                                                               simpleGuideColor: .clear,
                                                               portTintColor: .systemGray4,
                                                               detailGuide: "-",
                                                               closeButtonHidden: true))
  var didChargeCancel = PublishRelay<Void>()
  var didOccurErrorWithNetworking = PublishRelay<Void>()
  var didOccurErrorWithPortReady = PublishRelay<Void>()
  var didOccurErrorWithPortCancel = PublishRelay<Void>()
  var didOccurErrorWithLoginFailure = PublishRelay<Void>()
}

class ChargeProcessViewModel: ViewModel<ChargeProcessInput, ChargeProcessOutput> {

  private let chargeStream = BehaviorRelay<Bool>(value: false)

  var stationProperty: WSStructure.StationInformationProperty?

  var portType: WSPortTypeIdentifier = .none

  override func bind() {
    self.input.appearSignal
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.output.fakeText.accept(owner.stationProperty?.stationName ?? "-")
        owner.output.portText.accept("\(owner.stationProperty?.portNumber ?? 0)번 포트")

        let portImage: UIImage?
        switch owner.portType {
        case .gx:
          portImage = .init(named: "port.head.gx")
        case .dc8:
          portImage = .init(named: "port.head.dc8")
        case .none:
          portImage = .init(named: "port.head.none")
        }
        owner.output.portImage.accept(portImage)
      }).disposed(by: rx.disposeBag)

    self.input.appearSignal
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        WSSocketCenter.sharedV2.on(clientEvent: .connect) { _, _ in
          let realm = try! Realm()
          let token = realm.objects(UserStore.self).first?.token ?? ""
          WSSocketCenter.sharedV2.emit(for: .login, with: JSON(["token": token, "type": "user"]).rawString() ?? "")
        }
        WSSocketCenter.sharedV2.on(clientEvent: .error) { _, _ in
          owner.output.didOccurErrorWithNetworking.accept(())
        }
        WSSocketCenter.sharedV2.on(.chargeStart) { _, _ in
          owner.chargeStream.accept(true)
        }
        WSSocketCenter.sharedV2.on(.chargeCancel) { _, _ in
          owner.output.didChargeCancel.accept(())
        }
        WSSocketCenter.sharedV2.on(.result) { any, _ in
          guard let anyValue = any.first else {
            return
          }

          let json = JSON(anyValue)
          if let code = json["code"].string,
             let data = json["data"].bool {

            switch code {
            case "port_ready":
              if !data {
                owner.output.didOccurErrorWithPortReady.accept(())
              }
            case "port_cancel":
              if !data {
                owner.output.didOccurErrorWithPortCancel.accept(())
              }
            case "login":
              if data {
                if let stationProperty = owner.stationProperty {
                  WSSocketCenter.sharedV2.emit(for: .portReady, with: JSON([
                    "station_id": stationProperty.stationCode,
                    "port_numb": stationProperty.portNumber
                  ]).rawString() ?? "")
                }
              } else {
                owner.output.didOccurErrorWithLoginFailure.accept(())
              }
            default:
              break
            }
          }
        }

        WSSocketCenter.sharedV2.openClient()
      }).disposed(by: rx.disposeBag)

    self.input.disappearSignal
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        WSSocketCenter.sharedV2.offAll()
        WSSocketCenter.sharedV2.closeClient()
      }).disposed(by: rx.disposeBag)

    self.chargeStream
      .map { (isCharging: Bool) -> ChargeConditionPack in
        if isCharging {
          return (simpleGuide: """
킥보드와 충전단자가
정상적으로 연결되었습니다
""",
                  simpleGuideColor: UIColor.label,
                  portTintColor: UIColor.systemYellow,
                  detailGuide: "아래 닫기 버튼을 눌러주십시오.",
                  closeButtonHidden: false)
        } else {
          return (simpleGuide: "킥보드와 충전단자를 연결해주세요",
                  simpleGuideColor: UIColor.secondaryLabel,
                  portTintColor: UIColor.systemGray4,
                  detailGuide: "킥보드 연결을 기다리는 중입니다...",
                  closeButtonHidden: true)
        }
      }
      .bind(to: self.output.isChargeNow)
      .disposed(by: rx.disposeBag)
  }

}
