//
//  WSCellProxy.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/08.
//

enum WSCellProxy {

  /// PolicyRowCell Proxy
  case PRC(attribute: PolicyRowAttribute)

  /// DividerCell Proxy
  case DIV(attribute: DividerAttribute)

  /// PortCell Proxy
  case PRT(attribute: PortAttribute)

  /// AddressCell Proxy
  case ADR(attribute: AddressAttribute)

  /// NoticeCell Proxy
  case NTC(attribute: NoticeAttribute)

  /// NoticeMoreCell Proxy
  case NMC(attribute: NoticeMoreAttribute)

  /// PortStateCell Proxy
  case PSC(attribute: PortStateAttribute)

}
