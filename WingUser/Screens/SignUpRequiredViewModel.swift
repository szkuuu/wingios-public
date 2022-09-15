//
//  SignUpRequiredViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/30.
//

protocol SignUpRequiredInputable: ViewModelInputable {

  var injectLastName: PublishRelay<String> { get }
  var injectFirstName: PublishRelay<String> { get }
  var injectEmail: PublishRelay<String> { get }
  var tapNextButton: PublishRelay<CTAButton.Condition> { get }

}

protocol SignUpRequiredOutputable: ViewModelOutputable {

  var changeNextButtonCondition: PublishRelay<CTAButton.Condition> { get }
  var didTapNextButton: PublishRelay<Void> { get }
}

class SignUpRequiredInput: SignUpRequiredInputable {

  var injectLastName = PublishRelay<String>()
  var injectFirstName = PublishRelay<String>()
  var injectEmail = PublishRelay<String>()
  var tapNextButton = PublishRelay<CTAButton.Condition>()

}

class SignUpRequiredOutput: SignUpRequiredOutputable {

  var changeNextButtonCondition = PublishRelay<CTAButton.Condition>()
  var didTapNextButton = PublishRelay<Void>()

}

class SignUpRequiredViewModel: ViewModel<SignUpRequiredInput, SignUpRequiredOutput> {

  private let lastNameVerifyStream = BehaviorRelay<Bool>(value: false)
  private let firstNameVerifyStream = BehaviorRelay<Bool>(value: false)
  private let emailVerifyStream = BehaviorRelay<Bool>(value: false)

  var userCache: UserCache?
  
  override func bind() {
    self.input.injectLastName
      .map { $0.count > 0 }
      .bind(to: lastNameVerifyStream)
      .disposed(by: rx.disposeBag)

    self.input.injectFirstName
      .map { $0.count > 0 }
      .bind(to: firstNameVerifyStream)
      .disposed(by: rx.disposeBag)

    self.input.injectEmail
      .map { (email: String) -> Bool in
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
      }
      .bind(to: emailVerifyStream)
      .disposed(by: rx.disposeBag)

    Observable.combineLatest(lastNameVerifyStream, firstNameVerifyStream, emailVerifyStream)
      .map { $0.0 && $0.1 && $0.2 }
      .map { (valid: Bool) -> CTAButton.Condition in
        return valid ? .normal : .inactive
      }
      .bind(to: self.output.changeNextButtonCondition)
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
  }

}
