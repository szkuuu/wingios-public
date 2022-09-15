//
//  StationPortListViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/19.
//

import UIKit

class StationPortListViewController: UIViewController {

  private lazy var closeButton: UIButton = UIButton(type: .close)

  private lazy var fakeNavigationTitle: UILabel = UILabel().then {
    $0.font = .boldSystemFont(ofSize: 16)
    $0.text = "스테이션 정보"
  }

  private lazy var stationNameLabel: UILabel = UILabel().then {
    $0.font = .boldSystemFont(ofSize: 16)
  }

  private lazy var iconImageView: UIImageView = UIImageView(image: .init(named: "pin.gray")).then {
    $0.contentMode = .scaleAspectFit
    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }

  private lazy var lotNumberAddressLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .secondaryLabel
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
  }

  private lazy var stationImageView: UIImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.backgroundColor = .secondarySystemFill
    $0.layer.cornerRadius = 16.0
    $0.layer.masksToBounds = true
  }

  private lazy var availablePortCountLabel: UILabel = UILabel().then {
    $0.attributedText = "<s14b>사용가능포트  <orange>0</orange></s14b>".wsAttributed
  }

  private lazy var containerView: UIView = UIView().then {
    $0.backgroundColor = .systemYellow
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 32.0
    $0.layer.maskedCorners = [.layerMinXMinYCorner]
  }

  private let flowLayout = UICollectionViewFlowLayout().then {
    $0.scrollDirection = .vertical
    $0.minimumLineSpacing = 8.0
    $0.minimumInteritemSpacing = 0.0
  }

  private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
    $0.backgroundColor = .clear
    $0.dataSource = self
    $0.delegate = self
    $0.register(PortStateCell.self, forCellWithReuseIdentifier: PortStateAttribute.reusableId)
  }

  private var cells: [WSCellProxy] = []

  let viewModel: StationPortListViewModel = .init(input: StationPortListInput(), output: StationPortListOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    containerView.addSubview(collectionView)

    view.addSubview(closeButton)
    view.addSubview(fakeNavigationTitle)
    view.addSubview(stationNameLabel)
    view.addSubview(iconImageView)
    view.addSubview(lotNumberAddressLabel)
    view.addSubview(stationImageView)
    view.addSubview(availablePortCountLabel)
    view.addSubview(containerView)

    closeButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }

    fakeNavigationTitle.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.centerY.equalTo(closeButton.snp.centerY)
    }
    stationNameLabel.snp.makeConstraints {
      $0.top.equalTo(closeButton.snp.bottom).offset(16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    iconImageView.snp.makeConstraints {
      $0.top.equalTo(stationNameLabel.snp.bottom).offset(8)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    lotNumberAddressLabel.snp.makeConstraints {
      $0.top.equalTo(iconImageView.snp.top)
      $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
    }
    stationImageView.snp.makeConstraints {
      $0.top.equalTo(lotNumberAddressLabel.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(availablePortCountLabel.snp.top).offset(-24)
    }
    availablePortCountLabel.snp.makeConstraints {
      $0.bottom.equalTo(containerView.snp.top).offset(-8)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    containerView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalToSuperview().multipliedBy(0.4581)
    }
    collectionView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }

    closeButton.rx
      .tapGesture()
      .when(.recognized)
      .subscribe { [weak self] _ in
        self?.dismiss(animated: true)
      }.disposed(by: rx.disposeBag)

    viewModel.output.stationName
      .bind(to: self.stationNameLabel.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.stationAddress
      .bind(to: self.lotNumberAddressLabel.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.portStates
      .asDriver(onErrorJustReturn: [])
      .map { $0.filter { $0.state == 0 }.count }
      .drive(onNext: { [weak self] in
        self?.availablePortCountLabel.attributedText = "<s14b>사용가능포트  <orange>\($0)</orange></s14b>".wsAttributed
      }).disposed(by: rx.disposeBag)

    viewModel.output.portStates
      .asDriver(onErrorJustReturn: [])
      .map { $0.map { property -> WSCellProxy in
        let port: PortStateCell.Port
        switch property.type {
        case .gx:
          port = .gx
        case .dc8:
          port = .dc8
        case .none:
          port = .none
        }
        let state: PortStateCell.State = property.state == 0 ? .available : .unavailable

        return WSCellProxy.PSC(attribute: .init(port: port, portName: "포트\(property.portNumber)", portState: state))
      }}
      .drive(onNext: { [weak self] in
        self?.cells = $0
        self?.collectionView.reloadData()
      }).disposed(by: rx.disposeBag)
  }

}

// MARK: - UICollectionView Extension

extension StationPortListViewController: UICollectionViewDelegate {}

extension StationPortListViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    cells.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch cells[indexPath.row] {
    case .PSC(let attr):
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PortStateAttribute.reusableId, for: indexPath) as? PortStateCell else {
        return UICollectionViewCell()
      }
      cell.configure(with: attr)

      return cell
    default:
      return UICollectionViewCell()
    }
  }

}

extension StationPortListViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch cells[indexPath.row] {
    case .PSC:
      let itemsPerRow: CGFloat = 3
      let horizontalPadding: CGFloat = 4
      let cellSize = (collectionView.bounds.width - (horizontalPadding * (itemsPerRow + 1))) / itemsPerRow

      return .init(width: cellSize, height: cellSize)
    default:
      return .zero
    }
  }
}
