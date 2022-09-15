//
//  CardModifyViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/30.
//

protocol CardModifyInputable: ViewModelInputable {

  var injectName: BehaviorRelay<String> { get }
  var requestValidate: PublishRelay<(cardNumber: String, validMonth: String, validYear: String, password: String)> { get }

}

protocol CardModifyOutputable: ViewModelOutputable {

  var name: BehaviorRelay<String> { get }
  var ctaButtonText: BehaviorRelay<String> { get }
  var didCompleteValid: PublishRelay<Bool> { get }
  var didOccurErrorWithValidDate: PublishRelay<Void> { get }
  var didOccurErrorWithPassword: PublishRelay<Void> { get }
  var didOccurErrorWithKeeper: PublishRelay<Void> { get }
  var didSaveSuccessfully: PublishRelay<Void> { get }
  var didSaveUnsuccessfully: PublishRelay<Void> { get }

}

class CardModifyInput: CardModifyInputable {

  var injectName = BehaviorRelay<String>(value: "")
  var requestValidate = PublishRelay<(cardNumber: String, validMonth: String, validYear: String, password: String)>()

}

class CardModifyOutput: CardModifyOutputable {

  var name = BehaviorRelay<String>(value: "")
  var ctaButtonText = BehaviorRelay<String>(value: "")
  var didCompleteValid = PublishRelay<Bool>()
  var didOccurErrorWithValidDate = PublishRelay<Void>()
  var didOccurErrorWithPassword = PublishRelay<Void>()
  var didOccurErrorWithKeeper = PublishRelay<Void>()
  var didSaveSuccessfully = PublishRelay<Void>()
  var didSaveUnsuccessfully = PublishRelay<Void>()

}

class CardModifyViewModel: ViewModel<CardModifyInput, CardModifyOutput> {

  private let completeStream = BehaviorRelay<Bool>(value: false)
  
  override func bind() {
    self.completeStream
      .distinctUntilChanged()
      .withUnretained(self)
      .subscribe(onNext: { owner, isValidateCompleted in
        owner.output.ctaButtonText.accept(isValidateCompleted ? "저장" : "카드 인증하기")
      }).disposed(by: rx.disposeBag)

    self.input.injectName
      .bind(to: self.output.name)
      .disposed(by: rx.disposeBag)

    self.input.requestValidate
      .withUnretained(self)
      .subscribe(onNext: { owner, pack in
        WSLoadingIndicator.startLoad()
        if let validMonth = Int(pack.validMonth),
           let validYear = Int(pack.validYear),
           validMonth >= 1 && validMonth <= 12,
           validYear >= 0 && validYear <= 99 {
          // mondai nai
        } else {
          WSLoadingIndicator.stopLoad()
          owner.output.didOccurErrorWithValidDate.accept(())
          return
        }

        if pack.password.count < 2 {
          WSLoadingIndicator.stopLoad()
          owner.output.didOccurErrorWithPassword.accept(())
        }

        let realm = try! Realm()
        let token = realm.objects(UserStore.self).first?.token ?? ""
        let cardNumber = pack.cardNumber.replacingOccurrences(of: " ", with: "")
        let validMonth = pack.validMonth
        let validYear = pack.validYear
        let password = pack.password
        WSNetwork.request(target: .cardNew(token: token,
                                           cardNumber: cardNumber,
                                           validMonth: validMonth,
                                           validYear: validYear,
                                           password: password)) { result in
          switch result {
          case .success(let json):
            WSLoadingIndicator.stopLoad()
            owner.output.didSaveSuccessfully.accept(())
          case .failure(let error):
            WSLoadingIndicator.stopLoad()
            owner.output.didSaveUnsuccessfully.accept(())
          }
        }
      }).disposed(by: rx.disposeBag)
  }

}
