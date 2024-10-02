import UIKit
import Amplify
import Combine

import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

import Alamofire

var settingList = [[String:String]]()

class SettingTableViewController: UITableViewController {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userInfo: UILabel!
    @IBOutlet var userText: UILabel!
    @IBOutlet var settingListView: UITableView!
    
    @IBOutlet var userSex: UILabel!
    @IBOutlet var userAge: UILabel!
    
    /* in_app & push notification ver
    let settingData = ["충전하기","출석체크","푸쉬알림", "문의하기", "서비스 이용약관","개인정보 취급방침","버전정보", "로그아웃", "탈퇴하기"]
     */
    //tempo
    let settingData = ["출석체크", "문의하기", "서비스 이용약관","개인정보 취급방침","버전정보", "로그아웃", "탈퇴하기"]
    
    var userSubscription:  AmplifyAsyncThrowingSequence<MutationEvent>?
    var detail_info = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingListView.dataSource.self
        Task{
            detail_info = await userInfo() ?? ["":""]
            
            if(detail_info["name"] != nil){
                userName.text = detail_info["name"]
            } else{
                userName.text = "??"
            }
            
            if(detail_info["sex"] != nil){
                userSex.text = detail_info["sex"]
            } else {
                userSex.text = "??"
            }
            
            if(detail_info["age"] != nil){
                userAge.text = detail_info["age"]
            } else {
                userAge.text = "??"
            }
            
            if(detail_info["text"] != nil){
                userText.text = detail_info["text"]
            } else {
                userText.text = "나를 소개해봐요"
            }
            
            let fileName = await detail_info["imageName"]
            let image = await downloadImage(fileName: fileName ?? "")
            await self.userImage.image = image
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
    func unsubscribeFromPosts() {
        userSubscription?.cancel()
    }
    
    private func userInfo() async ->[String:String]? {
        let email = userGetAuth()
        do{
            let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(email))
            var tempo_info = [String:String]()
            for user in users {
                tempo_info = ["name":user.UserNickName,"age":user.UserAge,"sex":user.UserSex,"text":user.UserText,"imageName":user.UserImageName,"imageUrl":user.UserImageUrl]
                return tempo_info
            }
        } catch {
            print("Unable to perform operation: \(error)")
        }
        return nil
    }
    
    func downloadImage(fileName: String) async -> UIImage {
        let url: URL
        do {
            url = try await Amplify.Storage.getURL(key: fileName)
        } catch {
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
            return UIImage(named: "Luvky_Icon.png")!
        }
    }
    
    private func attendance_check() async {
        await subscribeToUser()
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        let email = userGetAuth()
        do{
            let attends = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(email))
            for attend in attends{
                if(attend.id == email){
                    if(attend.Attend == dateString){
                        //already attend
                        let attend = UIAlertController(title: "알림", message: "오늘은 이미 출석보상을 받았어요", preferredStyle: UIAlertController.Style.alert)
                        let yAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                        attend.addAction(yAction)
                        present(attend, animated: true, completion: nil)
                    } else {
                        guard attends.count == 1, var updatedAttend = attends.first else {
                            return
                        }
                        updatedAttend.Attend = dateString
                        updatedAttend.Point += 300
                        let savedAttend = try await Amplify.DataStore.save(updatedAttend)
                        let attend = UIAlertController(title: "출석체크", message: "출석되었습니다.", preferredStyle: UIAlertController.Style.alert)
                        let yAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                        attend.addAction(yAction)
                        present(attend, animated: true, completion: nil)
                    }
                }
            }
        } catch {
            print("Unable to perform operation: \(error)")
        }
    }
    
    private func logout(){
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
                let attend = UIAlertController(title: "로그아웃 되었습니다.", message: "", preferredStyle: UIAlertController.Style.alert)
                let yAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                attend.addAction(yAction)
                self.present(attend, animated: true, completion: nil)
                guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "kakaoLoginView") as? LoginViewController else { return }
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainVC, animated: false)
            }
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
    
    private func deleteAccount() async {
        do {
            let email = userGetAuth()
            let accounts = try await Amplify.DataStore.query(User.self,
                                                          where: User.keys.id.eq(email))
            guard accounts.count == 1, let toDeleteAccount = accounts.first else {
                return
            }
            try await Amplify.DataStore.delete(toDeleteAccount)
        } catch {
            print("Unable to perform operation: \(error)")
        }
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
            }
        }
    }
    
    func revokeAppleToken(clientSecret: String, token: String, completionHandler: @escaping () -> Void) {
        let url = "https://appleid.apple.com/auth/revoke"
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        let parameters: Parameters = [
            "client_id": "com.tistory.pinlib.Luvky2",
            "client_secret": clientSecret,
            "token": token
        ]

        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   headers: header)
        .validate(statusCode: 200..<300)
        .responseData { response in
            guard let statusCode = response.response?.statusCode else { return }
            if statusCode == 200 {
                print("애플 토큰 삭제 성공!")
                completionHandler()
            }
        }
    }
    
    
    @IBAction func changeProfileBtn(_ sender: UIButton) {
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingData.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingTableViewCell
        cell.settingText.text = settingData[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    /* in_app & push notification ver
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingListView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
            
        case 0: self.performSegue(withIdentifier: "setting_charge", sender: nil) //인앱결제 - 1.1.0 ver 구현 에정
            let attend = UIAlertController(title: "기달려주세요", message: "정식버전 때 출시 할 에정입니다.", preferredStyle: UIAlertController.Style.alert)
            let yAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            attend.addAction(yAction)
            present(attend, animated: true, completion: nil)
            
        case 1: //출석체크
            Task {
                await attendance_check()
            }
            
        case 2: self.performSegue(withIdentifier: "setting_pushAlarm", sender: nil) //푸쉬알림 - 1.1.0 ver 구현 예정
            let attend = UIAlertController(title: "기달려주세요", message: "정식버전 때 출시 할 에정입니다.", preferredStyle: UIAlertController.Style.alert)
            let yAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            attend.addAction(yAction)
            present(attend, animated: true, completion: nil)
            
        case 3: //문의하기
            let attend = UIAlertController(title: "문의하기", message: "nehcom00@gmail.com으로 문의 부탁드립니다.", preferredStyle: UIAlertController.Style.alert)
            let yAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            attend.addAction(yAction)
            present(attend, animated: true, completion: nil)
        
        case 4: self.performSegue(withIdentifier: "setting_serviceText", sender: nil)
        case 5: self.performSegue(withIdentifier: "setting_userInfoText", sender: nil)     
            
        case 6: //버전정보
            if let information = Bundle.main.infoDictionary{
                if let appVersion = information["CFBundleShortVersionString"] as? String {
                    print(appVersion)
                    let attend = UIAlertController(title: "현재 버전", message: "현재 버전 " + appVersion, preferredStyle: UIAlertController.Style.alert)
                    let yAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                    attend.addAction(yAction)
                    present(attend, animated: true, completion: nil)
                }
            }
        case 7: //로그아웃
            let attend = UIAlertController(title: "로그아웃 하시겠습니까?", message: "", preferredStyle: UIAlertController.Style.alert) //버전정보
            let yAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: {
                Action in self.logout()
            })
            let nAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
            attend.addAction(yAction)
            attend.addAction(nAction)
            present(attend, animated: true, completion: nil)
        
        case 8: //탈퇴하기
            let attend = UIAlertController(title: "탈퇴하시겠습니까?", message: "탈퇴 후에도 재가입이 가능하나 모든 정보는 복구될 수 없습니다.", preferredStyle: UIAlertController.Style.alert) //버전정보
            let yAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: {
                Action in Task{
                    await self.deleteAccount()
                }
            })
            let nAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
            attend.addAction(yAction)
            attend.addAction(nAction)
            present(attend, animated: true, completion: nil)
        default:
            return
        }
    }*/
    
    //1.0.1 ver
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingListView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
            
        case 0: //출석체크
            Task {
                await attendance_check()
            }
            
        case 1: //문의하기
            let attend = UIAlertController(title: "문의하기", message: "nehcom00@gmail.com으로 문의 부탁드립니다.", preferredStyle: UIAlertController.Style.alert)
            let yAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            attend.addAction(yAction)
            present(attend, animated: true, completion: nil)
        
        case 2: self.performSegue(withIdentifier: "setting_serviceText", sender: nil)
        case 3: self.performSegue(withIdentifier: "setting_userInfoText", sender: nil)
            
        case 4: //버전정보
            if let information = Bundle.main.infoDictionary{
                if let appVersion = information["CFBundleShortVersionString"] as? String {
                //if let appVersion = information["CFBundleLongVersionString"] as? String {
                    print(appVersion)
                    let attend = UIAlertController(title: "현재 버전", message: "현재 버전 " + appVersion, preferredStyle: UIAlertController.Style.alert)
                    let yAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                    attend.addAction(yAction)
                    present(attend, animated: true, completion: nil)
                }
            }
        case 5: //로그아웃
            let attend = UIAlertController(title: "로그아웃 하시겠습니까?", message: "", preferredStyle: UIAlertController.Style.alert) //버전정보
            let yAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: {
                Action in self.logout()
            })
            let nAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
            attend.addAction(yAction)
            attend.addAction(nAction)
            present(attend, animated: true, completion: nil)
        
        case 6: //탈퇴하기
            let attend = UIAlertController(title: "탈퇴하시겠습니까?", message: "탈퇴 후에도 재가입이 가능하나 모든 정보는 복구될 수 없습니다.", preferredStyle: UIAlertController.Style.alert) //버전정보
            let yAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: {
                Action in Task{
                    await self.deleteAccount()
                }
            })
            let nAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.default, handler: nil)
            attend.addAction(yAction)
            attend.addAction(nAction)
            present(attend, animated: true, completion: nil)
        default:
            return
        }
        
    }

}
