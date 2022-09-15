//
//  QrViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/03.
//

protocol QrInputable: ViewModelInputable {

  var urlComponent: PublishRelay<URLComponents?> { get }
  var tapFlashBubble: PublishRelay<Void> { get }

}

protocol QrOutputable: ViewModelOutputable {

  var didTapFlashBubble: BehaviorRelay<Bool> { get }
  var didOccurErrorWithComponentIsInvalid: PublishRelay<Void> { get }
  var didOccurErrorWithNetworking: PublishRelay<Void> { get }
  var didFetchStationInformationSuccessfully: PublishRelay<WSStructure.StationInformationProperty> { get }

}

class QrInput: QrInputable {

  var urlComponent = PublishRelay<URLComponents?>()
  var tapFlashBubble = PublishRelay<Void>()

}

class QrOutput: QrOutputable {

  var didTapFlashBubble = BehaviorRelay<Bool>(value: false)
  var didOccurErrorWithComponentIsInvalid = PublishRelay<Void>()
  var didOccurErrorWithNetworking = PublishRelay<Void>()
  var didFetchStationInformationSuccessfully = PublishRelay<WSStructure.StationInformationProperty>()

}

class QrViewModel: ViewModel<QrInput, QrOutput> {

  override func bind() {
    self.input.urlComponent
      .withUnretained(self)
      .subscribe(onNext: { owner, urlComponent in
        WSLoadingIndicator.startLoad()

        guard let urlComponent = urlComponent else {
          WSLoadingIndicator.stopLoad()
          owner.output.didOccurErrorWithComponentIsInvalid.accept(())
          return
        }

        guard let scheme = urlComponent.scheme,
              scheme == "https" else {
                WSLoadingIndicator.stopLoad()
                owner.output.didOccurErrorWithComponentIsInvalid.accept(())
                return
              }

        guard let host = urlComponent.host,
              host == "app.wingstation.co.kr" else {
                WSLoadingIndicator.stopLoad()
                owner.output.didOccurErrorWithComponentIsInvalid.accept(())
                return
              }

        let pathComponents = urlComponent.path.components(separatedBy: "/").filter { !$0.isEmpty }

        guard pathComponents.count == 2 else {
          WSLoadingIndicator.stopLoad()
          owner.output.didOccurErrorWithComponentIsInvalid.accept(())
          return
        }

        guard pathComponents[0] == "station" else {
          WSLoadingIndicator.stopLoad()
          owner.output.didOccurErrorWithComponentIsInvalid.accept(())
          return
        }

        let stationId = pathComponents[1]

        WSNetwork.request(target: .chargeStationCheck(stationId: stationId)) { result in
          switch result {
          case .success(let json):
            if let result = json["result"].bool,
               result {
              let station = json["station"]

              let portId = station["port_id"].int ?? -1
              let stationId = station["station_id"].int ?? -1
              let stationCode = station["station_code"].string ?? ""
              let portNumber = station["port"].int ?? -1
              let stationName = station["name"].string ?? ""
              let identifier = station["identifier"].string ?? ""

              WSLoadingIndicator.stopLoad()
              owner.output.didFetchStationInformationSuccessfully.accept(.init(portId: portId,
                                                                               stationId: stationId,
                                                                               stationCode: stationCode,
                                                                               portNumber: portNumber,
                                                                               stationName: stationName,
                                                                               identifier: identifier))
            } else {
              WSLoadingIndicator.stopLoad()
              owner.output.didOccurErrorWithNetworking.accept(())
            }
          case .failure:
            WSLoadingIndicator.stopLoad()
            owner.output.didOccurErrorWithNetworking.accept(())
          }
        }
      }).disposed(by: rx.disposeBag)

    self.input.tapFlashBubble
      .map { [weak self] _ in self?.output.didTapFlashBubble.value ?? false }
      .map { !$0 }
      .bind(to: self.output.didTapFlashBubble)
      .disposed(by: rx.disposeBag)
  }

}
