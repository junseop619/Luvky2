// swiftlint:disable all
import Amplify
import Foundation

public struct ChatChannel: Model {
  public let id: String
  public var Member1: String
  public var Member2: String
  public var Date: String
  public var priority: Priority?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      Member1: String,
      Member2: String,
      Date: String,
      priority: Priority? = nil) {
    self.init(id: id,
      Member1: Member1,
      Member2: Member2,
      Date: Date,
      priority: priority,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      Member1: String,
      Member2: String,
      Date: String,
      priority: Priority? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.Member1 = Member1
      self.Member2 = Member2
      self.Date = Date
      self.priority = priority
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}