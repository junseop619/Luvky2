import Amplify
import Combine
import UIKit
import MessageKit
import InputBarAccessoryView
import Photos
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser


class ChattingViewController: MessagesViewController {
    var otherPerson: String?
    
    var currentUser = Sender(senderId: "self", displayName: "current user")
        
    var otherUser = Sender(senderId: "other", displayName: "other user")
        
    var messages = [MessageType]()
    
    var unique_channel : String!

    var detailData = [String:String]()
    
    var subscription: AmplifyAsyncThrowingSequence<GraphQLSubscriptionEvent<ChatMessage>>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmDelegates()
        configure()
        setupMessageInputBar()
        removeOutgoingMessageAvatars()
        
        Task{
            await createSubscription()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Task{
            await createSubscription()
        }
    }
    
    deinit {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func userGetAuth() -> String? {
        var email: String?
        UserApi.shared.me { [self] user, error in
            if let error = error {
                print(error)
            } else {
                email = user?.kakaoAccount?.email
            }
        }
        return email
    }
    
    //channel에 대한 실질적 관리로 title값 = 상단 navigation bar title
    private func configure() {
        title = "가은이"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupMessageInputBar() {
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
        messageInputBar.inputTextView.placeholder = "Aa"
    }
    
    private func removeOutgoingMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.setMessageOutgoingAvatarSize(.zero)
        let outgoingLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }
    
    private func confirmDelegates() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    
    // NO.2 - 넘겨받은 parameter로 AWS Amplify sever에 create method
    private func saveMessage(_ channel: String, _ sender: String, _ message: String, _ priority: Priority) async {
        do {
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd HH:mm"
            let dateString = dateFormatter.string(from: currentDate)
            let item = ChatMessage(id: UUID().uuidString, channel: channel, sender: sender, message: message, timestamp: dateString, priority: priority)
            _ = try await Amplify.DataStore.save(item)
        } catch {
            print("Could not save item to dataStore: \(error)")
        }
    }
    
    
    //NO.3 - channel을 기준으로 query문 수행, 정확히는 AWS로 부터 graphql data를 불러옴
    //필요 보안사항 1. send data 2. currentUser, otherUser 어떻게 처리할 것인가?
    private func readMessage(_ noticeNumber: String) async {
        do {
            let email = userGetAuth()
            currentUser.senderId = email!
            let myinfos = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(email))
            for myinfo in myinfos {
                currentUser.displayName = myinfo.UserNickName
            }
            
            if(detailData["member2"] != nil){
                otherUser.senderId = detailData["member2"]!
                let yourinfos = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(detailData["member2"]))
                for yourinfo in yourinfos {
                    otherUser.displayName = yourinfo.UserNickName
                }
            }
            
            if(otherPerson != nil){
                //comment로 들어옴
                otherUser.senderId = otherPerson!
                let yourinfos = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(otherPerson))
                for yourinfo in yourinfos {
                    otherUser.displayName = yourinfo.UserNickName
                }
            }
            
            let awsMessages = try await Amplify.DataStore.query(ChatMessage.self, where: ChatMessage.keys.channel.eq(unique_channel))
            
            for awsMessage in awsMessages {
                if(awsMessage.sender == email){
                    //내꺼
                    messages.append(Message(sender: currentUser,
                                            messageId: awsMessage.id,
                                            sentDate: Date().addingTimeInterval(-86400),
                                            kind: .text(awsMessage.message),
                                            channel: awsMessage.channel))
                } else {
                    //니꺼
                    messages.append(Message(sender: otherUser,
                                            messageId: awsMessage.id,
                                            sentDate: Date().addingTimeInterval(-86400),
                                            kind: .text(awsMessage.message),
                                            channel: awsMessage.channel))
                }
            }
        } catch {
            print("Could not query DataStore: \(error)")
        }
    }
    
    func createSubscription() async{
        if let subscription = subscription {
            Task {
                do {
                    for try await subscriptionEvent in subscription {
                        switch subscriptionEvent {
                        case .connection(let subscriptionConnectionState):
                            print("Subscription connect state is \(subscriptionConnectionState)")
                        case .data(let result):
                            switch result {
                            case .success(let createdTodo):
                                print("Successfully got todo from subscription: \(createdTodo)")
                            case .failure(let error):
                                print("Got failed result with \(error.errorDescription)")
                            }
                        }
                    }
                } catch {
                    print("Subscription has terminated with \(error)")
                }
            }
        } else {
            print("Subscription is nil")
        }
    }
    
    //real-time unsubscribtion
    func cancelSubscription() {
        // Cancel the subscription listener when you're finished with it
        subscription?.cancel()
    }
    
    //new code
    private func addChatRoom(_ member1: String, _ member2: String, _ dateString: String,_ priority: Priority) async {
        
        do{
            let userEmail = userGetAuth()
            let item = ChatChannel(id: UUID().uuidString, Member1: userEmail!,  Member2: member2, Date: dateString, priority: priority)
            
            _ = try await Amplify.DataStore.save(item)
            print(dateString)
        } catch {
            print("Could not save item to dataStore: \(error)")
        }
    }
}



//please custom this code - delegate 구현 part로 messageDataSource(message data 정의)
extension ChattingViewController: MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        //return "pass" as! SenderType
        return Sender(senderId: "self", displayName: "current sender") //sender model과 연결
    }
    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count // message struct의 수를 나타내는 것이니깐 이거를 message dict으로 전환하게 된다면?
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section] //위와 동일
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                                                             .foregroundColor: UIColor(white: 0.3, alpha: 1)])
    }
}

extension ChattingViewController: MessagesLayoutDelegate {
    // 아래 여백
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    // 말풍선 위 이름 나오는 곳의 height
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}

// 상대방이 보낸 메시지, 내가 보낸 메시지를 구분하여 색상과 모양 지정 (일단 untouchable)
extension ChattingViewController: MessagesDisplayDelegate {
    // 말풍선의 배경 색상
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primary : .incomingMessageBackground
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .black : .white
    }
    
    // 말풍선의 꼬리 모양 방향
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let cornerDirection: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(cornerDirection, .curved)
    }
}

// NO.1 - input_bar에 입력된 text parameter로 chat message graphQL을 구성함 = new message(variable) , 이후 new message를 parameter로 add_message func를 call함
extension ChattingViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Create a new ChatMessage
        
        let email = userGetAuth()
    
        Task{
            if(otherPerson != nil){
                //comment로 들어옴
                let member_channels = try await Amplify.DataStore.query(ChatChannel.self, where: ChatChannel.keys.Member1.eq(email) && ChatChannel.keys.Member2.eq(otherPerson))
                for member_channel in member_channels {
                    unique_channel = member_channel.id
                }
                if(unique_channel != nil){
                    //채팅방 존재의 경우 -> 현재 channel값 이용
                    await saveMessage(unique_channel,email!,text, .normal)
                } else {
                    await addChatRoom(email!, otherPerson!, "dateString", .normal)
                    let member_channel2s = try await Amplify.DataStore.query(ChatChannel.self, where: ChatChannel.keys.Member1.eq(email) && ChatChannel.keys.Member2.eq(otherPerson))
                    
                    for member_channel2 in member_channel2s {
                        unique_channel = member_channel2.id
                    }
                    await saveMessage(unique_channel,email!,text, .normal)
                }
            } else {
                //list view로 들어옴
                unique_channel = detailData["channel"]
                await saveMessage(unique_channel,email!,text, .normal)
            }
        }
        
        inputBar.inputTextView.text.removeAll()
    }
}

