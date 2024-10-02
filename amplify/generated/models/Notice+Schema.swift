// swiftlint:disable all
import Amplify
import Foundation

extension Notice {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case noticeTitle
    case noticeText
    case Local
    case Member
    case ImageName
    case ImageUrl
    case priority
    case User
    case Date
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let notice = Notice.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Notices"
    model.syncPluralName = "Notices"
    
    model.attributes(
      .primaryKey(fields: [notice.id])
    )
    
    model.fields(
      .field(notice.id, is: .required, ofType: .string),
      .field(notice.noticeTitle, is: .required, ofType: .string),
      .field(notice.noticeText, is: .required, ofType: .string),
      .field(notice.Local, is: .required, ofType: .string),
      .field(notice.Member, is: .required, ofType: .string),
      .field(notice.ImageName, is: .required, ofType: .string),
      .field(notice.ImageUrl, is: .required, ofType: .string),
      .field(notice.priority, is: .optional, ofType: .enum(type: Priority.self)),
      .field(notice.User, is: .required, ofType: .string),
      .field(notice.Date, is: .required, ofType: .string),
      .field(notice.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(notice.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Notice: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}