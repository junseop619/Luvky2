// swiftlint:disable all
import Amplify
import Foundation

public struct Image: Model {
  public let id: String
  public var url: String
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      url: String) {
    self.init(id: id,
      url: url,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      url: String,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.url = url
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}