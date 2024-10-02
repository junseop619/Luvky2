// swiftlint:disable all
import Amplify
import Foundation

extension ChatChannel {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case Member1
    case Member2
    case Date
    case priority
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let chatChannel = ChatChannel.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "ChatChannels"
    model.syncPluralName = "ChatChannels"
    
    model.attributes(
      .primaryKey(fields: [chatChannel.id])
    )
    
    model.fields(
      .field(chatChannel.id, is: .required, ofType: .string),
      .field(chatChannel.Member1, is: .required, ofType: .string),
      .field(chatChannel.Member2, is: .required, ofType: .string),
      .field(chatChannel.Date, is: .required, ofType: .string),
      .field(chatChannel.priority, is: .optional, ofType: .enum(type: Priority.self)),
      .field(chatChannel.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(chatChannel.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension ChatChannel: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}