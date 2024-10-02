//
//  ChatListTableViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/09/22.
//

import UIKit
import Amplify
import Combine

import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
 
var chatRoomList = [[String:String]]()
 
class ChatListTableViewController: UITableViewController {
 
    @IBOutlet var chatRoomListView: UITableView!
 
    var addChatRoom = [String:String]()
    var addChatRoomUser = [String:String]()
    var addChatTable = [String:String]()
    
    let refreshControll = UIRefreshControl()
    var chatRoomSubscription:  AmplifyAsyncThrowingSequence<MutationEvent>?
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initRefresh()
        
        Task {
            await readChatRoom()
            await subscribeToChatRoom()
        }
    }
    
    //table view pull down recycling
    func initRefresh(){
        refreshControll.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        chatRoomListView.refreshControl = refreshControll
    }
 
    @objc func refreshTable(refresh: UIRefreshControl){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.chatRoomListView.reloadData()
            refresh.endRefreshing()
        }
    }
    
    //kakao auto통해 id value 얻어옴
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
    
    func subscribeToChatRoom() async {
        let chatRoomSubscription = Amplify.DataStore.observe(ChatChannel.self)
        self.chatRoomSubscription = chatRoomSubscription
        do {
            for try await changes in chatRoomSubscription {
                print("Subscription received mutation: \(changes)")
            }
        } catch {
            print("Subscription received error: \(error)")
        }
    }
    func unsubscribeFromPosts() {
        chatRoomSubscription?.cancel()
    }
    
    //다른 뷰에 갔다가 다시 돌아오는 상황에 해주고 싶은 처리 해결
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await subscribeToChatRoom()
            await readChatRoom()
            chatRoomListView.dataSource = self
        }
    }
    
    //read chat room
    private func readChatRoom() async {
        do{
            let userEmail = userGetAuth()
            let rooms = try await Amplify.DataStore.query(ChatChannel.self, where: ChatChannel.keys.Member1.eq(userEmail) || ChatChannel.keys.Member2.eq(userEmail))
            
            for room in rooms {
                // image, name
                if(userEmail == room.Member1){
                    let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(room.Member2))
                    for user in users{
                        addChatRoom = ["channel": room.id, "member1": userEmail!, "member2": room.Member2]
                        chatRoomList.append(addChatRoom)
                        addChatRoomUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl]
                        chatRoomList.append(addChatRoomUser)
                    }
                    
                } else if(userEmail == room.Member2){
                    let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(room.Member1))
                    for user in users{
                        addChatRoom = ["channel": room.id, "member1": userEmail!, "member2": room.Member1]
                        chatRoomList.append(addChatRoom)
                        addChatRoomUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl]
                        chatRoomList.append(addChatRoomUser)
                    }
                }
                
                let chatChannels = try await Amplify.DataStore.query(ChatMessage.self, where: ChatMessage.keys.channel.eq(room.id))
                if let lastMessage = chatChannels.sorted(by: { $0.timestamp > $1.timestamp }).first {
                    addChatTable = ["lastMessage": lastMessage.message, "messageDate": lastMessage.timestamp]
                    chatRoomList.append(addChatTable)
                }
            }
        } catch {
            print("Could not query DataStore: \(error)")
        }
    }
    
    //download image
    func downloadImage(fileName: String) async -> UIImage {
        let url: URL
        do {
            url = try await Amplify.Storage.getURL(key: fileName)
        } catch {
            print("Failed to get URL for image in homeview: \(error)")
            return UIImage(named: "Luvky_Icon.png")!
        }
        let downloadTask = Amplify.Storage.downloadFile(
            key: fileName,
            local: url,
            options: nil
        )
        Task {
            for await progress in await downloadTask.progress {
                print("Progress: \(progress)")
            }
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data) ?? UIImage(named: fileName)!
            return image
        } catch {
            print("Failed to get URL for image: \(error)")
            print(url)
            return UIImage(named: "Luvky_Icon.png")!
        }
    }
    
    //delete chat room
    private func deleteChatRoom(_ channel: String) async {
        do {
            let rooms = try await Amplify.DataStore.query(ChatChannel.self,
                                                          where: ChatChannel.keys.id.eq(channel))
            guard rooms.count == 1, let toDeleteRoom = rooms.first else {
                print("Did not find exactly one todo, bailing")
                return
            }
            try await Amplify.DataStore.delete(toDeleteRoom)
        } catch {
            print("Unable to perform operation: \(error)")
        }
    }
 
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomList.count
    }
 
    //cell로 보낼 정보 = member1,2(User), id(channel
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath) as! ChatListTableViewCell
        let dictTemp = chatRoomList[indexPath.row]
        
        let imageUrlString = dictTemp["userImgUrl"] ?? ""
        let imageUrl = URL(string: imageUrlString)
        
        cell.chatProfileName.text = dictTemp["userNickName"]
        cell.chatProfileText.text = dictTemp["lastMessage"] //이거는 message query이용해서 따와야 함
        cell.chatProfileTime.text = dictTemp["messageDate"] //위와 동일하다.
        
        Task {
            let userImage = await downloadImage(fileName: dictTemp["userImgName"] ?? "")
            cell.chatProfileImage.image = userImage
        }
 
        return cell
    }
 
    //신버전
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = ChattingViewController()
        viewController.detailData = chatRoomList[(self.tableView.indexPathForSelectedRow)!.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}
 
