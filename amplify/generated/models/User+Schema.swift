// swiftlint:disable all
import Amplify
import Foundation

extension User {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case UserNickName
    case UserSex
    case UserAge
    case UserImageName
    case UserImageUrl
    case UserText
    case Attend
    case Point
    case priority
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let user = User.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Users"
    model.syncPluralName = "Users"
    
    model.attributes(
      .primaryKey(fields: [user.id])
    )
    
    model.fields(
      .field(user.id, is: .required, ofType: .string),
      .field(user.UserNickName, is: .required, ofType: .string),
      .field(user.UserSex, is: .required, ofType: .string),
      .field(user.UserAge, is: .required, ofType: .string),
      .field(user.UserImageName, is: .required, ofType: .string),
      .field(user.UserImageUrl, is: .required, ofType: .string),
      .field(user.UserText, is: .required, ofType: .string),
      .field(user.Attend, is: .required, ofType: .string),
      .field(user.Point, is: .required, ofType: .int),
      .field(user.priority, is: .optional, ofType: .enum(type: Priority.self)),
      .field(user.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(user.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension User: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}