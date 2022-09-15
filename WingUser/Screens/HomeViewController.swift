//
//  HomeViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/03.
//

import MapKit
import UIKit

class HomeViewController: UIViewController {

  private var mapUserInteraction = false

  private let defaultLocation = CLLocationCoordinate2D(latitude: 37.554812178624516,
                                                       longitude: 126.97057517675293)

  lazy var mapView: MKMapView = MKMapView().then {
    $0.mapType = .standard
    $0.setCenter(defaultLocation, animated: false)
    $0.showsUserLocation = true
    $0.delegate = self
  }

  private lazy var centerAnnotationView: MKMarkerAnnotationView = MKMarkerAnnotationView()

  private lazy var locationManager: CLLocationManager = CLLocationManager().then {
    $0.desiredAccuracy = kCLLocationAccuracyBest
    $0.delegate = self
  }

  private lazy var fakeSearchBar: FakeSearchBar = FakeSearchBar(fakeText: "위치를 검색해주세요")

  private lazy var centerBubble: Bubble = Bubble(size: 48,
                                                 image: .init(systemName: "scope"),
                                                 color: .systemYellow)

  private lazy var requestButton: CTAButton = CTAButton(text: "-").then {
    $0.textLabel.font = .boldSystemFont(ofSize: 12)
  }

  private lazy var requestCloseButton: Bubble = Bubble(image: .init(systemName: "xmark"), color: .label)

  let viewModel: HomeViewModel = .init(input: HomeViewInput(), output: HomeViewOutput())

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(mapView)
    view.addSubview(centerAnnotationView)
    view.addSubview(fakeSearchBar)
    view.addSubview(centerBubble)
    view.addSubview(requestButton)
    view.addSubview(requestCloseButton)

    mapView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
    }
    centerAnnotationView.snp.makeConstraints {
      $0.center.equalTo(mapView.snp.center)
    }
    fakeSearchBar.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(48)
    }
    centerBubble.snp.makeConstraints {
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
    }
    requestButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.centerY.equalTo(centerBubble.snp.centerY)
    }
    requestCloseButton.snp.makeConstraints {
      $0.centerX.equalTo(requestButton.snp.centerX)
      $0.bottom.equalTo(requestButton.snp.top).offset(-8)
      $0.size.equalTo(32)
    }

    locationManager.requestWhenInUseAuthorization()

    viewModel.output.changeMode
      .asDriver(onErrorJustReturn: false)
      .drive { [weak self] in
        self?.changeCenterMode(to: $0)
      }.disposed(by: rx.disposeBag)

    viewModel.output.stationAnnotations
      .asDriver(onErrorJustReturn: [])
      .distinctUntilChanged {
        guard $0.count == $1.count else { return false }
        return $0.map { $0.property.stationId }.sorted() == $1.map { $0.property.stationId }.sorted()
      }
      .drive { [weak self] in
        self?.mapView.removeAnnotations(self?.mapView.annotations.filter { $0 is WSAnnotation } ?? [])
        self?.mapView.addAnnotations($0)
      }.disposed(by: rx.disposeBag)

    viewModel.output.requestButtonText
      .bind(to: self.requestButton.textLabel.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.requestButtonCondition
      .bind(to: self.requestButton.rx.condition)
      .disposed(by: rx.disposeBag)

    viewModel.output.requestButtonHidden
      .bind(to: self.requestButton.rx.isHidden)
      .disposed(by: rx.disposeBag)

    viewModel.output.requestCloseButtonHidden
      .bind(to: self.requestCloseButton.rx.isHidden)
      .disposed(by: rx.disposeBag)

    viewModel.output.centerAnnotationHidden
      .bind(to: self.centerAnnotationView.rx.isHidden)
      .disposed(by: rx.disposeBag)

    viewModel.output.didTapRequestButton
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "스테이션 설치요청", message: "마커 위치에 스테이션 설치를 요청하시겠습니까?", style: .alert, actions: [
          UIAlertAction(title: "취소", style: .cancel),
          UIAlertAction(title: "요청", style: .default) { _ in
            owner.viewModel.input.tapRequestAcceptButton.accept(owner.mapView.centerCoordinate)
          }
        ])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithUserNotExist
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "회원가입이 필요합니다",
                    message: "회원가입 후 이용 가능한 서비스입니다. 가입을 진행하시겠습니까?",
                    style: .alert,
                    actions: [
                      UIAlertAction(title: "가입할래요", style: .default, handler: { _ in
                        owner.present(UINavigationController(rootViewController: SignUpPhoneViewController()).then {
                          $0.modalPresentationStyle = .fullScreen
                        }, animated: true)
                      }),
                      UIAlertAction(title: "나중에 할래요", style: .cancel)
                    ])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithAddressNotExist
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "스테이션 설치요청 실패", message: "주소를 받아올 수 없습니다. 다시 한 번 시도해주십시오.", style: .alert, actions: [
          UIAlertAction(title: "확인", style: .cancel)
        ])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didStationRequestSuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "스테이션 설치요청 완료", message: "스테이션 설치를 요청하였습니다.", style: .alert, actions: [
          UIAlertAction(title: "확인", style: .cancel)
        ]) {
          let wsAnnotationCount = owner.mapView.annotations.filter { $0 is WSAnnotation }.count
          owner.viewModel.input.tapRequestCloseButton.accept(wsAnnotationCount)
        }
      }).disposed(by: rx.disposeBag)

    viewModel.output.didStationRequestUnsuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "스테이션 설치요청 실패", message: "스테이션 설치를 요청하지 못했습니다. 다시 한 번 시도해주십시오.", style: .alert, actions: [
          UIAlertAction(title: "확인", style: .cancel)
        ])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTapRequestCloseButton
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let bottomLeft = MKMapPoint(x: owner.mapView.visibleMapRect.minX, y: owner.mapView.visibleMapRect.maxY).coordinate
        let topRight = MKMapPoint(x: owner.mapView.visibleMapRect.maxX, y: owner.mapView.visibleMapRect.minY).coordinate

        owner.viewModel.input.requestAnnotations.accept((bottomLeft: bottomLeft, topRight: topRight))
      }).disposed(by: rx.disposeBag)

    fakeSearchBar.isHidden = true

    fakeSearchBar.rx
      .tapGesture()
      .when(.recognized)
      .subscribe { [weak self] _ in
        self?.present(AddressSearchViewController().then {
          $0.modalPresentationStyle = .fullScreen
          $0.previousViewController = self
        }, animated: true)
      }.disposed(by: rx.disposeBag)

    centerBubble.rx
      .tapGesture()
      .when(.recognized)
      .subscribe { [weak self] _ in
        self?.viewModel.input.changeCenterMode.accept(true)
      }.disposed(by: rx.disposeBag)

    requestButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.viewModel.input.tapRequestButton.accept(())
      }).disposed(by: rx.disposeBag)

    requestCloseButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let wsAnnotationCount = owner.mapView.annotations.filter { $0 is WSAnnotation }.count
        owner.viewModel.input.tapRequestCloseButton.accept(wsAnnotationCount)
      }).disposed(by: rx.disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    locationManager.startUpdatingLocation()
    locationManager.startMonitoringSignificantLocationChanges()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    self.viewModel.input.tapRequestCloseButton.accept(self.mapView.annotations.filter { $0 is WSAnnotation }.count)

    locationManager.stopUpdatingLocation()
    locationManager.stopMonitoringSignificantLocationChanges()
  }

  private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
    if let gestureRecognizers = mapView.subviews[0].gestureRecognizers {
      for recognizer in gestureRecognizers {
        if (recognizer.state == .began || recognizer.state == .ended) {
          return true
        }
      }
    }
    return false
  }

  private func trackingMode() {
    if CLLocationManager.locationServicesEnabled() {
      let locationAuthStatus: CLAuthorizationStatus
      if #available(iOS 14.0, *) {
        locationAuthStatus = locationManager.authorizationStatus
      } else {
        locationAuthStatus = CLLocationManager.authorizationStatus()
      }

      switch locationAuthStatus {
      case .notDetermined, .denied, .restricted:
        break
      default:
        if let currentLocation = locationManager.location?.coordinate {
          mapView.setRegion(.init(center: currentLocation,
                                  latitudinalMeters: 150,
                                  longitudinalMeters: 150), animated: false)
        }
      }
    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }

  private func changeCenterMode(to mode: Bool) {
    if (mode) {
      mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    centerBubble.imageColor = mode ? .systemYellow : .label
  }

}

// MARK: - CLLocationManagerDelegate

extension HomeViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
    case .authorizedWhenInUse, .authorizedAlways, .authorized:
      trackingMode()
    case .restricted, .denied:
      break
    @unknown default:
      break
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard viewModel.output.changeMode.value,
          let newLocation = locations.first else { return }

    mapView.setCenter(newLocation.coordinate, animated: true)
  }

}

// MARK: - MKMapviewDelegate

extension HomeViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    mapUserInteraction = mapViewRegionDidChangeFromUserInteraction()

    if (mapUserInteraction) {
      self.viewModel.input.changeCenterMode.accept(false)
    }
  }

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    let bottomLeft = MKMapPoint(x: mapView.visibleMapRect.minX, y: mapView.visibleMapRect.maxY).coordinate
    let topRight = MKMapPoint(x: mapView.visibleMapRect.maxX, y: mapView.visibleMapRect.minY).coordinate

    self.viewModel.input.requestAnnotations.accept((bottomLeft: bottomLeft, topRight: topRight))
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    switch annotation {
    case is WSAnnotation:
      guard let _annotation = annotation as? WSAnnotation else {
        return nil
      }

      let annotationView = MKAnnotationView().then {
        $0.image = _annotation.property.available ? .init(named: "mark.on") : .init(named: "mark.off")
        $0.annotation = _annotation
        $0.canShowCallout = true
      }
      let button = UIButton(type: .infoDark)
      annotationView.rightCalloutAccessoryView = button

      return annotationView
    default:
      return nil
    }
  }

  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    guard let annotation = view.annotation as? WSAnnotation else {
      return
    }

    self.present(StationPortListViewController().then {
      $0.modalPresentationStyle = .fullScreen
      $0.viewModel.input.setStationName.accept(annotation.property.name)
      $0.viewModel.input.setStationAddress.accept(annotation.property.address)
      $0.viewModel.input.requestPortState.accept(annotation.property.stationId)
    }, animated: true)
  }

}
