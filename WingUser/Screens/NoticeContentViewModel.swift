//
//  NoticeContentViewModel.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/02.
//

protocol NoticeContentInputable: ViewModelInputable {

  var appearSignal: PublishRelay<Void> { get }

}

protocol NoticeContentOutputable: ViewModelOutputable {

  var fetchNoticeContent: PublishRelay<WSStructure.NoticeContentProperty> { get }
  var didOccurErrorWithNoticeID: PublishRelay<Void> { get }
  var didOccurErrorWithNetworking: PublishRelay<Void> { get }
  var didOccurErrorWithDataFault: PublishRelay<Void> { get }

}

class NoticeContentInput: NoticeContentInputable {

  var appearSignal = PublishRelay<Void>()

}

class NoticeContentOutput: NoticeContentOutputable {

  var fetchNoticeContent = PublishRelay<WSStructure.NoticeContentProperty>()
  var didOccurErrorWithNoticeID = PublishRelay<Void>()
  var didOccurErrorWithNetworking = PublishRelay<Void>()
  var didOccurErrorWithDataFault = PublishRelay<Void>()

}

class NoticeContentViewModel: ViewModel<NoticeContentInput, NoticeContentOutput> {

  var noticeId: Int?

  override func bind() {
    self.input.appearSignal
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        guard let noticeId = owner.noticeId else {
          owner.output.didOccurErrorWithNoticeID.accept(())
          return
        }

        WSLoadingIndicator.startLoad()
        WSNetwork.request(target: .noticeGetDetail(id: noticeId)) { result in
          switch result {
          case .success(let json):
            if let result = json["result"].bool,
               result {
              let notice = json["notice"]
              let title = notice["title"].string ?? ""
              let date = notice["date"].string?.toISODate()?.date ?? Date(timeIntervalSince1970: 0)
              let content = notice["context"].string ?? ""
              let pictureURL = URL(string: notice["picture"].string ?? "")

              WSLoadingIndicator.stopLoad()
              owner.output.fetchNoticeContent.accept(.init(title: title, date: date, content: content, pictureURL: pictureURL))
            } else {
              WSLoadingIndicator.stopLoad()
              owner.output.didOccurErrorWithDataFault.accept(())
            }
          case .failure:
            owner.output.didOccurErrorWithNetworking.accept(())
          }
        }
      }).disposed(by: rx.disposeBag)
  }

}
