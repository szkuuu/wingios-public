//
//  HomeViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/24.
//

import CoreLocation

typealias CornerRegion = (bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D)

protocol HomeViewInputable: ViewModelInputable {

  var changeCenterMode: PublishRelay<Bool> { get }
  var requestAnnotations: PublishRelay<CornerRegion> { get }
  var tapRequestButton: PublishRelay<Void> { get }
  var tapRequestAcceptButton: PublishRelay<CLLocationCoordinate2D> { get }
  var tapRequestCloseButton: PublishRelay<Int> { get }

}

protocol HomeViewOutputable: ViewModelOutputable {

  var changeMode: BehaviorRelay<Bool> { get }
  var requestButtonCondition: BehaviorRelay<CTAButton.Condition> { get }
  var requestButtonText: BehaviorRelay<String> { get }
  var requestCloseButtonHidden: BehaviorRelay<Bool> { get }
  var requestButtonHidden: BehaviorRelay<Bool> { get }
  var centerAnnotationHidden: BehaviorRelay<Bool> { get }
  var stationAnnotations: BehaviorRelay<[WSAnnotation]> { get }
  var didTapRequestButton: PublishRelay<Void> { get }
  var didTapRequestCloseButton: PublishRelay<Void> { get }
  var didStationRequestSuccessfully: PublishRelay<Void> { get }
  var didStationRequestUnsuccessfully: PublishRelay<Void> { get }
  var didOccurErrorWithUserNotExist: PublishRelay<Void> { get }
  var didOccurErrorWithAddressNotExist: PublishRelay<Void> { get }

}

class HomeViewInput: HomeViewInputable {

  var changeCenterMode = PublishRelay<Bool>()
  var requestAnnotations = PublishRelay<CornerRegion>()
  var tapRequestButton = PublishRelay<Void>()
  var tapRequestAcceptButton = PublishRelay<CLLocationCoordinate2D>()
  var tapRequestCloseButton = PublishRelay<Int>()

}

class HomeViewOutput: HomeViewOutputable {

  var changeMode = BehaviorRelay<Bool>(value: true)
  var requestButtonCondition = BehaviorRelay<CTAButton.Condition>(value: .label(focused: false))
  var requestButtonText = BehaviorRelay<String>(value: "-")
  var requestCloseButtonHidden = BehaviorRelay<Bool>(value: true)
  var requestButtonHidden = BehaviorRelay<Bool>(value: true)
  var centerAnnotationHidden = BehaviorRelay<Bool>(value: true)
  var stationAnnotations = BehaviorRelay<[WSAnnotation]>(value: [])
  var didTapRequestButton = PublishRelay<Void>()
  var didTapRequestCloseButton = PublishRelay<Void>()
  var didStationRequestSuccessfully = PublishRelay<Void>()
  var didStationRequestUnsuccessfully = PublishRelay<Void>()
  var didOccurErrorWithUserNotExist = PublishRelay<Void>()
  var didOccurErrorWithAddressNotExist = PublishRelay<Void>()

}

class HomeViewModel: ViewModel<HomeViewInputable, HomeViewOutputable> {

  private let stationRequestMode = BehaviorRelay<Bool>(value: false)

  override func bind() {
    self.stationRequestMode
      .map { $0 ? "여기에 스테이션을 설치해주세요" : "스테이션 설치를 요청할래요" }
      .bind(to: self.output.requestButtonText)
      .disposed(by: rx.disposeBag)

    self.stationRequestMode
      .map { CTAButton.Condition.label(focused: $0) }
      .bind(to: self.output.requestButtonCondition)
      .disposed(by: rx.disposeBag)

    self.stationRequestMode
      .map { !$0 }
      .bind(to: self.output.requestCloseButtonHidden)
      .disposed(by: rx.disposeBag)

    self.stationRequestMode
      .map { !$0 }
      .bind(to: self.output.centerAnnotationHidden)
      .disposed(by: rx.disposeBag)
    
    self.input.changeCenterMode
      .distinctUntilChanged()
      .bind(to: self.output.changeMode)
      .disposed(by: rx.disposeBag)

    self.input.requestAnnotations
      .map { (minLat: $0.bottomLeft.latitude,
              minLong: $0.bottomLeft.longitude,
              maxLat: $0.topRight.latitude,
              maxLong: $0.topRight.longitude) }
      .withUnretained(self)
      .subscribe { owner, region in
        WSNetwork.request(target: .getMain(minLat: region.minLat,
                                           minLong: region.minLong,
                                           maxLat: region.maxLat,
                                           maxLong: region.maxLong,
                                           type: nil)) { result in
          switch result {
          case .success(let json):
            if let result = json["result"].bool,
               let stations = json["station"].array,
               result {
              var markers: [WSAnnotation] = []
              stations.forEach {
                if let stationId = $0["station_id"].int,
                   let available = $0["able"].bool,
                   let name = $0["name"].string,
                   let latitude = $0["lat"].double,
                   let longitude = $0["long"].double {
                  markers.append(WSAnnotation(property: .init(address: $0["address"].string ?? "-",
                                                              stationId: stationId,
                                                              available: available,
                                                              name: name,
                                                              coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))))
                }
              }
              if !owner.stationRequestMode.value {
                owner.output.requestButtonHidden.accept(!markers.isEmpty)
              }
              owner.output.stationAnnotations.accept(markers)
            } else {
              if !owner.stationRequestMode.value {
                owner.output.requestButtonHidden.accept(false)
              }
              owner.output.requestButtonHidden.accept(false)
              owner.output.stationAnnotations.accept([])
            }
          case .failure:
            if !owner.stationRequestMode.value {
              owner.output.requestButtonHidden.accept(false)
            }
            owner.output.requestButtonHidden.accept(false)
            owner.output.stationAnnotations.accept([])
          }
        }
      }.disposed(by: rx.disposeBag)

    self.input.tapRequestButton
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let realm = try! Realm()
        let token = realm.objects(UserStore.self).first?.token ?? ""

        guard !token.isEmpty else {
          owner.output.didOccurErrorWithUserNotExist.accept(())
          return
        }

        if owner.stationRequestMode.value {
          // 현재 스테이션 설치요청 모드일 경우
          owner.output.didTapRequestButton.accept(())
        } else {
          // 현재 스테이션 설치요청 모드가 아닐경우
          owner.stationRequestMode.accept(!owner.stationRequestMode.value)
        }
      }).disposed(by: rx.disposeBag)

    self.input.tapRequestAcceptButton
      .withUnretained(self)
      .subscribe(onNext: { owner, coordinate in
        var address: String = ""

        WSLoadingIndicator.startLoad()
        WSNaverMap.request(target: .rgc(lat: coordinate.latitude, long: coordinate.longitude)) { result in
          switch result {
          case .success(let json):
            if json["status"].exists(),
               let code = json["status"]["code"].int,
               code == 0,
               let results = json["results"].array,
               !results.isEmpty {
              if results.contains(where: { $0["name"].stringValue == "roadaddr" }) {
                // 도로명 주소가 있을 경우 도로명 주소를 리턴
                guard let roadAddr = results.filter({ $0["name"].stringValue == "roadaddr" }).first,
                      roadAddr["region"].exists(),
                      roadAddr["land"].exists() else {
                        WSLoadingIndicator.stopLoad()
                        owner.output.didOccurErrorWithAddressNotExist.accept(())
                        return
                      }

                let roadAddrRegion = roadAddr["region"]
                let roadAddrLand = roadAddr["land"]

                address = "\(roadAddrRegion["area1"]["name"].string ?? "") " +
                "\(roadAddrRegion["area2"]["name"].string ?? "") " +
                "\(roadAddrLand["name"].string ?? "")"

                if let number1 = roadAddrLand["number1"].string,
                   !number1.isEmpty {
                  address += " "
                  address += number1
                }
                if let number2 = roadAddrLand["number2"].string,
                   !number2.isEmpty {
                  address += "-"
                  address += number2
                }

                owner.stationInstall(coordinate: coordinate, address: address)
              } else if results.contains(where: { $0["name"].stringValue == "addr" }) {
                // 도로명 주소가 없을 경우 지번 주소를 리턴
                guard let addr = results.filter({ $0["name"].stringValue == "addr" }).first,
                      addr["region"].exists(),
                      addr["land"].exists() else {
                        WSLoadingIndicator.stopLoad()
                        owner.output.didOccurErrorWithAddressNotExist.accept(())
                        return
                      }

                let addrRegion = addr["region"]
                let addrLand = addr["land"]

                address = "\(addrRegion["area1"]["name"].string ?? "") " +
                "\(addrRegion["area2"]["name"].string ?? "") " +
                "\(addrRegion["area3"]["name"].string ?? "")"

                if let number1 = addrLand["number1"].string,
                   !number1.isEmpty {
                  address += " "
                  address += number1
                }
                if let number2 = addrLand["number2"].string,
                   !number2.isEmpty {
                  address += "-"
                  address += number2
                }

                owner.stationInstall(coordinate: coordinate, address: address)
              } else {
                WSLoadingIndicator.stopLoad()
                owner.output.didOccurErrorWithAddressNotExist.accept(())
                return
              }
            } else {
              WSLoadingIndicator.stopLoad()
              owner.output.didOccurErrorWithAddressNotExist.accept(())
              return
            }
          case .failure:
            WSLoadingIndicator.stopLoad()
            owner.output.didOccurErrorWithAddressNotExist.accept(())
            return
          }
        }
      }).disposed(by: rx.disposeBag)

    self.input.tapRequestCloseButton
      .withUnretained(self)
      .subscribe(onNext: { owner, wsAnnotationCount in
        owner.stationRequestMode.accept(false)
        if wsAnnotationCount > 0 {
          owner.output.requestButtonHidden.accept(true)
        }
      }).disposed(by: rx.disposeBag)
  }

  private func stationInstall(coordinate: CLLocationCoordinate2D, address: String) {
    WSLoadingIndicator.startLoad()
    let realm = try! Realm()
    let token = realm.objects(UserStore.self).first?.token ?? ""
    WSNetwork.request(target: .requestStationInstall(token: token,
                                                     latitude: coordinate.latitude,
                                                     longitude: coordinate.longitude,
                                                     address: address)) { [weak self] result in
      switch result {
      case .success(let json):
        if let result = json["result"].bool,
           result {
          WSLoadingIndicator.stopLoad()
          self?.output.didStationRequestSuccessfully.accept(())
        } else {
          WSLoadingIndicator.stopLoad()
          self?.output.didStationRequestUnsuccessfully.accept(())
        }
      case .failure:
        WSLoadingIndicator.stopLoad()
        self?.output.didStationRequestUnsuccessfully.accept(())
      }
    }
  }

}
