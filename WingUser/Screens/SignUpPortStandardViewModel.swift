//
//  SignUpPortStandardViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/30.
//

protocol SignUpPortStandardInputable: ViewModelInputable {

  var injectVoltage: PublishRelay<String> { get }
  var injectAmpere: PublishRelay<String> { get }
  var tapNextButton: PublishRelay<CTAButton.Condition> { get }
  var tapLaterButton: PublishRelay<Void> { get }

}

protocol SignUpPortStandardOutputable: ViewModelOutputable {

  var formattedVoltage: BehaviorRelay<String> { get }
  var formattedAmpere: BehaviorRelay<String> { get }
  var changeNextButtonCondition: PublishRelay<CTAButton.Condition> { get }
  var didSignUpSuccessfully: PublishRelay<Void> { get }
  var didSignUpUnsuccessfully: PublishRelay<Void> { get }
  var didDoInvalid: PublishRelay<Void> { get }
  var didOccurWarningWithOutOfRange: PublishRelay<(category: WSConst.WarningCategory, message: String)> { get }

}

class SignUpPortStandardInput: SignUpPortStandardInputable {

  var injectVoltage = PublishRelay<String>()
  var injectAmpere = PublishRelay<String>()
  var tapNextButton = PublishRelay<CTAButton.Condition>()
  var tapLaterButton = PublishRelay<Void>()

}

class SignUpPortStandardOutput: SignUpPortStandardOutputable {

  var formattedVoltage = BehaviorRelay<String>(value: "")
  var formattedAmpere = BehaviorRelay<String>(value: "")
  var changeNextButtonCondition = PublishRelay<CTAButton.Condition>()
  var didSignUpSuccessfully = PublishRelay<Void>()
  var didSignUpUnsuccessfully = PublishRelay<Void>()
  var didDoInvalid = PublishRelay<Void>()
  var didOccurWarningWithOutOfRange = PublishRelay<(category: WSConst.WarningCategory, message: String)>()

}

class SignUpPortStandardViewModel: ViewModel<SignUpPortStandardInput, SignUpPortStandardOutput> {

  private let satisfiedStream = BehaviorRelay<Bool>(value: false)

  var userCache: UserCache?
  
  override func bind() {

    let satisfiedObservable = Observable.combineLatest(self.output.formattedVoltage,
                                              self.output.formattedAmpere) {
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
          WSLoadingIndicator.startLoad()

          if let userCache = owner.userCache {
            let uuid = UUID().uuidString
            WSNetwork.request(target: .loginJoin(identifier: uuid,
                                                 phone: userCache.phoneNumber,
                                                 lastName: userCache.lastName,
                                                 firstName: userCache.firstName,
                                                 email: userCache.email,
                                                 portType: userCache.portType,
                                                 portVoltage: Double(owner.output.formattedVoltage.value) ?? 0.0,
                                                 portAmpere: Double(owner.output.formattedAmpere.value) ?? 0.0)) { result in
              switch result {
              case .success(let json):
                if let result = json["result"].bool,
                   let token = json["token"].string,
                   result {
                  let realm = try! Realm()
                  if let userStore = realm.objects(UserStore.self).first {
                    try! realm.write {
                      userStore.token = token
                      userStore.identifier = uuid
                    }
                    WSLoadingIndicator.stopLoad()
                    owner.output.didSignUpSuccessfully.accept(())
                  } else {
                    WSLoadingIndicator.stopLoad()
                    owner.output.didDoInvalid.accept(())
                  }
                } else {
                  WSLoadingIndicator.stopLoad()
                  owner.output.didSignUpUnsuccessfully.accept(())
                }
              case .failure:
                WSLoadingIndicator.stopLoad()
                owner.output.didSignUpUnsuccessfully.accept(())
              }
            }
          }
        default:
          break
        }
      }).disposed(by: rx.disposeBag)

    self.input.tapLaterButton
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        print(owner.userCache?.portType)
        WSLoadingIndicator.startLoad()

        if let userCache = owner.userCache {
          let uuid = UUID().uuidString
          WSNetwork.request(target: .loginJoin(identifier: uuid,
                                               phone: userCache.phoneNumber,
                                               lastName: userCache.lastName,
                                               firstName: userCache.firstName,
                                               email: userCache.email,
                                               portType: userCache.portType,
                                               portVoltage: nil,
                                               portAmpere: nil)) { result in
            switch result {
            case .success(let json):
              if let result = json["result"].bool,
                 let token = json["token"].string,
                 result {
                print(token)
                let realm = try! Realm()
                if let userStore = realm.objects(UserStore.self).first {
                  try! realm.write {
                    userStore.token = token
                    userStore.identifier = uuid
                  }
                  WSLoadingIndicator.stopLoad()
                  owner.output.didSignUpSuccessfully.accept(())
                } else {
                  WSLoadingIndicator.stopLoad()
                  owner.output.didDoInvalid.accept(())
                }
              } else {
                WSLoadingIndicator.stopLoad()
                owner.output.didSignUpUnsuccessfully.accept(())
              }
            case .failure:
              WSLoadingIndicator.stopLoad()
              owner.output.didSignUpUnsuccessfully.accept(())
            }
          }
        }
      }).disposed(by: rx.disposeBag)

    satisfiedObservable.map { (satisfied: Bool) -> CTAButton.Condition in
      satisfied ? .normal : .inactive
    }
    .bind(to: self.output.changeNextButtonCondition)
    .disposed(by: rx.disposeBag)
  }

}
