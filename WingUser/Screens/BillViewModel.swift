//
//  BillViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/08.
//

protocol BillInputable: ViewModelInputable {

  var appearSignal: PublishRelay<Void> { get }

}

protocol BillOutputable: ViewModelOutputable {

  var place: BehaviorRelay<String> { get }
  var port: BehaviorRelay<Int> { get }
  var startDate: BehaviorRelay<Date> { get }
  var endDate: BehaviorRelay<Date> { get }
  var standardVoltage: BehaviorRelay<Int> { get }
  var amount: BehaviorRelay<CGFloat> { get }
  var didOccurErrorWithNothingBill: PublishRelay<Void> { get }

}

class BillInput: BillInputable {

  var appearSignal = PublishRelay<Void>()

}

class BillOutput: BillOutputable {

  var place = BehaviorRelay<String>(value: "-")
  var port = BehaviorRelay<Int>(value: -1)
  var startDate = BehaviorRelay<Date>(value: Date(timeIntervalSince1970: 0))
  var endDate = BehaviorRelay<Date>(value: Date(timeIntervalSince1970: 0))
  var standardVoltage = BehaviorRelay<Int>(value: 0)
  var amount = BehaviorRelay<CGFloat>(value: 0)
  var didOccurErrorWithNothingBill = PublishRelay<Void>()

}

class BillViewModel: ViewModel<BillInput, BillOutput> {

  var billProperty: WSStructure.BillProperty?

  override func bind() {
    self.input.appearSignal
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        WSLoadingIndicator.startLoad()
        guard let billProperty = owner.billProperty else {
          WSLoadingIndicator.stopLoad()
          owner.output.didOccurErrorWithNothingBill.accept(())
          return
        }

        owner.output.place.accept(billProperty.stationName)
        owner.output.port.accept(billProperty.port)
        owner.output.startDate.accept(billProperty.startTime)
        owner.output.endDate.accept(billProperty.endTime)
        owner.output.standardVoltage.accept(billProperty.standardVoltage)
        owner.output.amount.accept(billProperty.amount)

        WSLoadingIndicator.stopLoad()
      }).disposed(by: rx.disposeBag)
  }
  
}
