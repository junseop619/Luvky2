// swiftlint:disable all
import Amplify
import Foundation

public struct Notice: Model {
  public let id: String
  public var noticeTitle: String
  public var noticeText: String
  public var Local: String
  public var Member: String
  public var ImageName: String
  public var ImageUrl: String
  public var priority: Priority?
  public var User: String
  public var Date: String
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      noticeTitle: String,
      noticeText: String,
      Local: String,
      Member: String,
      ImageName: String,
      ImageUrl: String,
      priority: Priority? = nil,
      User: String,
      Date: String) {
    self.init(id: id,
      noticeTitle: noticeTitle,
      noticeText: noticeText,
      Local: Local,
      Member: Member,
      ImageName: ImageName,
      ImageUrl: ImageUrl,
      priority: priority,
      User: User,
      Date: Date,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      noticeTitle: String,
      noticeText: String,
      Local: String,
      Member: String,
      ImageName: String,
      ImageUrl: String,
      priority: Priority? = nil,
      User: String,
      Date: String,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.noticeTitle = noticeTitle
      self.noticeText = noticeText
      self.Local = Local
      self.Member = Member
      self.ImageName = ImageName
      self.ImageUrl = ImageUrl
      self.priority = priority
      self.User = User
      self.Date = Date
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}