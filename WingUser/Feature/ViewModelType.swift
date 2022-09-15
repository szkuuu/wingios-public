//
//  ViewModelType.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/24.
//

public protocol ViewModelInputable: AnyObject {}

public protocol ViewModelOutputable: AnyObject {}

public protocol ViewModelable: AnyObject {

  associatedtype ViewModelInputType

  associatedtype ViewModelOutputType

  /// 뷰에서 뷰모델로 향하는 입력 스트림
  var input: ViewModelInputType { get }

  /// 뷰모델에서 뷰로 향하는 출력 스트림
  var output: ViewModelOutputType { get }

  init(input: ViewModelInputType, output: ViewModelOutputType)

  /// 입력 스트림과 출력 스트림을 등록
  func bind()

}

open class ViewModel<IType, OType>: NSObject, ViewModelable {

  public let input: IType

  public let output: OType

  public required init(input: IType, output: OType) {
    self.input = input
    self.output = output

    super.init()

    self.bind()
  }

  public func bind() {}

}
