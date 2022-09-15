//
//  SignUpPhoneViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/26.
//

import Moya

protocol SignUpPhoneViewInputable: ViewModelInputable {

  var phoneNumber: PublishRelay<String> { get }
  var tapNextButton: PublishRelay<CTAButton.Condition> { get }
  var fetchVerifyCode: PublishRelay<String?> { get }

}

protocol SignUpPhoneViewOutputable: ViewModelOutputable {

  var phoneNumberFormatted: PublishRelay<String> { get }
  var phoneNumberEditingForceEnd: PublishRelay<Void> { get }
  var changeNextButtonCondition: PublishRelay<Bool> { get }
  var didTapNextButton: PublishRelay<Void> { get }
  var didFetchVerifyCode: PublishRelay<Result<Int, Moya.MoyaError>> { get }

}

class SignUpPhoneViewInput: SignUpPhoneViewInputable {

  var phoneNumber = PublishRelay<String>()
  var tapNextButton = PublishRelay<CTAButton.Condition>()
  var fetchVerifyCode = PublishRelay<String?>()

}

class SignUpPhoneViewOutput: SignUpPhoneViewOutputable {

  var phoneNumberFormatted = PublishRelay<String>()
  var phoneNumberEditingForceEnd = PublishRelay<Void>()
  var changeNextButtonCondition = PublishRelay<Bool>()
  var didTapNextButton = PublishRelay<Void>()
  var didFetchVerifyCode = PublishRelay<Result<Int, MoyaError>>()

}

class SignUpPhoneViewModel: ViewModel<SignUpPhoneViewInput, SignUpPhoneViewOutput> {

  override func bind() {
    self.input.phoneNumber
      .map { $0.replacingOccurrences(of: "\\W+", with: "", options: .regularExpression) }
      .map {
        switch $0.count {
        case 0:
          return ""
        case 1...3:
          return $0
        case 4...7:
          return $0.replacingOccurrences(of: "(\\d{3})(\\d{1,4})", with: "$1 $2", options: .regularExpression)
        case 8...11:
          return $0.replacingOccurrences(of: "(\\d{3})(\\d{4})(\\d+)", with: "$1 $2 $3", options: .regularExpression)
        default:
          return String($0.replacingOccurrences(of: "(\\d{3})(\\d{4})(\\d+)", with: "$1 $2 $3", options: .regularExpression).prefix(13))
        }
      }
      .bind(to: self.output.phoneNumberFormatted)
      .disposed(by: rx.disposeBag)
    self.input.phoneNumber
      .map { $0.replacingOccurrences(of: "\\W+", with: "", options: .regularExpression) }
      .map { $0.count >= 11 }
      .withUnretained(self)
      .subscribe(onNext: { owner, isFull in
        if isFull {
          owner.output.changeNextButtonCondition.accept(true)
          owner.output.phoneNumberEditingForceEnd.accept(())
        } else {
          owner.output.changeNextButtonCondition.accept(false)
        }
      }).disposed(by: rx.disposeBag)
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
    self.input.fetchVerifyCode
      .withUnretained(self)
      .subscribe(onNext: { owner, phone in
        let phoneFormatted: String = phone?.replacingOccurrences(of: " ", with: "") ?? ""

        WSNetwork.request(target: .loginGetCert(phone: phoneFormatted)) { result in
          switch result {
          case .success(let json):
            if let result = json["result"].bool,
               let verifyNumber = json["numb"].int,
               result {
              print("VERIFY CODE ===========> \(verifyNumber)")
              owner.output.didFetchVerifyCode.accept(.success(verifyNumber))
            } else {
              owner.output.didFetchVerifyCode.accept(.failure(.requestMapping("에러가 발생하였습니다. 전화번호를 다시 한 번 확인해주세요.")))
            }
          case .failure(let error):
            owner.output.didFetchVerifyCode.accept(.failure(error))
          }
        }
      }).disposed(by: rx.disposeBag)
  }

}
