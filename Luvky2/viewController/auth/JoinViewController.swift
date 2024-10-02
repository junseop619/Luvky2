//
//  JoinViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/27.
//

import UIKit
import Amplify
import Combine
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class JoinViewController: UIViewController {
    
    var userSubscription:  AmplifyAsyncThrowingSequence<MutationEvent>?
    var userSex : String!

    @IBOutlet var userName: UITextField!
    @IBOutlet var userAge: UITextField!
    @IBOutlet var userText: UITextField!
    
    @IBOutlet weak var userSexBtn: UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sex = UIAction(title: "전체성별" , handler: {_ in self.userSex = "성별을 선택하세요"})
        let male = UIAction(title: "남자", handler: {_ in self.userSex = "남자"})
        let female = UIAction(title: "여자", handler: {_ in self.userSex = "여자"})
        
        self.userSexBtn.menu = UIMenu(title: "성별", identifier: nil, options: .displayInline, children: [sex, male, female])
        self.userSexBtn.showsMenuAsPrimaryAction = true
        self.userSexBtn.changesSelectionAsPrimaryAction = true
    }
    
    
    @IBAction func joinUserBtn(_ sender: Any) {
        UserApi.shared.me { [self] user, error in
            if let error = error {
                print(error)
            } else {
                let email = user?.kakaoAccount?.email
                
                if(userSex == "성별을 선택하세요"){
                    let alert = UIAlertController(title: "에러", message: "성별을 선택하셔야 합니다.", preferredStyle: UIAlertController.Style.alert)
                    let check = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)

                } else {
                    Task {
                        //test1.jpeg = basement image(url & path)
                        await joinUser(email!, userName.text!, userSex, userAge.text!,"test1.jpeg","test1.jpeg" ,userText.text!,"2023-09-02",.normal)
                        await subscribeToUser()
                    }
                    guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstMain") as? FirstTabBarViewController else { return }
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainVC, animated: false)
                }

            }
        }
    }
    
    
    private func joinUser(_ KakaoEmail: String, _ UserNickName: String, _ UserSex: String, _ UserAge: String, _ UserImageName: String, _ UserImageUrl: String, _ UserText: String, _ AttendCheck: String, _ priority: Priority) async {
        
        do{
            let item = User(id: KakaoEmail, UserNickName: UserNickName , UserSex: UserSex, UserAge: UserAge, UserImageName:  UserImageName, UserImageUrl: UserImageUrl, UserText: UserText, Attend: AttendCheck, Point:0, priority: priority)
            _ = try await Amplify.DataStore.save(item)
        } catch {
            print("Could not save item to dataStore: \(error)")
        }
    }
    
    
    func subscribeToUser() async {
        let userSubscription = Amplify.DataStore.observe(User.self)
        self.userSubscription = userSubscription
        do {
            for try await changes in userSubscription {
                print("Subscription received mutation: \(changes)")
            }
        } catch {
            print("Subscription received error: \(error)")
        }
    }
    func unsubscribeFromUsers() {
        userSubscription?.cancel()
    }
}
