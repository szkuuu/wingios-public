//
//  NoticeContentViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/19.
//

import SwiftDate
import UIKit

class NoticeContentViewController: UIViewController {

  private lazy var titleLabel: UILabel = UILabel().then {
    $0.attributedText = "<s18b>Tilte</s18b>".wsAttributed
  }

  private lazy var dateLabel: UILabel = UILabel().then {
    $0.text = Date().toFormat("yy.MM.dd", locale: Locales.koreanSouthKorea)
    $0.font = .systemFont(ofSize: 12)
    $0.textColor = .secondaryLabel
  }

  private lazy var divider: UIView = UIView().then {
    $0.backgroundColor = .systemGray6
  }

  private lazy var noticeContent: NoticeContent = NoticeContent(content: "")

  let viewModel = NoticeContentViewModel(input: NoticeContentInput(), output: NoticeContentOutput())

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    navigationItem.title = "공지사항"

    view.addSubview(titleLabel)
    view.addSubview(dateLabel)
    view.addSubview(divider)
    view.addSubview(noticeContent)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    dateLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
    }
    divider.snp.makeConstraints {
      $0.top.equalTo(dateLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
    }
    noticeContent.snp.makeConstraints {
      $0.top.equalTo(divider.snp.bottom).offset(24)
      $0.leading.equalTo(view.layoutMarginsGuide.snp.leadingMargin)
      $0.trailing.equalTo(view.layoutMarginsGuide.snp.trailingMargin)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }

    viewModel.output.fetchNoticeContent
      .withUnretained(self)
      .subscribe(onNext: { owner, notice in
        owner.titleLabel.text = notice.title
        owner.dateLabel.text = notice.date.toFormat("yy.MM.dd", locale: Locales.koreanSouthKorea)
        owner.noticeContent.contentImageURL = notice.pictureURL
        owner.noticeContent.contentText = notice.content
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithDataFault
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "공지사항 에러", message: "존재하지 않는 데이터입니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.navigationController?.popViewController(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithNetworking
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "공지사항 에러", message: "네트워크 연결을 확인해주세요.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.navigationController?.popViewController(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.output.didOccurErrorWithNoticeID
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.alert(title: "공지사항 에러", message: "잘못된 접근입니다.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          owner.navigationController?.popViewController(animated: true)
        }])
      }).disposed(by: rx.disposeBag)

    viewModel.input.appearSignal.accept(())
  }

}
