// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "ccd70fd202fc2b5a34f8ddaec4a86f72"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Notice.self)
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: ChatChannel.self)
    ModelRegistry.register(modelType: ChatMessage.self)
  }
}