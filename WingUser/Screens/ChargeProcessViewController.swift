//
//  ChargeProcessViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/16.
//

import UIKit

class ChargeProcessViewController: UIViewController {

  private lazy var fakeSearchBar: FakeSearchBar = FakeSearchBar(fakeText: "-",
                                                                textColor: .label)

  private lazy var portNumberLabel: UILabel = UILabel().then {
    $0.textColor = .systemOrange
    $0.font = .boldSystemFont(ofSize: 16)
    $0.text = "-"
  }

  private lazy var simpleGuideLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
    $0.textColor = .systemGray
    $0.font = .systemFont(ofSize: 18)
    $0.text = "-"
    $0.textAlignment = .center
  }

  private lazy var portHeadImageView: UIImageView = UIImageView(image: .init(named: "port.head.none")).then {
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .systemGray4
  }

  private lazy var detailGuideBackgroundView: UIView = UIView().then {
    $0.backgroundColor = .systemGray6
    $0.layer.cornerRadius = 8.0
    $0.layer.masksToBounds = true
  }

  private lazy var detailGuideLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
    $0.font = .systemFont(ofSize: 14)
    $0.text = "-"
    $0.textAlignment = .center
  }

  private lazy var closeButton: CTAButton = CTAButton(text: "닫기", condition: .normal)

  let viewModel = ChargeProcessViewModel(input: ChargeProcessInput(), output: ChargeProcessOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    navigationItem.title = "충전기기 확인"

    detailGuideBackgroundView.addSubview(detailGuideLabel)

    view.addSubview(fakeSearchBar)
    view.addSubview(portNumberLabel)
    view.addSubview(simpleGuideLabel)
    view.addSubview(portHeadImageView)
    view.addSubview(detailGuideBackgroundView)
    view.addSubview(closeButton)

    fakeSearchBar.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(48)
    }
    portNumberLabel.snp.makeConstraints {
      $0.bottom.equalTo(simpleGuideLabel.snp.top).offset(-8)
      $0.centerX.equalToSuperview()
    }
    simpleGuideLabel.snp.makeConstraints {
      $0.bottom.equalTo(portHeadImageView.snp.top).offset(-24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.centerX.equalToSuperview()
    }
    portHeadImageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.size.equalTo(UIScreen.main.bounds.height * 0.179802)
    }
    detailGuideLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(18)
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
    }
    detailGuideBackgroundView.snp.makeConstraints {
      $0.top.equalTo(portHeadImageView.snp.bottom).offset(32)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(detailGuideLabel.snp.bottom).offset(18)
    }
    closeButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(60)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    closeButton.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.presentingViewController?.presentingViewController?.dismiss(animated: true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.fakeText
      .bind(to: self.fakeSearchBar.rx.fakeText)
      .disposed(by: rx.disposeBag)

    viewModel.output.portText
      .bind(to: self.portNumberLabel.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.portImage
      .bind(to: self.portHeadImageView.rx.image)
      .disposed(by: rx.disposeBag)

    viewModel.output.isChargeNow
      .withUnretained(self)
      .subscribe(on: MainScheduler.instance)
      .subscribe(onNext: { owner, pack in
        owner.simpleGuideLabel.text = pack.simpleGuide
        owner.simpleGuideLabel.textColor = pack.simpleGuideColor
        owner.portHeadImageView.tintColor = pack.portTintColor
        owner.detailGuideLabel.text = pack.detailGuide
        owner.closeButton.isHidden = pack.closeButtonHidden
      }).disposed(by: rx.disposeBag)

    viewModel.output.didChargeCancel
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "충전 취소", message: "충전이 취소되었습니다. 충전을 다시 시도해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.navigationController?.popViewController(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithNetworking
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "충전준비 에러", message: "네트워크 상태를 다시 한 번 확인해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.navigationController?.popViewController(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithPortReady
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "충전준비 에러", message: "충전준비 처리 중 에러가 발생하였습니다. 충전을 다시 시도해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.navigationController?.popViewController(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithPortCancel
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "충전취소 에러", message: "충전취소 처리 중 에러가 발생하였습니다. 충전을 다시 시도해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.navigationController?.popViewController(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithLoginFailure
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "에러", message: "접근할 수 없습니다. 관리자에게 문의 바랍니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.navigationController?.popViewController(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.input.appearSignal.accept(())
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    viewModel.input.disappearSignal.accept(())
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    var mutatingSelf = self
    mutatingSelf.rx.disposeBag = DisposeBag()
  }
  
}
