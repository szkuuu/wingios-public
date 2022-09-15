//
//  MyPageViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/03.
//

import UIKit

class MyPageViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>마이페이지</s24b>".wsAttributed
  }

  private lazy var nameSubtitle: UILabel = UILabel().then {
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    $0.font = .systemFont(ofSize: 12)
    $0.text = "이름"
  }

  private lazy var nameTextField: UnderlineTextField = UnderlineTextField().then {
    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    $0.isUserInteractionEnabled = false
  }

  private lazy var emailSubtitle: UILabel = UILabel().then {
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    $0.font = .systemFont(ofSize: 12)
    $0.text = "이메일"
  }

  private lazy var emailTextField: UnderlineTextField = UnderlineTextField().then {
    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    $0.isUserInteractionEnabled = false
  }

  private lazy var cardSubtitle: UILabel = UILabel().then {
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    $0.font = .systemFont(ofSize: 12)
    $0.text = "카드"
  }

  private lazy var cardTextField: UnderlineTextField = UnderlineTextField().then {
    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    $0.isUserInteractionEnabled = false
  }

  private lazy var cardAddButton: UIButton = UIButton(type: .contactAdd).then {
    $0.setImage(.init(named: "plus.circle"), for: .normal)
    $0.tintColor = .systemGray
  }

  private lazy var divider1: DividerCell = DividerCell().then {
    $0.configure(with: .init(height: 4, color: .systemGray6))
  }

  private lazy var chargeSubtitle: UILabel = UILabel().then {
    $0.attributedText = "<s18b>충전규격</s18b>".wsAttributed
  }

  private lazy var chargeEditButton: UIButton = UIButton().then {
    let attributedString = NSMutableAttributedString().then { stringBuilder in
      let attachment = NSTextAttachment().then { att in
        att.image = UIImage(systemName: "chevron.forward")?.withTintColor(.label)
      }

      stringBuilder.append(NSAttributedString(string: "수정하기 "))
      stringBuilder.append(NSAttributedString(attachment: attachment))
    }
    $0.setAttributedTitle(attributedString, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 14)
  }

  private lazy var voltageCircle: CircleTemplate = CircleTemplate(background: .init(named: "circle.volt"),
                                                                  text: "")

  private lazy var ampereCircle: CircleTemplate = CircleTemplate(background: .init(named: "circle.ampere"),
                                                                 text: "")

  private lazy var portCircle: CircleTemplate = CircleTemplate(background: .init(named: "port.head.none"))

  private lazy var circleStack: UIStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.spacing = 24
  }

  private lazy var divider2: DividerCell = DividerCell().then {
    $0.configure(with: .init(height: 4, color: .systemGray6))
  }

  private lazy var noticeBelow: BelowCon = BelowCon(icon: .init(named: "speaker"), subscript: "공지사항")

  private lazy var verticalDivider: UIView = UIView().then {
    $0.backgroundColor = .systemGray6
  }

  private lazy var askBelow: BelowCon = BelowCon(icon: .init(named: "notice"), subscript: "문의하기")

  private lazy var scrollView: UIScrollView = UIScrollView().then {
    $0.backgroundColor = .systemBackground
  }

  private lazy var contentView: UIView = UIView().then {
    $0.backgroundColor = .systemBackground
  }

  private lazy var underButton: CTAButton = CTAButton(text: "", condition: .normal)

  let viewModel = MyPageViewModel(input: MyPageInput(), output: MyPageOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    circleStack.addArrangedSubview(voltageCircle)
    circleStack.addArrangedSubview(ampereCircle)
    circleStack.addArrangedSubview(portCircle)

    // 1. 개인정보 블럭
    contentView.addSubview(nameSubtitle)
    contentView.addSubview(nameTextField)
    contentView.addSubview(emailSubtitle)
    contentView.addSubview(emailTextField)
    contentView.addSubview(cardSubtitle)
    contentView.addSubview(cardTextField)
    contentView.addSubview(cardAddButton)

    contentView.addSubview(divider1)

    // 2. 충전규격 블럭
    contentView.addSubview(chargeSubtitle)
    contentView.addSubview(chargeEditButton)
    contentView.addSubview(circleStack)

    contentView.addSubview(divider2)

    // 3. 공지사항 문의하기
    contentView.addSubview(noticeBelow)
    contentView.addSubview(verticalDivider)
    contentView.addSubview(askBelow)

    scrollView.addSubview(contentView)

    view.addSubview(titleLabel)
    view.addSubview(scrollView)
    view.addSubview(underButton)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    scrollView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(underButton.snp.top).offset(-16)
    }
    if let horizontallyLongestSubtitle = [nameSubtitle, emailSubtitle, cardSubtitle].max(by: {
      $0.intrinsicContentSize.width < $1.intrinsicContentSize.width
    }) {
      nameSubtitle.snp.makeConstraints {
        $0.top.equalToSuperview().offset(24)
        $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      }
      nameTextField.snp.makeConstraints {
        $0.leading.equalTo(horizontallyLongestSubtitle.snp.trailing).offset(20)
        $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
        $0.centerY.equalTo(nameSubtitle.snp.centerY)
      }
      emailSubtitle.snp.makeConstraints {
        $0.top.equalTo(nameTextField.snp.bottom).offset(nameTextField.intrinsicContentSize.height / 2)
        $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      }
      emailTextField.snp.makeConstraints {
        $0.leading.equalTo(horizontallyLongestSubtitle.snp.trailing).offset(20)
        $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
        $0.centerY.equalTo(emailSubtitle.snp.centerY)
      }
      cardSubtitle.snp.makeConstraints {
        $0.top.equalTo(emailTextField.snp.bottom).offset(emailTextField.intrinsicContentSize.height / 2)
        $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      }
      cardTextField.snp.makeConstraints {
        $0.leading.equalTo(horizontallyLongestSubtitle.snp.trailing).offset(20)
        $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
        $0.centerY.equalTo(cardSubtitle.snp.centerY)
      }
      cardAddButton.snp.makeConstraints {
        $0.trailing.equalTo(cardTextField.snp.trailing).offset(-8)
        $0.centerY.equalTo(cardTextField.snp.centerY)
        $0.height.equalTo(cardTextField.intrinsicContentSize.height - 8)
      }
    }
    divider1.snp.makeConstraints {
      $0.top.equalTo(cardTextField.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(divider1.height ?? 1)
    }
    chargeSubtitle.snp.makeConstraints {
      $0.top.equalTo(divider1.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    chargeEditButton.snp.makeConstraints {
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.centerY.equalTo(chargeSubtitle.snp.centerY)
    }
    circleStack.snp.makeConstraints {
      $0.top.equalTo(chargeSubtitle.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(32)
      $0.trailing.equalToSuperview().offset(-32)
      $0.height.equalTo(portCircle.snp.width)
    }
    divider2.snp.makeConstraints {
      $0.top.equalTo(circleStack.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(divider2.height ?? 1)
    }
    verticalDivider.snp.makeConstraints {
      $0.width.equalTo(1)
      $0.top.equalTo(divider2.snp.bottom).offset(24)
      $0.bottom.equalTo(noticeBelow.snp.bottom)
      $0.centerX.equalToSuperview()
    }
    noticeBelow.snp.makeConstraints {
      $0.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
      $0.trailing.equalTo(verticalDivider.snp.leading).offset(-50)
      $0.centerY.equalTo(verticalDivider.snp.centerY)
    }
    askBelow.snp.makeConstraints {
      $0.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
      $0.leading.equalTo(verticalDivider.snp.trailing).offset(50)
      $0.centerY.equalTo(verticalDivider.snp.centerY)
    }
    contentView.snp.makeConstraints {
      $0.edges.equalTo(scrollView.contentLayoutGuide.snp.edges)
      $0.center.equalTo(scrollView.contentLayoutGuide.snp.center)
      $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
    }
    underButton.snp.makeConstraints {
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
      $0.height.equalTo(60)
    }

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    cardAddButton.rx
      .tapGesture()
      .when(.recognized)
      .map { _ in () }
      .bind(to: viewModel.input.tapCardAddButton)
      .disposed(by: rx.disposeBag)

    chargeEditButton.rx
      .tapGesture()
      .when(.recognized)
      .map { _ in () }
      .bind(to: viewModel.input.tapChargeEditButton)
      .disposed(by: rx.disposeBag)

    noticeBelow.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.present(UINavigationController(rootViewController: NoticeListViewController()).then {
          $0.modalPresentationStyle = .fullScreen
        }, animated: true)
      }).disposed(by: rx.disposeBag)

    askBelow.rx
      .tapGesture()
      .when(.recognized)
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(style: .actionSheet, actions: [
          UIAlertAction(title: "카카오톡 채널 문의하기", style: .default, handler: { _ in
            if let teleURL = URL(string: "https://pf.kakao.com/_hxnFFs/chat"),
               UIApplication.shared.canOpenURL(teleURL) {
              UIApplication.shared.open(teleURL, options: [:])
            }
          }),
          UIAlertAction(title: "상담원과 통화하기", style: .default, handler: { _ in
            if let teleURL = URL(string: "tel://16002834"),
               UIApplication.shared.canOpenURL(teleURL) {
              UIApplication.shared.open(teleURL, options: [:])
            }
          }),
          UIAlertAction(title: "취소", style: .cancel)
        ])
      }).disposed(by: rx.disposeBag)

    underButton.rx
      .tapGesture()
      .when(.recognized)
      .map { _ in () }
      .bind(to: viewModel.input.tapUnderButton)
      .disposed(by: rx.disposeBag)

    viewModel.output.didFetchUserUnsuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, isNotLoggedIn in
        owner.nameTextField.textField.text = ""
        owner.emailTextField.textField.text = ""
        owner.cardTextField.textField.text = ""
        owner.voltageCircle.backgroundTintColor = .systemGray4
        owner.ampereCircle.backgroundTintColor = .systemGray4
        owner.portCircle.backgroundTintColor = .systemGray4
        owner.voltageCircle.subscript = ""
        owner.ampereCircle.subscript = ""
        owner.portCircle.backgroundImage = .init(named: "port.head.none")

        if !isNotLoggedIn {
          owner.alert(title: "마이페이지 에러", message: "사용자 정보를 가져올 수 없습니다. 다시 시도해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
        }
      }).disposed(by: rx.disposeBag)

    viewModel.output.didFetchUserSuccessfully
      .withUnretained(self)
      .subscribe(onNext: { owner, myPageProperty in
        owner.nameTextField.textField.text = "\(myPageProperty.lastName) \(myPageProperty.firstName)"
        owner.emailTextField.textField.text = myPageProperty.email
        owner.cardTextField.textField.text = myPageProperty.cardInfo
        if let chargeVoltage = myPageProperty.voltage,
           let chargeAmpere = myPageProperty.ampere {
          owner.voltageCircle.backgroundTintColor = .systemYellow
          owner.ampereCircle.backgroundTintColor = .systemYellow
          owner.voltageCircle.subscript = "\(String(format: "%.2f", chargeVoltage)) V"
          owner.ampereCircle.subscript = "\(String(format: "%.1f", chargeAmpere)) A"
        } else {
          owner.voltageCircle.backgroundTintColor = .systemGray4
          owner.ampereCircle.backgroundTintColor = .systemGray4
          owner.voltageCircle.subscript = ""
          owner.ampereCircle.subscript = ""
        }
        owner.portCircle.backgroundTintColor = .systemGray4
        switch myPageProperty.type {
        case .none:
          owner.portCircle.backgroundImage = .init(named: "port.head.none")
        case .gx:
          owner.portCircle.backgroundImage = .init(named: "port.head.gx")
        case .dc8:
          owner.portCircle.backgroundImage = .init(named: "port.head.dc8")
        }
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTapCardAddButton
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.present(UINavigationController(rootViewController: CardModifyViewController().then {
          $0.viewModel.input.injectName.accept(owner.nameTextField.textField.text ?? "")
        }).then {
          $0.modalPresentationStyle = .fullScreen
        }, animated: true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTapChargeEditButton
      .withUnretained(self)
      .subscribe(onNext: { owner, property in
        owner.present(UINavigationController(rootViewController: ChargePortModifyViewController().then {
          $0.viewModel.portStream.accept((port: property.type,
                                          voltage: property.voltage ?? 0.0,
                                          ampere: property.ampere ?? 0.0))
        }).then {
          $0.modalPresentationStyle = .fullScreen
        }, animated: true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.didNoticeErrorNow
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "마이페이지 에러", message: "회원정보를 불러오지 못했습니다. 마이페이지에 다시 접속해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didNoticeRequireSignUp
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "회원가입이 필요합니다",
                    message: "회원가입 후 이용 가능한 서비스입니다. 가입을 진행하시겠습니까?",
                    style: .alert,
                    actions: [
                      UIAlertAction(title: "가입할래요", style: .default, handler: { [weak self] _ in
                        self?.present(UINavigationController(rootViewController: SignUpPhoneViewController()).then {
                          $0.modalPresentationStyle = .fullScreen
                        }, animated: true)
                      }),
                      UIAlertAction(title: "나중에 할래요", style: .cancel)
                    ])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didLogout
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "로그아웃", message: "로그아웃 하시겠습니까?", style: .alert, actions: [
          UIAlertAction(title: "취소", style: .cancel),
          UIAlertAction(title: "로그아웃", style: .destructive) { _ in
            WSLoadingIndicator.startLoad()
            let realm = try! Realm()
            let user = realm.objects(UserStore.self).first

            try! realm.write {
              user?.token = ""
              user?.identifier = ""
            }
            WSLoadingIndicator.stopLoad()
            owner.viewModel.input.appearSignal.accept(())
          }
        ])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didSignUp
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.present(UINavigationController(rootViewController: SignUpPhoneViewController()).then {
          $0.modalPresentationStyle = .fullScreen
        }, animated: true)
      }).disposed(by: rx.disposeBag)

    viewModel.output.underButtonText
      .bind(to: self.underButton.textLabel.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.input.appearSignal.accept(())
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    var mutatingSelf = self
    mutatingSelf.rx.disposeBag = DisposeBag()
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

}
