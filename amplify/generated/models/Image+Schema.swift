// swiftlint:disable all
import Amplify
import Foundation

extension Image {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case url
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let image = Image.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "Images"
    
    model.attributes(
      .primaryKey(fields: [image.id])
    )
    
    model.fields(
      .field(image.id, is: .required, ofType: .string),
      .field(image.url, is: .required, ofType: .string),
      .field(image.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(image.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Image: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}