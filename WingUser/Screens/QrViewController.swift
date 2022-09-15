//
//  QrViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/03.
//

import AVFoundation
import UIKit

class QrViewController: UIViewController {

  private lazy var backwardButton: UIButton = UIButton().then {
    $0.setImage(.init(systemName: "arrow.backward"), for: .normal)
    $0.imageView?.tintColor = .white
  }

  private lazy var capsuleLabel: CapsuleLabel = CapsuleLabel(text: "QR 코드를 사각형에 맞춰주세요",
                                                             backgroundColor: .systemYellow,
                                                             labelColor: .black,
                                                             vPadding: 10)

  private lazy var fakeScanView: UIView = UIView().then {
    $0.backgroundColor = .clear
  }

  private lazy var flashBubble: BubbleWithTitle = BubbleWithTitle(bubble: {
    Bubble(size: 56, image: .init(systemName: "bolt.fill"), color: .label)
  }, name: "플래시", labelColor: .white.withAlphaComponent(0.7))

  private lazy var numberBubble: BubbleWithTitle = BubbleWithTitle(bubble: {
    Bubble(size: 56, image: .init(systemName: "keyboard"), color: .label)
  }, name: "번호입력", labelColor: .white.withAlphaComponent(0.7))

  private var captureSession: AVCaptureSession?

  private var videoPreviewLayer: AVCaptureVideoPreviewLayer?

  private var metadataOutput: AVCaptureMetadataOutput?

  private let focusAreaRatio: CGFloat = 0.64

  private var focusArea: CGRect {
    let focusSize: CGFloat = view.bounds.width * focusAreaRatio

    return .init(x: (view.bounds.width / 2) - (focusSize / 2),
                 y: (view.bounds.height / 2) - (focusSize / 2),
                 width: focusSize,
                 height: focusSize
    )
  }

  let viewModel = QrViewModel(input: QrInput(), output: QrOutput())

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraSetting()
    setPreviewLayer()

    view.addSubview(backwardButton)
    view.addSubview(capsuleLabel)
    view.addSubview(fakeScanView)
    view.addSubview(flashBubble)
    view.addSubview(numberBubble)

    backwardButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.size.equalTo(24)
    }
    fakeScanView.snp.makeConstraints {
      $0.size.equalTo(self.focusArea.size)
      $0.center.equalToSuperview()
    }
    capsuleLabel.snp.makeConstraints {
      $0.bottom.equalTo(fakeScanView.snp.top).offset(-16)
      $0.centerX.equalTo(fakeScanView.snp.centerX)
    }
    flashBubble.snp.makeConstraints {
      $0.top.equalTo(fakeScanView.snp.bottom).offset(24)
      $0.leading.equalTo(fakeScanView.snp.leading).offset(24)
    }
    numberBubble.snp.makeConstraints {
      $0.top.equalTo(fakeScanView.snp.bottom).offset(24)
      $0.trailing.equalTo(fakeScanView.snp.trailing).offset(-24)
    }

    backwardButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        if owner.presentingViewController != nil {
          owner.dismiss(animated: true)
        }
      }).disposed(by: rx.disposeBag)

    flashBubble.bubble.rx
      .tapGesture()
      .when(.recognized)
      .map { _ in () }
      .bind(to: self.viewModel.input.tapFlashBubble)
      .disposed(by: rx.disposeBag)

    viewModel.output.didTapFlashBubble
      .map { (isOn: Bool) -> UIColor in isOn ? .systemYellow : .white }
      .bind(to: self.flashBubble.bubble.rx.backColor)
      .disposed(by: rx.disposeBag)

    viewModel.output.didTapFlashBubble
      .withUnretained(self)
      .subscribe(onNext: { owner, isOn in
        owner.changeTorchMode(to: isOn)
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithComponentIsInvalid
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "QR코드 에러", message: "스테이션 ID를 불러올 수 없습니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.enableReadMetadata()
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithNetworking
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "QR코드 에러", message: "네트워크 상태를 다시 한 번 확인해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.enableReadMetadata()
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didFetchStationInformationSuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, property in
        owner.present(UINavigationController(rootViewController: ChargeCheckViewController().then {
          $0.viewModel.stationProperty = property
        }).then {
          $0.modalPresentationStyle = .fullScreen
        }, animated: true)
      }).disposed(by: rx.disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let captureSession = captureSession {
      if !captureSession.isRunning {
        enableReadMetadata()
      }
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    if let captureSession = captureSession {
      if captureSession.isRunning {
        disableReadMetadata()
      }
    }
  }

  private func changeTorchMode(to boolean: Bool) {
    guard let device = AVCaptureDevice.default(for: .video),
          device.hasTorch else {
            return
          }

    do {
      try device.lockForConfiguration()

      if boolean {
        try device.setTorchModeOn(level: 1.0)
      } else {
        device.torchMode = .off
      }

      device.unlockForConfiguration()
    } catch {
      self.alert(title: "손전등 에러", message: "손전등을 토글에 에러가 발생했습니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
    }
  }

}

// MARK: - Camera Setting

extension QrViewController {

  private func cameraSetting() {
    self.captureSession = .init()
    guard let captureSession = self.captureSession,
          let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
          }

    let input: AVCaptureDeviceInput
    do {
      input = try AVCaptureDeviceInput(device: captureDevice)
    } catch _ {
      return
    }

    if captureSession.canAddInput(input) {
      captureSession.addInput(input)
    }
  }

  private func setPreviewLayer() {
    guard let captureSession = self.captureSession else {
      return
    }

    self.videoPreviewLayer = .init(session: captureSession).then { cameraLayer in
      cameraLayer.videoGravity = .resizeAspectFill
      cameraLayer.frame = view.layer.bounds

      let path = CGMutablePath().then { mutablePath in
        mutablePath.addRect(view.layer.bounds)
        mutablePath.addPath(UIBezierPath(roundedRect: self.focusArea, cornerRadius: 16.0).cgPath)
      }

      let maskLayer = CAShapeLayer().then { mask in
        mask.path = path
        mask.fillColor = UIColor.black.withAlphaComponent(0.51).cgColor
        mask.fillRule = .evenOdd
      }

      let outerLayer = CAShapeLayer().then { outer in
        let outerWidth: CGFloat = 6.0

        outer.path = UIBezierPath(roundedRect: self.focusArea, cornerRadius: 16.0).cgPath
        outer.lineWidth = outerWidth
        outer.strokeColor = UIColor.systemYellow.withAlphaComponent(0.9).cgColor
        outer.fillColor = UIColor.clear.cgColor
      }

      cameraLayer.addSublayer(maskLayer)
      cameraLayer.addSublayer(outerLayer)
    }

    if let previewLayer = self.videoPreviewLayer {
      view.layer.addSublayer(previewLayer)
    }
  }

  private func enableReadMetadata() {
    if let metadataOutput = self.metadataOutput {
      add(output: metadataOutput)
    } else {
      let output = AVCaptureMetadataOutput()
      self.metadataOutput = output

      add(output: output)
    }
    captureSession?.startRunning()
    if let videoPreviewLayer = self.videoPreviewLayer {
      metadataOutput?.rectOfInterest = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: self.focusArea)
    }
  }

  private func disableReadMetadata() {
    if let metadataOutput = self.metadataOutput {
      remove(output: metadataOutput)
    }
    captureSession?.stopRunning()
  }

  private func add(output: AVCaptureMetadataOutput) {
    guard let captureSession = self.captureSession else {
      return
    }

    if captureSession.canAddOutput(output) {
      captureSession.addOutput(output)
      output.setMetadataObjectsDelegate(self, queue: .main)
      output.metadataObjectTypes = [.qr]
    }
  }

  private func remove(output: AVCaptureMetadataOutput) {
    guard let captureSession = self.captureSession else {
      return
    }

    captureSession.removeOutput(output)
  }

}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QrViewController: AVCaptureMetadataOutputObjectsDelegate {

  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    disableReadMetadata()

    UINotificationFeedbackGenerator().then {
      $0.prepare()
    }.notificationOccurred(.success)

    guard let metadataObject = metadataObjects.first,
          let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
          let string = readableObject.stringValue else {
            alert(title: "QR코드 에러", message: "유효하지 않은 QR코드 값입니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { [weak self] _ in
              self?.enableReadMetadata()
            }])
            return
          }
    
    viewModel.input.urlComponent.accept(URLComponents(string: string))
  }

}
