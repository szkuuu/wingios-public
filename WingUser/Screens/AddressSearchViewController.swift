//
//  AddressSearchViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/15.
//

import UIKit

class AddressSearchViewController: UIViewController {

  weak var previousViewController: UIViewController?

  private lazy var closeButton: UIButton = UIButton(type: .close)

  private lazy var fakeNavigationTitle: UILabel = UILabel().then {
    $0.font = .boldSystemFont(ofSize: 16)
    $0.text = "주소검색"
  }

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.lineBreakMode = .byWordWrapping
    $0.attributedText = "<s24b>도로명이나 지번주소를\n입력해주세요</s24b>".wsAttributed
  }

  private lazy var searchBar: UISearchBar = UISearchBar().then {
    $0.delegate = self
    $0.searchBarStyle = .minimal
    $0.placeholder = "주소를 입력해주세요"
  }

  private let flowLayout = UICollectionViewFlowLayout().then {
    $0.scrollDirection = .vertical
    $0.minimumLineSpacing = 8.0
    $0.minimumInteritemSpacing = 0.0
  }

  private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
    $0.backgroundColor = .systemBackground
    $0.dataSource = self
    $0.delegate = self
    $0.register(AddressCell.self, forCellWithReuseIdentifier: AddressAttribute.reusableId)
  }

  private var cells: [WSCellProxy] = [WSCellProxy](repeating: .ADR(attribute: .init(logo: .init(named: "pin.gray"), road: "Sample Road", lotNumber: "Sample Road(LOT)")), count: 20)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    view.addSubview(closeButton)
    view.addSubview(fakeNavigationTitle)
    view.addSubview(titleLabel)
    view.addSubview(searchBar)
    view.addSubview(collectionView)

    closeButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }

    fakeNavigationTitle.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.centerY.equalTo(closeButton.snp.centerY)
    }

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(closeButton.snp.bottom).offset(35)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    searchBar.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
    }
    collectionView.snp.makeConstraints {
      $0.top.equalTo(searchBar.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
    }

    closeButton.rx
      .tapGesture()
      .when(.recognized)
      .subscribe { [weak self] _ in
        self?.dismiss(animated: true)
      }.disposed(by: rx.disposeBag)

    collectionView.rx
      .itemSelected
      .subscribe { [weak self] _ in
        if let previousViewController = self?.previousViewController as? HomeViewController {
          previousViewController.viewModel.input.changeCenterMode.accept(false)
          previousViewController.mapView.setCenter(.init(latitude: 35.88772228714518, longitude: 128.60306704814565), animated: true)
        }
        self?.dismiss(animated: true)
      }.disposed(by: rx.disposeBag)
  }

}

extension AddressSearchViewController: UISearchBarDelegate {}

extension AddressSearchViewController: UICollectionViewDelegate {}

extension AddressSearchViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    cells.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch cells[indexPath.row] {
    case .ADR(let attr):
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddressAttribute.reusableId, for: indexPath) as? AddressCell else {
        return UICollectionViewCell()
      }
      cell.configure(with: attr)

      return cell
    default:
      return UICollectionViewCell()
    }
  }

}

extension AddressSearchViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch cells[indexPath.row] {
    case .ADR(let attr):
      let dummyCell = AddressCell()
      dummyCell.configure(with: attr)

      return dummyCell.sizeThatFits(.init(width: collectionView.bounds.width, height: .greatestFiniteMagnitude))
    default:
      return .zero
    }
  }

}
