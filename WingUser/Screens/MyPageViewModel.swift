//
//  MyPageViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/01.
//

protocol MyPageInputable: ViewModelInputable {

  var appearSignal: PublishRelay<Void> { get }
  var tapCardAddButton: PublishRelay<Void> { get }
  var tapChargeEditButton: PublishRelay<Void> { get }
  var tapUnderButton: PublishRelay<Void> { get }

}

protocol MyPageOutputable: ViewModelOutputable {

  var underButtonText: BehaviorRelay<String> { get }
  var didFetchUserSuccessfully: PublishRelay<WSStructure.MyPageProperty> { get }
  var didFetchUserUnsuccessfully: PublishRelay<Bool> { get }
  var didTapCardAddButton: PublishRelay<Void> { get }
  var didTapChargeEditButton: PublishRelay<WSStructure.MyPageProperty> { get }
  var didNoticeErrorNow: PublishRelay<Void> { get }
  var didNoticeRequireSignUp: PublishRelay<Void> { get }
  var didLogout: PublishRelay<Void> { get }
  var didSignUp: PublishRelay<Void> { get }

}

class MyPageInput: MyPageInputable {

  var appearSignal = PublishRelay<Void>()
  var tapCardAddButton = PublishRelay<Void>()
  var tapChargeEditButton = PublishRelay<Void>()
  var tapUnderButton = PublishRelay<Void>()

}

class MyPageOutput: MyPageOutputable {

  var underButtonText = BehaviorRelay<String>(value: "회원가입")
  var didFetchUserSuccessfully = PublishRelay<WSStructure.MyPageProperty>()
  var didFetchUserUnsuccessfully = PublishRelay<Bool>()
  var didTapCardAddButton = PublishRelay<Void>()
  var didTapChargeEditButton = PublishRelay<WSStructure.MyPageProperty>()
  var didNoticeErrorNow = PublishRelay<Void>()
  var didNoticeRequireSignUp = PublishRelay<Void>()
  var didLogout = PublishRelay<Void>()
  var didSignUp = PublishRelay<Void>()

}

class MyPageViewModel: ViewModel<MyPageInput, MyPageOutput> {

  private let errorStream = BehaviorRelay<Bool>(value: false)
  private let loginStream = BehaviorRelay<Bool>(value: false)
  private let myPagePropertyStream = BehaviorRelay<WSStructure.MyPageProperty>(value: .init(lastName: "", firstName: "", cardInfo: nil, email: "", type: .none, ampere: nil, voltage: nil))

  override func bind() {
    self.input.appearSignal
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let realm = try! Realm()
        let user = realm.objects(UserStore.self).first
        let token = user?.token ?? ""

        if token.isEmpty {
          owner.errorStream.accept(false)
          owner.loginStream.accept(false)
          owner.output.underButtonText.accept("회원가입")
          owner.output.didFetchUserUnsuccessfully.accept(token.isEmpty)
          return
        }
        WSLoadingIndicator.startLoad()
        WSNetwork.request(target: .getMyInfo(token: token)) { result in
          switch result {
          case .success(let json):
            if let result = json["result"].bool,
               result {
              let lastName = json["user"]["last_name"].string ?? ""
              let firstName = json["user"]["first_name"].string ?? ""
              let cardInfo = json["user"]["card_info"].string
              let email = json["user"]["email"].string ?? ""
              let portType = WSPortTypeIdentifier(rawValue: json["charge"]["type"].int ?? -1) ?? .none
              let chargeVoltage = json["charge"]["voltage"].double
              let chargeAmpere = json["charge"]["ampere"].double

              WSLoadingIndicator.stopLoad()
              owner.errorStream.accept(false)
              owner.loginStream.accept(true)
              owner.output.underButtonText.accept("로그아웃")
              owner.myPagePropertyStream.accept(.init(lastName: lastName,
                                                      firstName: firstName,
                                                      cardInfo: cardInfo,
                                                      email: email,
                                                      type: portType,
                                                      ampere: chargeAmpere,
                                                      voltage: chargeVoltage))
              return
            }

            WSLoadingIndicator.stopLoad()
            owner.errorStream.accept(true)
            owner.loginStream.accept(false)
            owner.output.underButtonText.accept("-")
            owner.output.didFetchUserUnsuccessfully.accept(token.isEmpty)
          case .failure:
            WSLoadingIndicator.stopLoad()
            owner.errorStream.accept(true)
            owner.loginStream.accept(false)
            owner.output.underButtonText.accept("-")
            owner.output.didFetchUserUnsuccessfully.accept(token.isEmpty)
          }
        }
      }).disposed(by: rx.disposeBag)

    self.input.tapCardAddButton
      .map { (isError: self.errorStream.value, isLoggedIn: self.loginStream.value) }
      .withUnretained(self)
      .subscribe(onNext: { owner, streams in
        guard !streams.isError else {
          owner.output.didNoticeErrorNow.accept(())
          return
        }

        if streams.isLoggedIn {
          owner.output.didTapCardAddButton.accept(())
        } else {
          owner.output.didNoticeRequireSignUp.accept(())
        }
      }).disposed(by: rx.disposeBag)

    self.input.tapChargeEditButton
      .map { (isError: self.errorStream.value, isLoggedIn: self.loginStream.value) }
      .withUnretained(self)
      .subscribe(onNext: { owner, streams in
        guard !streams.isError else {
          owner.output.didNoticeErrorNow.accept(())
          return
        }

        if streams.isLoggedIn {
          owner.output.didTapChargeEditButton.accept(owner.myPagePropertyStream.value)
        } else {
          owner.output.didNoticeRequireSignUp.accept(())
        }
      }).disposed(by: rx.disposeBag)

    self.input.tapUnderButton
      .map { (isError: self.errorStream.value, isLoggedIn: self.loginStream.value) }
      .withUnretained(self)
      .subscribe(onNext: { owner, streams in
        guard !streams.isError else {
          return
        }

        if streams.isLoggedIn {
          owner.output.didLogout.accept(())
        } else {
          owner.output.didSignUp.accept(())
        }
      }).disposed(by: rx.disposeBag)

    self.myPagePropertyStream
      .bind(to: self.output.didFetchUserSuccessfully)
      .disposed(by: rx.disposeBag)
  }

}
