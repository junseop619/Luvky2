// swiftlint:disable all
import Amplify
import Foundation

public struct ChatMessage: Model {
  public let id: String
  public var channel: String
  public var sender: String
  public var message: String
  public var timestamp: String
  public var priority: Priority?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      channel: String,
      sender: String,
      message: String,
      timestamp: String,
      priority: Priority? = nil) {
    self.init(id: id,
      channel: channel,
      sender: sender,
      message: message,
      timestamp: timestamp,
      priority: priority,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      channel: String,
      sender: String,
      message: String,
      timestamp: String,
      priority: Priority? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.channel = channel
      self.sender = sender
      self.message = message
      self.timestamp = timestamp
      self.priority = priority
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}