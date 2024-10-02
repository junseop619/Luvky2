import Foundation
import MessageKit
import UIKit


struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var channel: String
}

extension Message: Comparable {
  static func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.messageId == rhs.messageId
  }

  static func < (lhs: Message, rhs: Message) -> Bool {
    return lhs.sentDate < rhs.sentDate
  }
}
