// swiftlint:disable all
import Amplify
import Foundation

extension ChatMessage {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case channel
    case sender
    case message
    case timestamp
    case priority
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let chatMessage = ChatMessage.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "ChatMessages"
    model.syncPluralName = "ChatMessages"
    
    model.attributes(
      .primaryKey(fields: [chatMessage.id])
    )
    
    model.fields(
      .field(chatMessage.id, is: .required, ofType: .string),
      .field(chatMessage.channel, is: .required, ofType: .string),
      .field(chatMessage.sender, is: .required, ofType: .string),
      .field(chatMessage.message, is: .required, ofType: .string),
      .field(chatMessage.timestamp, is: .required, ofType: .string),
      .field(chatMessage.priority, is: .optional, ofType: .enum(type: Priority.self)),
      .field(chatMessage.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(chatMessage.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension ChatMessage: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}