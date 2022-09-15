//
//  SignUpPortRegisterViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/30.
//

protocol SignUpPortRegisterInputable: ViewModelInputable {

  var tapOption0: PublishRelay<Void> { get }
  var tapOption1: PublishRelay<Void> { get }
  var tapNextButton: PublishRelay<CTAButton.Condition> { get }
  var tapLaterButton: PublishRelay<Void> { get }

}

protocol SignUpPortRegisterOutputable: ViewModelOutputable {

  var changeOption: PublishRelay<(Bool, Bool)> { get }
  var changeNextButtonCondition: PublishRelay<CTAButton.Condition> { get }
  var didTapNextButton: PublishRelay<WSPortTypeIdentifier> { get }
  var didSignUpSuccessfully: PublishRelay<Void> { get }
  var didSignUpUnsuccessfully: PublishRelay<Void> { get }
  var didDoInvalid: PublishRelay<Void> { get }

}

class SignUpPortRegisterInput: SignUpPortRegisterInputable {

  var tapOption0 = PublishRelay<Void>()
  var tapOption1 = PublishRelay<Void>()
  var tapNextButton = PublishRelay<CTAButton.Condition>()
  var tapLaterButton = PublishRelay<Void>()

}

class SignUpPortRegisterOutput: SignUpPortRegisterOutputable {

  var changeOption = PublishRelay<(Bool, Bool)>()
  var changeNextButtonCondition = PublishRelay<CTAButton.Condition>()
  var didTapNextButton = PublishRelay<WSPortTypeIdentifier>()
  var didSignUpSuccessfully = PublishRelay<Void>()
  var didSignUpUnsuccessfully = PublishRelay<Void>()
  var didDoInvalid = PublishRelay<Void>()

}

class SignUpPortRegisterViewModel: ViewModel<SignUpPortRegisterInput, SignUpPortRegisterOutput> {

  private let optionStream = BehaviorRelay<(Bool, Bool)>(value: (false, false))

  var userCache: UserCache?
  
  override func bind() {
    self.input.tapOption0
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.optionStream.accept((true, false))
      }).disposed(by: rx.disposeBag)

    self.input.tapOption1
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.optionStream.accept((false, true))
      }).disposed(by: rx.disposeBag)

    self.input.tapNextButton
      .withUnretained(self)
      .subscribe(onNext: { owner, condition in
        switch condition {
        case .normal:
          switch owner.optionStream.value {
          case (true, false):
            owner.output.didTapNextButton.accept(.gx)
          case (false, true):
            owner.output.didTapNextButton.accept(.dc8)
          default:
            // zettai hairanai
            owner.output.didTapNextButton.accept(.none)
          }
        default:
          break
        }
      }).disposed(by: rx.disposeBag)

    self.input.tapLaterButton
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        WSLoadingIndicator.startLoad()

        if let userCache = owner.userCache {
          let uuid = UUID().uuidString
          WSNetwork.request(target: .loginJoin(identifier: uuid,
                                               phone: userCache.phoneNumber,
                                               lastName: userCache.lastName,
                                               firstName: userCache.firstName,
                                               email: userCache.email,
                                               portType: nil,
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
      })
      .disposed(by: rx.disposeBag)

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
  }

}
