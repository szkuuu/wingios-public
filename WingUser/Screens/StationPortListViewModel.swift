//
//  StationPortListViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/25.
//

protocol StationPortListInputable: ViewModelInputable {

  var setStationName: PublishRelay<String> { get }
  var setStationAddress: PublishRelay<String?> { get }
  var requestPortState: PublishRelay<Int> { get }

}

protocol StationPortListOutputable: ViewModelOutputable {

  var stationName: BehaviorRelay<String> { get }
  var stationAddress: BehaviorRelay<String?> { get }
  var portStates: BehaviorRelay<[WSStructure.PortStateProperty]> { get }
  var error: PublishRelay<Error> { get }

}

class StationPortListInput: StationPortListInputable {

  var setStationName = PublishRelay<String>()
  var setStationAddress = PublishRelay<String?>()
  var requestPortState = PublishRelay<Int>()

}

class StationPortListOutput: StationPortListOutputable {

  var stationName = BehaviorRelay<String>(value: "")
  var stationAddress = BehaviorRelay<String?>(value: nil)
  var portStates = BehaviorRelay<[WSStructure.PortStateProperty]>(value: [])
  var error = PublishRelay<Error>()

}

class StationPortListViewModel: ViewModel<StationPortListInput, StationPortListOutput> {

  override func bind() {
    self.input.setStationName
      .bind(to: self.output.stationName)
      .disposed(by: rx.disposeBag)

    self.input.setStationAddress
      .bind(to: self.output.stationAddress)
      .disposed(by: rx.disposeBag)
    
    self.input.requestPortState
      .subscribe (onNext: { [weak self] in
        WSNetwork.request(target: .portList(stationId: "\($0)")) { [weak self] result in
          switch result {
          case .success(let json):
            if let result = json["result"].bool,
               let ports = json["port"].array,
               result {
              print(json)
              var stationPorts: [WSStructure.PortStateProperty] = []

              ports.forEach { port in
                if let portId = port["port_id"].int,
                   let portNumber = port["numb"].int,
                   let type = port["type"].int,
                   let state = port["status"].int {
                  stationPorts.append(.init(portId: portId,
                                            portNumber: portNumber,
                                            type: WSPortTypeIdentifier(rawValue: type) ?? WSPortTypeIdentifier.none,
                                            state: state))
                }
              }
              self?.output.portStates.accept(stationPorts.sorted(by: { $0.portNumber < $1.portNumber }))
            }
          case .failure(let error):
            self?.output.error.accept(error)
          }
        }
      }).disposed(by: rx.disposeBag)
  }

}
