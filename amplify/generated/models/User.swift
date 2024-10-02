// swiftlint:disable all
import Amplify
import Foundation

public struct User: Model {
  public let id: String
  public var UserNickName: String
  public var UserSex: String
  public var UserAge: String
  public var UserImageName: String
  public var UserImageUrl: String
  public var UserText: String
  public var Attend: String
  public var Point: Int
  public var priority: Priority?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      UserNickName: String,
      UserSex: String,
      UserAge: String,
      UserImageName: String,
      UserImageUrl: String,
      UserText: String,
      Attend: String,
      Point: Int,
      priority: Priority? = nil) {
    self.init(id: id,
      UserNickName: UserNickName,
      UserSex: UserSex,
      UserAge: UserAge,
      UserImageName: UserImageName,
      UserImageUrl: UserImageUrl,
      UserText: UserText,
      Attend: Attend,
      Point: Point,
      priority: priority,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      UserNickName: String,
      UserSex: String,
      UserAge: String,
      UserImageName: String,
      UserImageUrl: String,
      UserText: String,
      Attend: String,
      Point: Int,
      priority: Priority? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.UserNickName = UserNickName
      self.UserSex = UserSex
      self.UserAge = UserAge
      self.UserImageName = UserImageName
      self.UserImageUrl = UserImageUrl
      self.UserText = UserText
      self.Attend = Attend
      self.Point = Point
      self.priority = priority
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}