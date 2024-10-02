// swiftlint:disable all
import Amplify
import Foundation

public struct Attend: Model {
  public let id: String
  public var KakaoEmail: String
  public var AttendCheck: String
  public var priority: Priority?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      KakaoEmail: String,
      AttendCheck: String,
      priority: Priority? = nil) {
    self.init(id: id,
      KakaoEmail: KakaoEmail,
      AttendCheck: AttendCheck,
      priority: priority,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      KakaoEmail: String,
      AttendCheck: String,
      priority: Priority? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.KakaoEmail = KakaoEmail
      self.AttendCheck = AttendCheck
      self.priority = priority
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}