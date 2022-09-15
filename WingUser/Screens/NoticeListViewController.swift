//
//  NoticeListViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/19.
//

import UIKit

class NoticeListViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s24b>공지사항</s24b>".wsAttributed
  }

  private lazy var divider: UIView = UIView().then {
    $0.backgroundColor = .label
  }

  private lazy var segmentedControl: UISegmentedControl = UISegmentedControl(items: ["전체", "공지", "이벤트", "제휴"]).then {
    $0.selectedSegmentIndex = 0
  }

  private lazy var countContainerView: UIView = UIView().then {
    $0.backgroundColor = .systemGray6
  }

  private lazy var countLabel: UILabel = UILabel().then {
    $0.text = "_"
    $0.font = .systemFont(ofSize: 14)
  }

  private let flowLayout = UICollectionViewFlowLayout().then {
    $0.scrollDirection = .vertical
    $0.minimumLineSpacing = 0.0
    $0.minimumInteritemSpacing = 0.0
  }

  private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
    $0.backgroundColor = .systemBackground
    $0.dataSource = self
    $0.delegate = self
    $0.register(NoticeCell.self, forCellWithReuseIdentifier: NoticeAttribute.reusableId)
    $0.register(NoticeMoreCell.self, forCellWithReuseIdentifier: NoticeMoreAttribute.reusableId)
  }

  private var cells: [WSCellProxy] = []

  let viewModel = NoticeListViewModel(input: NoticeListInput(), output: NoticeListOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    if presentingViewController != nil {
      navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil), animated: true)
      navigationItem.leftBarButtonItem?.rx
        .tap
        .withUnretained(self)
        .subscribe(onNext: { owner, _ in
          owner.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
    }

    countContainerView.addSubview(countLabel)

    view.addSubview(titleLabel)
    view.addSubview(divider)
    view.addSubview(segmentedControl)
    view.addSubview(countContainerView)
    view.addSubview(collectionView)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    divider.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
    }
    segmentedControl.snp.makeConstraints {
      $0.top.equalTo(divider.snp.bottom).offset(8)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
    }
    countLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(8)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    countContainerView.snp.makeConstraints {
      $0.top.equalTo(segmentedControl.snp.bottom).offset(8)
      $0.bottom.equalTo(countLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview()
    }
    collectionView.snp.makeConstraints {
      $0.top.equalTo(countContainerView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
    }

    viewModel.output.proxyCells
      .withUnretained(self)
      .subscribe(onNext: { owner, cells in
        owner.cells = cells
        owner.collectionView.reloadData()
      }).disposed(by: rx.disposeBag)

    viewModel.output.counterLabelText
      .bind(to: self.countLabel.rx.text)
      .disposed(by: rx.disposeBag)

    viewModel.output.didOccurError
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "공지사항 에러", message: "공지사항 내용을 불러오지 못했습니다. 다시 시도해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didTapNoticeCell
      .withUnretained(self)
      .subscribe(onNext: { owner, id in
        owner.navigationController?.pushViewController(NoticeContentViewController().then {
          $0.viewModel.noticeId = id
        }, animated: true)
      }).disposed(by: rx.disposeBag)

    self.segmentedControl.rx
      .selectedSegmentIndex
      .map { WSNoticeTypeIdentifier(rawValue: $0) ?? .all }
      .bind(to: viewModel.input.initRequestNoticeList)
      .disposed(by: rx.disposeBag)
  }

}

// MARK: - UICollectionView Extension

extension NoticeListViewController: UICollectionViewDelegate {}

extension NoticeListViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    cells.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch cells[indexPath.row] {
    case .NTC(let attr):
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeAttribute.reusableId, for: indexPath) as? NoticeCell else {
        return UICollectionViewCell()
      }
      cell.configure(with: attr)

      return cell
    case .NMC(let attr):
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeMoreAttribute.reusableId, for: indexPath) as? NoticeMoreCell else {
        return UICollectionViewCell()
      }
      cell.configure(with: attr)

      return cell
    default:
      return UICollectionViewCell()
    }
  }

}

extension NoticeListViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let fitCountCell = floor(collectionView.bounds.height / 60)
    let fitHeight = collectionView.bounds.height / fitCountCell

    return .init(width: collectionView.bounds.width, height: fitHeight)
  }

}
