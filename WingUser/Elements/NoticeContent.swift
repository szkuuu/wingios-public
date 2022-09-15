//
//  NoticeContent.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/19.
//

import Kingfisher
import UIKit

class NoticeContent: UIView {

  private var contentTextLabel: UILabel!

  private var contentImageView: UIImageView!

  private var scrollView: UIScrollView!

  private let contentView: UIView = UIView().then {
    $0.backgroundColor = .systemBackground
  }

  var contentText: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var contentImageURL: URL? = nil {
    didSet {
      guard let imageURL = contentImageURL else {
        self.contentImage = nil
        return
      }

      KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: imageURL), options: nil, progressBlock: nil) { result in
        switch result {
        case .success(let value):
          self.contentImage = value.image
        case .failure:
          self.contentImage = nil
        }
      }
    }
  }

  private var contentImage: UIImage? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  init(
    content: String? = nil
  ) {
    super.init(frame: .zero)

    commonInit()

    self.contentText = content
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    scrollView = UIScrollView().then {
      $0.backgroundColor = .systemBackground
    }
    contentTextLabel = UILabel().then {
      $0.numberOfLines = 0
      $0.lineBreakMode = .byWordWrapping
      $0.font = .systemFont(ofSize: 14)
    }
    contentImageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit
      $0.layer.cornerRadius = 16.0
      $0.layer.masksToBounds = true
    }

    contentView.addSubview(contentTextLabel)
    contentView.addSubview(contentImageView)

    scrollView.addSubview(contentView)

    addSubview(scrollView)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateContentImageView()
    updateContentTextLabel()
    updatePin()
  }

  private func updateContentImageView() {
    contentImageView.image = contentImage
  }

  private func updateContentTextLabel() {
    contentTextLabel.text = contentText
  }

  private func updatePin() {
    scrollView.pin.all()
    contentView.pin.top().horizontally()

    contentImageView.pin
      .top()
      .horizontally()
      .aspectRatio()
      .sizeToFit(.width)
    contentTextLabel.pin
      .below(of: contentImageView, aligned: .start)
      .horizontally()
      .marginTop(self.contentImageView.image != nil ? 16 : 0)
      .sizeToFit(.width)

    contentView.pin.wrapContent(.vertically)
    // auto-layout
    contentView.snp.remakeConstraints {
      $0.edges.equalTo(scrollView.contentLayoutGuide.snp.edges)
      $0.center.equalTo(scrollView.contentLayoutGuide.snp.center)
      $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
      $0.height.equalTo(contentView.bounds.height)
    }
  }

}
