//
//  DetailArticleViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/12.
//

import UIKit
import Amplify

import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class DetailArticleViewController: UIViewController {

    var detailData = [String:String]()
    //var detailUserData = [String:String]()
    
    @IBOutlet var articleUserImg: UIImageView!
    
    @IBOutlet var articleUserName: UILabel!
    
    @IBOutlet var articleUserSex: UILabel!
    
    @IBOutlet var articleUserAge: UILabel!
    
    
    @IBOutlet var articleUserLocal: UILabel!
    
    @IBOutlet var articleUserMember: UILabel!
    
    @IBOutlet var articleTitleImg: UIImageView!
    
    @IBOutlet var articleTitle: UILabel!
    
    @IBOutlet var articleText: UILabel!
    
    
    
    
    
    
    @IBOutlet var moreBtn: UIButton!
    
   
    
    
    @IBOutlet var detailDate: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleUserName.text = detailData["userNickName"]
        articleUserSex.text = detailData["sex"]
        articleUserAge.text = detailData["age"]
        articleUserLocal.text = detailData["local"]
        articleUserMember.text = detailData["member"]
        articleTitle.text = detailData["title"]
        detailDate.text = detailData["Date"]
        articleText.text = detailData["text"]
        
        
        

        
        Task {
            //article image
            let fileName = detailData["titleImgName"]
            let image = await testImage2(fileName: fileName!)
            articleTitleImg.image = image
            
            //user image
            let filename2 = detailData["userImgName"]
            let userImage = await testImage2(fileName: filename2 ?? "")
            articleUserImg.image = userImage
        }
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
    
    //Delete
    private func deleteNotice(_ noticeId: String) async {
        do {
            let notices = try await Amplify.DataStore.query(Notice.self,
                                                          where: Notice.keys.id.eq(noticeId))
            guard notices.count == 1, let toDeleteNotice = notices.first else {
                print("Did not find exactly one todo, bailing")
                return
            }
            try await Amplify.DataStore.delete(toDeleteNotice)
        } catch {
            print("Unable to perform operation: \(error)")
        }
    }
    
    //download image
    func testImage2(fileName: String) async -> UIImage {
        let url: URL
        do {
            url = try await Amplify.Storage.getURL(key: fileName)
        } catch {
            print("Failed to get URL for image: \(error)")
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
            print(url)
            return UIImage(named: "Luvky_Icon.png")!
        }
    }
    
    
    @IBAction func watchProfile(_ sender: Any) {
        guard let result = self.storyboard?.instantiateViewController(identifier: "profileInfo") as? ProfileViewController else {
            return
        }
        result.receiveUser = detailData["User"]
        self.navigationController?.pushViewController(result, animated: true)
    }
    

    
    //이거 변경해야됨
    @IBAction func commentBtn(_ sender: Any) {
        let viewController = ChattingViewController()
        let send = UIAlertController(title: "채팅 보내기", message: "채팅을 보내시면 100 포인트가 차감됩니다", preferredStyle: UIAlertController.Style.alert)
        let yAction = UIAlertAction(title: "네 보낼게요", style: UIAlertAction.Style.default, handler: { _ in
            self.navigationController?.pushViewController(viewController, animated: true)
            viewController.otherPerson = self.detailData["User"]
        })
        let nAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
        send.addAction(yAction)
        send.addAction(nAction)
        present(send, animated: true, completion: nil)
        
        
    }
}
