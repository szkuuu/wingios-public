//
//  StateViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/08.
//

import SwiftDate

protocol StateInputable: ViewModelInputable {

  var appearSignal: PublishRelay<Void> { get }
  var disappearSignal: PublishRelay<Void> { get }
  var injectUsage: BehaviorRelay<WSStructure.UsageProperty?> { get }
  var injectVoltage: BehaviorRelay<Double> { get }
  var tapCompleteButton: PublishRelay<CTAButton.Condition> { get }

}

protocol StateOutputable: ViewModelOutputable {

  var voltage: BehaviorRelay<String> { get }
  var circleTintColor: BehaviorRelay<UIColor> { get }
  var indicator: BehaviorRelay<String> { get }
  var batteryImage: BehaviorRelay<UIImage?> { get }
  var addressHidden: BehaviorRelay<Bool> { get }
  var timeCardImage: BehaviorRelay<UIImage?> { get }
  var stationName: BehaviorRelay<String>  { get }
  var stationAddress: BehaviorRelay<String> { get }
  var useTime: BehaviorRelay<String> { get }
  var chargeDetail: BehaviorRelay<String> { get }
  var completeButtonCondition: BehaviorRelay<CTAButton.Condition> { get }
  var didOccurErrorWithNetworking: PublishRelay<Void> { get }
  var didOccurErrorWithPayment: PublishRelay<Void> { get }
  var didTapCompleteButton: PublishRelay<WSStructure.BillProperty> { get }

}

class StateInput: StateInputable {

  var appearSignal = PublishRelay<Void>()
  var disappearSignal = PublishRelay<Void>()
  var injectUsage = BehaviorRelay<WSStructure.UsageProperty?>(value: nil)
  var injectVoltage = BehaviorRelay<Double>(value: 0.0)
  var tapCompleteButton = PublishRelay<CTAButton.Condition>()

}

class StateOutput: StateOutputable {

  var voltage = BehaviorRelay<String>(value: "-")
  var circleTintColor = BehaviorRelay<UIColor>(value: .systemGray)
  var indicator = BehaviorRelay<String>(value: "-")
  var batteryImage = BehaviorRelay<UIImage?>(value: .init(named: "charging.none"))
  var addressHidden = BehaviorRelay<Bool>(value: true)
  var timeCardImage = BehaviorRelay<UIImage?>(value: .init(named: "charge.battery.off"))
  var stationName = BehaviorRelay<String>(value: "-")
  var stationAddress = BehaviorRelay<String>(value: "-")
  var useTime = BehaviorRelay<String>(value: "-")
  var chargeDetail = BehaviorRelay<String>(value: "-")
  var completeButtonCondition = BehaviorRelay<CTAButton.Condition>(value: .inactive)
  var didOccurErrorWithNetworking = PublishRelay<Void>()
  var didOccurErrorWithPayment = PublishRelay<Void>()
  var didTapCompleteButton = PublishRelay<WSStructure.BillProperty>()

}

class StateViewModel: ViewModel<StateInput, StateOutput> {

  private let feePerMinute = 0

  override func bind() {
    self.input.injectVoltage
      .distinctUntilChanged()
      .map { $0 > 0 ? "\(String(format: "%.2f", $0)) V" : "0 V" }
      .bind(to: self.output.voltage)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .map { $0 == nil ? UIColor.systemGray4 : UIColor.systemYellow }
      .bind(to: self.output.circleTintColor)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .map { $0 == nil }
      .bind(to: self.output.addressHidden)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .map { $0 == nil ? "충전중인 기기가 없습니다" : "현재 기기를 충전하고 있습니다" }
      .bind(to: self.output.indicator)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .map { $0 == nil ? UIImage(named: "charging.none") : UIImage(named: "charging.none") }
      .bind(to: self.output.batteryImage)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .map { $0 == nil }
      .bind(to: self.output.addressHidden)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .map { $0 == nil ? UIImage(named: "charge.battery.off") : UIImage(named: "charge.battery.on") }
      .bind(to: self.output.timeCardImage)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .filter { $0 == nil }
      .map { _ in "데이터 없음" }
      .bind(to: self.output.stationName)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .filter { $0 != nil }
      .map { $0! }
      .map { $0.stationName }
      .bind(to: self.output.stationName)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .filter { $0 == nil }
      .map { _ in "데이터 없음" }
      .bind(to: self.output.stationAddress)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .filter { $0 != nil }
      .map { $0! }
      .map { $0.stationAddress }
      .bind(to: self.output.stationAddress)
      .disposed(by: rx.disposeBag)

    Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
      .withUnretained(self)
      .map { owner, _ in owner.input.injectUsage.value?.start }
      .filter { $0 != nil }
      .map { $0! }
      .map { (date: Date) -> DateInRegion in
        return DateInRegion(date, region: .current)
      }
      .map { (startDateInRegion: DateInRegion) -> String in
        let nowDateInRegion = DateInRegion(Date(), region: .current)
        let intervalSeconds = startDateInRegion.getInterval(toDate: nowDateInRegion, component: .second)

        return Int(intervalSeconds).seconds.timeInterval.toString(options: {
          $0.allowedUnits = [.hour, .minute, .second]
          $0.unitsStyle = .positional
          $0.zeroFormattingBehavior = .pad
        })
      }
      .bind(to: self.output.useTime)
      .disposed(by: rx.disposeBag)

    Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
      .withUnretained(self)
      .map { owner, _ in owner.input.injectUsage.value?.start }
      .filter { $0 == nil }
      .map { _ in "-" }
      .bind(to: self.output.useTime)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .map { [weak self] in $0 == nil ? "-" : "충전중 (분당 \(self?.feePerMinute ?? 0)원)" }
      .bind(to: self.output.chargeDetail)
      .disposed(by: rx.disposeBag)

    self.input.injectUsage
      .map { $0 == nil ? CTAButton.Condition.inactive : CTAButton.Condition.normal }
      .bind(to: self.output.completeButtonCondition)
      .disposed(by: rx.disposeBag)

    self.input.appearSignal
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let realm = try! Realm()
        let token = realm.objects(UserStore.self).first?.token ?? ""
        var voltage: Double = 0.0

        WSLoadingIndicator.startLoad()
        WSNetwork.request(target: .getMyInfo(token: token)) { result in
          switch result {
          case .success(let json):
            if let result = json["result"].bool,
               result,
               json["charge"].exists(),
               let chargeVoltage = json["charge"]["voltage"].double {
              voltage = chargeVoltage
            }
          case .failure:
            break
          }

          WSNetwork.request(target: .chargeStatus(token: token)) { result in
            switch result {
            case .success(let json):
              print(json)
              if let result = json["result"].bool,
                 json["usage"].exists(),
                 json["usage"].type != .null,
                 result {
                let usage = json["usage"]

                let id = usage["id"].int ?? -1
                let userType = usage["user_type"].int ?? -1
                let userId = usage["user_id"].int ?? -1
                let stationId = usage["station_id"].int ?? -1
                let stationName = usage["station_name"].string ?? "-"
                let stationAddress = usage["station_address"].string ?? "-"
                let portId = usage["port_id"].int ?? -1
                let code = usage["code"].int ?? -1
                var date: Date? = nil
                var start: Date? = nil
                var chargeComplete: Date? = nil
                var end: Date? = nil
                if let dateString = usage["date"].string {
                  date = dateString.toISODate()?.date
                }
                if let startString = usage["start"].string {
                  start = startString.toISODate()?.date
                }
                if let chargeCompleteString = usage["charge_complete"].string {
                  chargeComplete = chargeCompleteString.toISODate()?.date
                }
                if let endString = usage["end"].string {
                  end = endString.toISODate()?.date
                }
                let kickboard = usage["kickboard"].int
                let status = usage["status"].int ?? -1

                let usageProperty: WSStructure.UsageProperty = .init(id: id,
                                                                     userType: userType,
                                                                     userId: userId,
                                                                     stationId: stationId,
                                                                     stationName: stationName,
                                                                     stationAddress: stationAddress,
                                                                     portId: portId,
                                                                     code: code,
                                                                     date: date,
                                                                     start: start,
                                                                     chargeComplete: chargeComplete,
                                                                     end: end,
                                                                     kickboard: kickboard,
                                                                     status: status)

                owner.input.injectUsage.accept(usageProperty)
                owner.input.injectVoltage.accept(voltage)
                WSLoadingIndicator.stopLoad()
              } else {
                owner.input.injectUsage.accept(nil)
                owner.input.injectVoltage.accept(0)
                WSLoadingIndicator.stopLoad()
              }
            case .failure:
              owner.input.injectUsage.accept(nil)
              owner.input.injectVoltage.accept(0)
              WSLoadingIndicator.stopLoad()
              owner.output.didOccurErrorWithNetworking.accept(())
            }
          }
        }
      }).disposed(by: rx.disposeBag)

    self.input.disappearSignal
      .map { _ -> WSStructure.UsageProperty? in nil }
      .bind(to: self.input.injectUsage)
      .disposed(by: rx.disposeBag)

    self.input.tapCompleteButton
      .filter {
        switch $0 {
        case .normal:
          return true
        default:
          return false
        }
      }
      .map { _ in () }
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        WSLoadingIndicator.startLoad()

        let realm = try! Realm()
        let token = realm.objects(UserStore.self).first?.token ?? ""
        let startTime = owner.input.injectUsage.value?.start ?? Date(timeIntervalSince1970: 0)
        let endTime = Date()
        let standardVoltage = 36
        let chargeSeconds = Int(DateInRegion(startTime, region: .current).getInterval(toDate: DateInRegion(endTime, region: .current), component: .second))
        let chargeMinutesAndSeconds = (chargeSeconds.seconds).timeInterval.toUnits([.minute, .second])
        let amount: CGFloat
        if let minute = chargeMinutesAndSeconds[.minute],
           let second = chargeMinutesAndSeconds[.second] {
          amount = CGFloat((second > 0 ? minute + 1 : minute) * owner.feePerMinute)
        } else {
          amount = -1
        }

        WSNetwork.request(target: .chargePayment(token: token, price: Int(amount))) { result in
          switch result {
          case .success(let json):
            print(json)
            if let result = json["result"].bool,
               json["info"].exists(),
               result {
              let info = json["info"]

              let stationName = info["station_name"].string ?? ""
              let portNumber = info["port"].int ?? -1

              WSLoadingIndicator.stopLoad()
              owner.output.didTapCompleteButton.accept(.init(stationName: stationName,
                                                             port: portNumber,
                                                             startTime: startTime,
                                                             endTime: endTime,
                                                             standardVoltage: standardVoltage,
                                                             amount: amount))
            } else {
              WSLoadingIndicator.stopLoad()
              owner.output.didOccurErrorWithPayment.accept(())
            }
            break
          case .failure:
            WSLoadingIndicator.stopLoad()
            owner.output.didOccurErrorWithPayment.accept(())
          }
        }
      }).disposed(by: rx.disposeBag)
  }
  
}
