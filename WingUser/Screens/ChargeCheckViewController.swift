//
//  ChargeCheckViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/16.
//

import UIKit

class ChargeCheckViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
    $0.attributedText = "<s24b>충전하실 기기를\n확인해주세요</s24b>".wsAttributed
  }

  private lazy var voltageCircle: CircleTemplate = CircleTemplate(background: .init(named: "circle.volt"),
                                                                  tintColor: .systemYellow,
                                                                  text: "-")

  private lazy var ampereCircle: CircleTemplate = CircleTemplate(background: .init(named: "circle.ampere"),
                                                                 tintColor: .systemYellow,
                                                                 text: "-")

  private lazy var portCircle: CircleTemplate = CircleTemplate(background: .init(named: "port.head.none"))

  private lazy var circleStack: UIStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.spacing = 24
  }

  private lazy var detailLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
    $0.font = .systemFont(ofSize: 14)
    $0.text = """
충전규격이 다를 경우 다음과 같은 상황이
발생할 수 있으니 주의하십시오.
"""
  }

  private lazy var subscriptBackgroundView: UIView = UIView().then {
    $0.backgroundColor = .systemGray6
    $0.layer.cornerRadius = 8.0
    $0.layer.masksToBounds = true
  }

  private lazy var subscriptLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
    $0.font = .systemFont(ofSize: 14)

    let firstString = NSMutableAttributedString().then { stringBuilder in
      let attachment = NSTextAttachment().then { att in
        att.image = UIImage(systemName: "1.circle.fill")?.withTintColor(.label)
      }

      stringBuilder.append(NSAttributedString(attachment: attachment))
      stringBuilder.append(NSAttributedString(string: " 이용자의 기기 고장"))
    }
    let secondString = NSMutableAttributedString().then { stringBuilder in
      let attachment = NSTextAttachment().then { att in
        att.image = UIImage(systemName: "2.circle.fill")?.withTintColor(.label)
      }

      stringBuilder.append(NSAttributedString(attachment: attachment))
      stringBuilder.append(NSAttributedString(string: " 충전소의 고장"))
    }
    let thirdString = NSMutableAttributedString().then { stringBuilder in
      let attachment = NSTextAttachment().then { att in
        att.image = UIImage(systemName: "3.circle.fill")?.withTintColor(.label)
      }

      stringBuilder.append(NSAttributedString(attachment: attachment))
      stringBuilder.append(NSAttributedString(string: " 폭발 및 화재 위험"))
    }
    let fullString = NSMutableAttributedString().then {
      $0.append(firstString)
      $0.append(NSAttributedString(string: "\n\n"))
      $0.append(secondString)
      $0.append(NSAttributedString(string: "\n\n"))
      $0.append(thirdString)
    }

    $0.attributedText = fullString
  }

  private lazy var compabilityButton: UIButton = UIButton().then {
    $0.setTitle("호환되는 킥보드 종류를 알고 싶어요!", for: .normal)
    $0.setTitleColor(.systemOrange, for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 14.0)
  }

  private lazy var checkButton: CTAButton = CTAButton(text: "확인했어요", condition: .normal)

  private lazy var changeButton: CTAButton = CTAButton(text: "충전규격을 바꾸고 싶어요", condition: .option(lightForced: false))

  let viewModel = ChargeCheckViewModel(input: ChargeCheckInput(), output: ChargeCheckOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    if presentingViewController != nil {
      navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil), animated: true)
      navigationItem.title = "충전규격 확인"
    }

    circleStack.addArrangedSubview(voltageCircle)
    circleStack.addArrangedSubview(ampereCircle)
    circleStack.addArrangedSubview(portCircle)
    subscriptBackgroundView.addSubview(subscriptLabel)

    view.addSubview(titleLabel)
    view.addSubview(circleStack)
    view.addSubview(detailLabel)
    view.addSubview(subscriptBackgroundView)
    view.addSubview(compabilityButton)
    view.addSubview(checkButton)
    view.addSubview(changeButton)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    circleStack.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(36)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(portCircle.snp.width)
    }
    detailLabel.snp.makeConstraints {
      $0.top.equalTo(circleStack.snp.bottom).offset(36)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    subscriptLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(18)
      $0.leading.equalToSuperview().offset(18)
      $0.trailing.equalToSuperview().offset(-18)
    }
    subscriptBackgroundView.snp.makeConstraints {
      $0.top.equalTo(detailLabel.snp.bottom).offset(16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(subscriptLabel.snp.bottom).offset(20)
    }
    compabilityButton.snp.makeConstraints {
      $0.top.equalTo(subscriptBackgroundView.snp.bottom).offset(16)
      $0.centerX.equalTo(view.layoutMarginsGuide.snp.centerX)
    }
    checkButton.snp.makeConstraints {
      $0.bottom.equalTo(changeButton.snp.top).offset(-16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(60)
    }
    changeButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.height.equalTo(60)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigationItem.leftBarButtonItem?.rx
      .tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.dismiss(animated: true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.didFetchUserPortSuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, pack in
        owner.voltageCircle.backgroundTintColor = .systemYellow
        owner.ampereCircle.backgroundTintColor = .systemYellow
        owner.voltageCircle.subscript = "\(String(format: "%.2f", pack.1)) V"
        owner.ampereCircle.subscript = "\(String(format: "%.1f", pack.2)) A"
        switch pack.0 {
        case .none:
          owner.portCircle.backgroundImage = .init(named: "port.head.none")
        case .gx:
          owner.portCircle.backgroundImage = .init(named: "port.head.gx")
        case .dc8:
          owner.portCircle.backgroundImage = .init(named: "port.head.dc8")
        }
      }).disposed(by: rx.disposeBag)

    viewModel.output.didFetchUserPortUnsuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "사용자 정보 에러", message: "사용자 정보를 불러오지 못했습니다. 다시 시도해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.presentingViewController?.presentingViewController?.dismiss(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithNetworking
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "충전준비 에러", message: "네트워크 상태를 다시 한 번 확인해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.presentingViewController?.presentingViewController?.dismiss(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTapCheckButton
      .withUnretained(self)
      .subscribe(onNext: { owner, pack in
        owner.navigationController?.pushViewController(ChargeProcessViewController().then {
          $0.viewModel.stationProperty = pack.property
          $0.viewModel.portType = pack.portType
        }, animated: true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTapChageButton
      .withUnretained(self)
      .subscribe(onNext: { owner, pack in
        owner.present(UINavigationController(rootViewController: ChargePortModifyViewController().then {
          $0.viewModel.portStream.accept((port: pack.0, voltage: pack.1, ampere: pack.2))
        }).then {
          $0.modalPresentationStyle = .fullScreen
        }, animated: true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTapCompabilityButton
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.present(WebViewController(url: WSConst.compabilityAddress), animated: true)
      }).disposed(by: rx.disposeBag)

    self.checkButton.rx
      .tapGesture()
      .when(.recognized)
      .map { _ in () }
      .bind(to: self.viewModel.input.tapCheckButton)
      .disposed(by: rx.disposeBag)
//      .withUnretained(self)
//      .subscribe(onNext: { owner, _ in
//        owner.navigationController?.pushViewController(ChargeProcessViewController().then {
//          $0.viewModel.stationProperty = owner.viewModel.stationProperty
//        }, animated: true)
//      }).disposed(by: rx.disposeBag)

    self.changeButton.rx
      .tapGesture()
      .when(.recognized)
      .map { _ in () }
      .bind(to: viewModel.input.tapChangeButton)
      .disposed(by: rx.disposeBag)

    self.compabilityButton.rx
      .tapGesture()
      .when(.recognized)
      .map { _ in () }
      .bind(to: viewModel.input.tapCompabilityButton)
      .disposed(by: rx.disposeBag)

    viewModel.input.appearSignal.accept(())
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    var mutatingSelf = self
    mutatingSelf.rx.disposeBag = DisposeBag()
  }

}
