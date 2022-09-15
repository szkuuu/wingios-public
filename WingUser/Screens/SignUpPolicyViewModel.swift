//
//  SignUpPolicyViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/30.
//

protocol SignUpPolicyInputable: ViewModelInputable {

  var tapOptionAll: PublishRelay<Bool> { get }
  var tapOption0: PublishRelay<Bool> { get }
  var tapOption1: PublishRelay<Bool> { get }
  var tapOption2: PublishRelay<Bool> { get }
  var tapNextButton: PublishRelay<CTAButton.Condition> { get }
  var tapRightView: PublishRelay<URL?> { get }

}

protocol SignUpPolicyOutputable: ViewModelOutputable {

  var changeAllOption: PublishRelay<Bool> { get }
  var changeSubOptions: PublishRelay<(Bool, Bool, Bool)> { get }
  var changeNextButtonCondition: BehaviorRelay<CTAButton.Condition> { get }
  var didTapNextButton: PublishRelay<Void> { get }
  var didTapRightView: PublishRelay<URL> { get }

}

class SignUpPolicyInput: SignUpPolicyInputable {

  var tapOptionAll = PublishRelay<Bool>()
  var tapOption0 = PublishRelay<Bool>()
  var tapOption1 = PublishRelay<Bool>()
  var tapOption2 = PublishRelay<Bool>()
  var tapNextButton = PublishRelay<CTAButton.Condition>()
  var tapRightView = PublishRelay<URL?>()

}

class SignUpPolicyOutput: SignUpPolicyOutputable {

  var changeAllOption = PublishRelay<Bool>()
  var changeSubOptions = PublishRelay<(Bool, Bool, Bool)>()
  var changeNextButtonCondition = BehaviorRelay<CTAButton.Condition>(value: .inactive)
  var didTapNextButton = PublishRelay<Void>()
  var didTapRightView = PublishRelay<URL>()

}

class SignUpPolicyViewModel: ViewModel<SignUpPolicyInput, SignUpPolicyOutput> {

  var optionsStream = BehaviorRelay<(Bool, Bool, Bool)>(value: (false, false, false))
  var optionSatisfiredStream = BehaviorRelay<Bool>(value: false)
  var userCache: UserCache?

  override func bind() {
    self.input.tapOptionAll
      .map { !$0 }
      .map { ($0, $0, $0) }
      .bind(to: self.optionsStream)
      .disposed(by: rx.disposeBag)

    self.input.tapOption0
      .map { (!$0, self.optionsStream.value.1, self.optionsStream.value.2) }
      .bind(to: self.optionsStream)
      .disposed(by: rx.disposeBag)

    self.input.tapOption1
      .map { (self.optionsStream.value.0, !$0, self.optionsStream.value.2) }
      .bind(to: self.optionsStream)
      .disposed(by: rx.disposeBag)

    self.input.tapOption2
      .map { (self.optionsStream.value.0, self.optionsStream.value.1, !$0) }
      .bind(to: self.optionsStream)
      .disposed(by: rx.disposeBag)

    self.optionsStream
      .bind(to: self.output.changeSubOptions)
      .disposed(by: rx.disposeBag)

    self.optionsStream
      .map { $0.0 && $0.1 && $0.2 }
      .bind(to: self.output.changeAllOption)
      .disposed(by: rx.disposeBag)

    self.optionsStream
      .map { $0.0 && $0.1 && $0.2 }
      .bind(to: self.optionSatisfiredStream)
      .disposed(by: rx.disposeBag)

    self.optionSatisfiredStream
      .map { (satisfied: Bool) -> CTAButton.Condition in
        satisfied ? .normal : .inactive
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

    self.input.tapRightView
      .withUnretained(self)
      .subscribe(onNext: { owner, url in
        if let url = url {
          owner.output.didTapRightView.accept(url)
        }
      }).disposed(by: rx.disposeBag)
  }

}
