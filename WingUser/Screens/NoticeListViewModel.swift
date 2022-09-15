//
//  NoticeListViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/02.
//

protocol NoticeListInputable: ViewModelInputable {

  var initRequestNoticeList: PublishRelay<WSNoticeTypeIdentifier> { get }
  var retryRequestNoticeList: PublishRelay<WSNoticeTypeIdentifier> { get }
  var nextRequestNoticeList: PublishRelay<WSNoticeTypeIdentifier> { get }

}

protocol NoticeListOutputable: ViewModelOutputable {

  var proxyCells: PublishRelay<[WSCellProxy]> { get }
  var counterLabelText: BehaviorRelay<String> { get }
  var didOccurError: PublishRelay<Void> { get }
  var didTapNoticeCell: PublishRelay<Int> { get }

}

class NoticeListInput: NoticeListInputable {

  var initRequestNoticeList = PublishRelay<WSNoticeTypeIdentifier>()
  var retryRequestNoticeList = PublishRelay<WSNoticeTypeIdentifier>()
  var nextRequestNoticeList = PublishRelay<WSNoticeTypeIdentifier>()

}

class NoticeListOutput: NoticeListOutputable {

  var proxyCells = PublishRelay<[WSCellProxy]>()
  var counterLabelText = BehaviorRelay<String>(value: "총 0 건")
  var didOccurError = PublishRelay<Void>()
  var didTapNoticeCell = PublishRelay<Int>()

}

class NoticeListViewModel: ViewModel<NoticeListInput, NoticeListOutput> {

  private let pageStream = BehaviorRelay<Int>(value: 1)
  private let cellProxyStream = BehaviorRelay<[WSCellProxy]>(value: [])

  override func bind() {
    self.input.initRequestNoticeList
      .withUnretained(self)
      .subscribe(onNext: { owner, type in
        owner.pageStream.accept(1)
        WSLoadingIndicator.startLoad()

        WSNetwork.request(target: .noticeGetList(page: owner.pageStream.value, noticeType: type)) { result in
          switch result {
          case .success(let json):
            var cellProxys: [WSCellProxy] = []
            if let notices = json["list"].array {
              notices.map { (noticeJson: JSON) -> NoticeAttribute in
                let id = noticeJson["id"].int ?? -1
                let isPinned = (noticeJson["important"].int ?? 0) == 1
                let category = NoticeCell.Category(rawValue: (noticeJson["type"].int ?? 0))
                let title = noticeJson["title"].string
                let date = noticeJson["date"].string?.toISODate()?.date

                return NoticeAttribute(isPinned: isPinned, category: category, title: title, date: date) {
                  owner.output.didTapNoticeCell.accept(id)
                }
              }
              .sorted(by: { $0.date ?? Date(timeIntervalSince1970: 0) > $1.date ?? Date(timeIntervalSince1970: 0) })
              .sorted(by: { ($0.pinned ?? false).asInt > ($1.pinned ?? false).asInt })
              .map { WSCellProxy.NTC(attribute: $0) }
              .forEach { cellProxys.append($0) }

              owner.output.counterLabelText.accept("총 \(cellProxys.count) 건")
              cellProxys.append(.NMC(attribute: .init {
                owner.input.nextRequestNoticeList.accept(type)
              }))
            } else {
              owner.output.counterLabelText.accept("총 \(cellProxys.count) 건")
              cellProxys.append(.NMC(attribute: .init {
                owner.input.retryRequestNoticeList.accept(type)
              }))
            }

            WSLoadingIndicator.stopLoad()
            owner.cellProxyStream.accept(cellProxys)
          case .failure:
            WSLoadingIndicator.stopLoad()
            owner.output.counterLabelText.accept("총 0 건")
            owner.cellProxyStream.accept([.NMC(attribute: .init {
              owner.input.retryRequestNoticeList.accept(type)
            })])
            owner.output.didOccurError.accept(())
          }
        }
      }).disposed(by: rx.disposeBag)

    self.input.retryRequestNoticeList
      .withUnretained(self)
      .subscribe(onNext: { owner, type in
        owner.pageStream.accept(owner.pageStream.value)
        WSLoadingIndicator.startLoad()

        WSNetwork.request(target: .noticeGetList(page: owner.pageStream.value, noticeType: type)) { result in
          switch result {
          case .success(let json):
            var cellProxys: [WSCellProxy] = owner.cellProxyStream.value
            cellProxys.removeLast()
            if let notices = json["list"].array,
               !notices.isEmpty {
              notices.map { (noticeJson: JSON) -> NoticeAttribute in
                let id = noticeJson["id"].int ?? -1
                let isPinned = (noticeJson["important"].int ?? 0) == 1
                let category = NoticeCell.Category(rawValue: (noticeJson["type"].int ?? 0))
                let title = noticeJson["title"].string
                let date = noticeJson["date"].string?.toISODate()?.date

                return NoticeAttribute(isPinned: isPinned, category: category, title: title, date: date) {
                  owner.output.didTapNoticeCell.accept(id)
                }
              }
              .sorted(by: { $0.date ?? Date(timeIntervalSince1970: 0) > $1.date ?? Date(timeIntervalSince1970: 0) })
              .sorted(by: { ($0.pinned ?? false).asInt > ($1.pinned ?? false).asInt })
              .map { WSCellProxy.NTC(attribute: $0) }
              .forEach { cellProxys.append($0) }

              owner.output.counterLabelText.accept("총 \(cellProxys.count) 건")
              cellProxys.append(.NMC(attribute: .init {
                owner.input.nextRequestNoticeList.accept(type)
              }))
            } else {
              owner.output.counterLabelText.accept("총 \(cellProxys.count) 건")
              cellProxys.append(.NMC(attribute: .init {
                owner.input.retryRequestNoticeList.accept(type)
              }))
            }

            WSLoadingIndicator.stopLoad()
            owner.cellProxyStream.accept(cellProxys)
          case .failure:
            WSLoadingIndicator.stopLoad()
            owner.output.counterLabelText.accept("총 \(owner.cellProxyStream.value.count) 건")
            owner.cellProxyStream.accept([.NMC(attribute: .init {
              owner.input.retryRequestNoticeList.accept(type)
            })])
            owner.output.didOccurError.accept(())
          }
        }
      }).disposed(by: rx.disposeBag)

    self.input.nextRequestNoticeList
      .withUnretained(self)
      .subscribe(onNext: { owner, type in
        owner.pageStream.accept(owner.pageStream.value + 1)
        WSLoadingIndicator.startLoad()

        WSNetwork.request(target: .noticeGetList(page: owner.pageStream.value, noticeType: type)) { result in
          switch result {
          case .success(let json):
            var cellProxys: [WSCellProxy] = owner.cellProxyStream.value
            cellProxys.removeLast()
            if let notices = json["list"].array,
               !notices.isEmpty {
              notices.map { (noticeJson: JSON) -> NoticeAttribute in
                let id = noticeJson["id"].int ?? -1
                let isPinned = (noticeJson["important"].int ?? 0) == 1
                let category = NoticeCell.Category(rawValue: (noticeJson["type"].int ?? 0))
                let title = noticeJson["title"].string
                let date = noticeJson["date"].string?.toISODate()?.date

                return NoticeAttribute(isPinned: isPinned, category: category, title: title, date: date) {
                  owner.output.didTapNoticeCell.accept(id)
                }
              }
              .sorted(by: { $0.date ?? Date(timeIntervalSince1970: 0) > $1.date ?? Date(timeIntervalSince1970: 0) })
              .sorted(by: { ($0.pinned ?? false).asInt > ($1.pinned ?? false).asInt })
              .map { WSCellProxy.NTC(attribute: $0) }
              .forEach { cellProxys.append($0) }

              owner.output.counterLabelText.accept("총 \(cellProxys.count) 건")
              cellProxys.append(.NMC(attribute: .init {
                owner.input.nextRequestNoticeList.accept(type)
              }))
            } else {
              owner.output.counterLabelText.accept("총 \(cellProxys.count) 건")
              cellProxys.append(.NMC(attribute: .init {
                owner.input.retryRequestNoticeList.accept(type)
              }))
            }

            WSLoadingIndicator.stopLoad()
            owner.cellProxyStream.accept(cellProxys)
          case .failure:
            WSLoadingIndicator.stopLoad()
            owner.output.counterLabelText.accept("총 \(owner.cellProxyStream.value.count) 건")
            owner.cellProxyStream.accept([.NMC(attribute: .init {
              owner.input.retryRequestNoticeList.accept(type)
            })])
            owner.output.didOccurError.accept(())
          }
        }
      }).disposed(by: rx.disposeBag)

    self.cellProxyStream
      .bind(to: self.output.proxyCells)
      .disposed(by: rx.disposeBag)
  }

}
