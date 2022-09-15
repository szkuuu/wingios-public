//
//  SignUpVerifyViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/29.
//

import SwiftDate

protocol SignUpVerifyInputable: ViewModelInputable {

  var startTimer: PublishRelay<Int> { get }
  var restartTimer: PublishRelay<(phoneNumber: String?, limitTime: Int)> { get }
  var injectVerifyCode: PublishRelay<Int> { get }
  var injectPhoneNumber: PublishRelay<String?> { get }
  var code: PublishRelay<String> { get }
  var tapNextButton: PublishRelay<CTAButton.Condition> { get }
  var fetchVerify: PublishRelay<Int> { get }

}

protocol SignUpVerifyOutputable: ViewModelOutputable {

  var timeString: PublishRelay<String> { get }
  var phoneNumber: BehaviorRelay<String> { get }
  var codeFormatted: PublishRelay<String> { get }
  var didTapNextButton: PublishRelay<Void> { get }
  var changeNextButtonCondition: PublishRelay<CTAButton.Condition> { get }
  var verifyCodeEditingForceEnd: PublishRelay<Void> { get }
  var didFetchVerifyCode: BehaviorRelay<String> { get }
  var didChangeVerifyCode: PublishRelay<Void> { get }
  var didOccurError: PublishRelay<Void> { get }
  var didTimeout: PublishRelay<Void> { get }
  var didVerify: PublishRelay<Bool> { get }
  var didLogin: PublishRelay<Void> { get }

}

class SignUpVerifyInput: SignUpVerifyInputable {

  var startTimer = PublishRelay<Int>()
  var restartTimer = PublishRelay<(phoneNumber: String?, limitTime: Int)>()
  var injectVerifyCode = PublishRelay<Int>()
  var injectPhoneNumber = PublishRelay<String?>()
  var code = PublishRelay<String>()
  var tapNextButton = PublishRelay<CTAButton.Condition>()
  var fetchVerify = PublishRelay<Int>()

}

class SignUpVerifyOutput: SignUpVerifyOutputable {

  var timeString = PublishRelay<String>()
  var phoneNumber = BehaviorRelay<String>(value: "")
  var codeFormatted = PublishRelay<String>()
  var didTapNextButton = PublishRelay<Void>()
  var changeNextButtonCondition = PublishRelay<CTAButton.Condition>()
  var verifyCodeEditingForceEnd = PublishRelay<Void>()
  var didFetchVerifyCode = BehaviorRelay<String>(value: "")
  var didChangeVerifyCode = PublishRelay<Void>()
  var didOccurError = PublishRelay<Void>()
  var didTimeout = PublishRelay<Void>()
  var didVerify = PublishRelay<Bool>()
  var didLogin = PublishRelay<Void>()

}

class SignUpVerifyViewModel: ViewModel<SignUpVerifyInput, SignUpVerifyOutput> {

  private let verifyCodeStream = BehaviorRelay<Int>(value: 0)

  private let timeOutStream = BehaviorRelay<Bool>(value: false)

  private var timerDisposable: Disposable?

  override func bind() {
    self.input.startTimer
      .withUnretained(self)
      .subscribe(onNext: { owner, limitTime in
        owner.timerDisposable?.dispose()
        owner.timerDisposable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
          .take(limitTime + 1)
          .map { Date(seconds: Double(limitTime - $0)).toFormat("mm:ss", locale: Locales.koreanSouthKorea) }
          .asDriver(onErrorJustReturn: "")
          .drive(onNext: { [weak self] timeString in
            self?.output.timeString.accept(timeString)
          }, onCompleted: { [weak self] in
            self?.timeOutStream.accept(true)
          }, onDisposed: { [weak self] in
            self?.timeOutStream.accept(true)
          })
      }).disposed(by: rx.disposeBag)

    self.input.restartTimer
      .withUnretained(self)
      .subscribe(onNext: { owner, pack in
        let phoneNumberWithoutSpace = pack.phoneNumber?.replacingOccurrences(of: " ", with: "") ?? ""
        print(phoneNumberWithoutSpace)

        WSNetwork.request(target: .loginGetCert(phone: phoneNumberWithoutSpace)) { [weak owner = owner] result in
          WSLoadingIndicator.startLoad()
          switch result {
          case .success(let json):
            WSLoadingIndicator.stopLoad()
            if let result = json["result"].bool,
               let verifyCode = json["numb"].int,
               result {
              owner?.input.injectVerifyCode.accept(verifyCode)
              owner?.input.startTimer.accept(pack.limitTime)
              owner?.timeOutStream.accept(false)
              owner?.output.didChangeVerifyCode.accept(())
            } else {
              owner?.output.didOccurError.accept(())
            }
          case .failure:
            WSLoadingIndicator.stopLoad()
            owner?.output.didOccurError.accept(())
          }
        }
      }).disposed(by: rx.disposeBag)

    self.input.injectVerifyCode
      .bind(to: verifyCodeStream)
      .disposed(by: rx.disposeBag)

    self.input.injectPhoneNumber
      .map { $0 ?? "" }
      .bind(to: self.output.phoneNumber)
      .disposed(by: rx.disposeBag)

    self.input.code
      .map { $0.count >= 6 }
      .withUnretained(self)
      .subscribe(onNext: { owner, isFull in
        if isFull {
          owner.output.changeNextButtonCondition.accept(.normal)
          owner.output.verifyCodeEditingForceEnd.accept(())
        } else {
          owner.output.changeNextButtonCondition.accept(.inactive)
        }
      }).disposed(by: rx.disposeBag)

    self.input.code
      .map { $0.count > 6 ? String($0.prefix(6)) : $0 }
      .bind(to: self.output.codeFormatted)
      .disposed(by: rx.disposeBag)

    self.input.tapNextButton
      .withUnretained(self)
      .subscribe(onNext: { owner, condition in
        switch condition {
        case .normal:
          owner.output.didTapNextButton.accept(())
        default:
          break
        }
      }).disposed(by: rx.disposeBag)

    self.input.fetchVerify
      .withUnretained(self)
      .subscribe(onNext: { owner, code in
        print(owner.verifyCodeStream.value)
        if owner.timeOutStream.value {
          owner.output.didTimeout.accept(())
          return
        }
        if code == owner.verifyCodeStream.value {
          owner.timerDisposable?.dispose()
          owner.timerDisposable = nil

          let realm = try! Realm()
          let user = realm.objects(UserStore.self).first
          let phoneNumber = self.output.phoneNumber.value.replacingOccurrences(of: " ", with: "")
          let identifierString = user?.identifier ?? ""
          let identifier = identifierString.isEmpty ? UUID().uuidString : identifierString

          WSNetwork.request(target: .loginNew(phone: phoneNumber, identifier: identifier)) { result in
            WSLoadingIndicator.startLoad()

            switch result {
            case .success(let json):
              if let result = json["result"].bool,
                 let token = json["token"].string,
                 result {
                try! realm.write {
                  user?.token = token
                  user?.identifier = identifier
                }
                WSLoadingIndicator.stopLoad()
                owner.output.didLogin.accept(())
                return
              }

              WSLoadingIndicator.stopLoad()
              owner.output.didVerify.accept(true)
            case .failure:
              WSLoadingIndicator.stopLoad()
              owner.output.didVerify.accept(true)
            }
          }
        } else {
          owner.output.didVerify.accept(false)
        }
      }).disposed(by: rx.disposeBag)

    self.verifyCodeStream
      .map { "\($0) "}
      .bind(to: self.output.didFetchVerifyCode)
      .disposed(by: rx.disposeBag)
  }

}
