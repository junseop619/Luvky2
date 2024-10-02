//
//  SettingProfileViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/08/01.
//

import UIKit
import Amplify
import Combine

import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class SettingProfileViewController: UIViewController {
    
    var progressSink: AnyCancellable?
    var resultSink: AnyCancellable?
    var userSubscription:  AmplifyAsyncThrowingSequence<MutationEvent>?
    @IBOutlet var settingProfileNickName: UITextField!
    @IBOutlet var settingProfileAge: UITextField!
    @IBOutlet var settingProfileText: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    let picker = UIImagePickerController()
    var selectedFileName: String?
    var selectedFileUrl: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.image = UIImage(named: "Luvky_Icon.png")!
        picker.delegate = self
    }
    
    func openLibrary(){
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
    }
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            present(picker, animated: false, completion: nil)
        }
        else{
            print("Camera not available")
        }
    }

    @IBAction func imageSetting2Btn(_ sender: Any) {
        let alert = UIAlertController(title: "사진을 고르시겠습니까?", message: "원하는 메세지", preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "사진앨범", style: .default) { (action) in self.openLibrary()}
        let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
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
    
    @IBAction func profileSaveBtn(_ sender: UIButton) {
        Task { @MainActor in
            guard let fileName = selectedFileName, let fileUrl = selectedFileUrl else {
                print("Error: File information is missing.")
                return
            }
            let email = userGetAuth()
            await updateProfile(email!, settingProfileNickName.text!, settingProfileText.text!, settingProfileAge.text!, fileName, fileUrl.absoluteString)
            await subscribeToUser()
            settingProfileNickName.text = ""
            settingProfileText.text = ""
            settingProfileAge.text = ""
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateProfile(_ kakaoEmail:String, _ userNickName: String, _ userText: String, _ userAge: String, _ ImageName: String, _ ImageUrl: String) async {
        do {
            let users = try await Amplify.DataStore.query(User.self,
                                                          where: User.keys.id.eq(kakaoEmail))
            guard users.count == 1, var updatedUser = users.first else {
                print("Did not find exactly one todo, bailing")
                return
            }
            updatedUser.UserNickName = userNickName
            updatedUser.UserText = userText
            updatedUser.UserAge = userAge
            updatedUser.UserImageName = ImageName
            updatedUser.UserImageUrl = ImageUrl
            let savedUser = try await Amplify.DataStore.save(updatedUser)
        } catch {
            print("Unable to perform operation: \(error)")
        }
    }
    
    
    func uploadImageOrigin(url: URL, fileName: String){
        let localImageUrl = url
        let fileNameKey = fileName
        let uploadTask = Amplify.Storage.uploadFile(
            key: fileNameKey,
            local: localImageUrl
        )
        progressSink = uploadTask
            .inProcessPublisher
            .sink { progress in
                print("Progress: \(progress)")
            }
        resultSink = uploadTask
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
            receiveValue: { data in
                print("Completed: \(data)")
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

extension SettingProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
            let uuid = UUID().uuidString
            let fileName = "\(uuid).jpeg"
            let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(uuid, isDirectory: false)
                .appendingPathExtension("jpeg")
            if let data = image.jpegData(compressionQuality: 0.8) {
                do {
                    try data.write(to: url)
                    self.selectedFileName = fileName
                    self.selectedFileUrl = url
                    uploadImageOrigin(url: url, fileName: fileName)
                } catch {
                    print("Handle the error, i.e. disk can be full")
                }
            }
            print(info)
        }
        dismiss(animated: true, completion: nil)
    }
}
