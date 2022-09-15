//
//  WSSocketCenter.swift
//  WingUser
//
//  Created by 차상호 on 2021/12/06.
//

import SocketIO

class WSSocketCenter: NSObject {

  static let sharedV2: WSSocketCenter = WSSocketCenter(serverVersion: .two)

  static let sharedV3: WSSocketCenter = WSSocketCenter(serverVersion: .three)

  private let manager: SocketManager

  private let socket: SocketIOClient

  private var listenBag: [UUID] = []

  private init(serverVersion version: SocketIOVersion, namespace: String = "") {
    if let url = URL(string: WSSecret.socketConnectionUrlString) {
      self.manager = SocketManager(socketURL: url, config: [.reconnects(false), .version(version)])
    } else {
      self.manager = .init(socketURL: URL(fileURLWithPath: "/"))
    }
    if namespace.isEmpty {
      self.socket = self.manager.defaultSocket
    } else {
      self.socket = self.manager.socket(forNamespace: namespace)
    }
  }

  func openClient() {
    self.socket.connect()
  }

  func closeClient() {
    self.socket.disconnect()
  }

  func emit(for eventName: WSEvent, with socketData: SocketData) {
    self.socket.emit(eventName.rawValue, with: [socketData], completion: nil)
  }

  func on(clientEvent event: SocketClientEvent, _ callbackBlock: @escaping ([Any], SocketAckEmitter) -> Void) {
    self.listenBag.append(self.socket.on(clientEvent: event, callback: callbackBlock))
  }

  func on(_ eventName: WSListen, _ callbackBlock: @escaping ([Any], SocketAckEmitter) -> Void) {
    self.listenBag.append(self.socket.on(eventName.rawValue, callback: callbackBlock))
  }

  func offAll() {
    self.listenBag.forEach { [weak self] in self?.socket.off(id: $0) }
  }

}
