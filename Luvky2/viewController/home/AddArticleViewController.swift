//
//  AddArticleViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/12.
//

import UIKit
import Amplify
import Combine

import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser


class AddArticleViewController: UIViewController {
    
    var progressSink: AnyCancellable?
    var resultSink: AnyCancellable?
    
    var selectedFileName: String?
    var selectedFileUrl: URL?
    
    
    let picker = UIImagePickerController()
    
    var addArticle = [String:String]()
    
    @IBOutlet var articleTitle: UITextField!
    @IBOutlet var articleText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var memberCountText: UILabel!
    
    @IBOutlet weak var localBtn: UIButton!
    
    @IBOutlet weak var memberStepper: UIStepper!
    
    var testLocal: String!
    var memberCount = "1명"
    
    var noticeSubscription:  AmplifyAsyncThrowingSequence<MutationEvent>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        let local = UIAction(title: "지역을 선택하세요", handler: {_ in print("지역을 선택하세요")})
        let local1 = UIAction(title: "경기도", handler: {_ in
            print("경기도")
            self.testLocal = "경기도"
        })
        let local2 = UIAction(title: "충남", handler: {_ in
            print("충남")
            self.testLocal = "충남"
        })
        
        self.localBtn.menu = UIMenu(title: "지역을 선택하세요", identifier: nil, options: .displayInline, children: [local, local1, local2])
        self.localBtn.showsMenuAsPrimaryAction = true
        self.localBtn.changesSelectionAsPrimaryAction = true
        
    }
    //keyboard touch method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //본인 Luvky계정안에 저장된 kakaoEmail값을 따옴
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


    @IBAction func stepperPress(_ sender: UIStepper) {
        memberCountText.text = Int(sender.value).description + "명"
        memberCount = memberCountText.text!
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
            let error = UIAlertController(title: "ERROR", message: "카메라를 열 수 없습니다.", preferredStyle: UIAlertController.Style.alert)
            let yError = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            error.addAction(yError)
            present(error, animated: true, completion: nil)
        }
    }

    
    //image popup
    @IBAction func addImage(_ sender: Any) {
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
        
    
    @IBAction func btnAddItem(_ sender: UIButton) {
    
        Task { @MainActor in
            guard let fileName = selectedFileName, let fileUrl = selectedFileUrl else {
                let error = UIAlertController(title: "ERROR", message: "Error: File information is missing.", preferredStyle: UIAlertController.Style.alert)
                let yError = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                error.addAction(yError)
                present(error, animated: true, completion: nil)
                return
            }
            let email = userGetAuth()
            
            
            await addNotice(articleTitle.text!, articleText.text!, testLocal, memberCount, fileName, fileUrl.absoluteString, .high, email!)
            await subscribeToNotice()
            
            memberCount = ""
            articleTitle.text = ""
            articleText.text = ""
            _ = navigationController?.popViewController(animated: true)
        }
    }
    

    //create
    private func addNotice(_ title: String, _ text: String, _ local: String, _ Member: String, _ ImageName: String, _ ImageUrl: String, _ priority: Priority, _ User: String) async {
        
        do{
            //date
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd HH:mm"
            let dateString = dateFormatter.string(from: currentDate)
            
            let item = Notice(id: UUID().uuidString, noticeTitle: title, noticeText: text, Local: local, Member: Member, ImageName: ImageName, ImageUrl: ImageUrl, priority: priority, User: User, Date: dateString)
            
            _ = try await Amplify.DataStore.save(item)
            print(dateString)
        } catch {
            let error = UIAlertController(title: "ERROR", message: "Could not save item to dataStore: \(error)", preferredStyle: UIAlertController.Style.alert)
            let yError = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            error.addAction(yError)
            present(error, animated: true, completion: nil)
            
        }
    }
    
    func subscribeToNotice() async {
        let noticeSubscription = Amplify.DataStore.observe(Notice.self)
        self.noticeSubscription = noticeSubscription
        do {
            for try await changes in noticeSubscription {
                print("Subscription received mutation: \(changes)")
            }
        } catch {
            print("Subscription received error: \(error)")
        }
    }
    func unsubscribeFromPosts() {
        noticeSubscription?.cancel()
    }
    
    //upload image
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
    
    

}

extension AddArticleViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            
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
                    
                    uploadImageOrigin(url: url, fileName: fileName) //Call the updated function to store to AWS bucket

                } catch {
                    let error = UIAlertController(title: "ERROR", message: "Handle the error, i.e. disk can be full", preferredStyle: UIAlertController.Style.alert)
                    let yError = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                    error.addAction(yError)
                    present(error, animated: true, completion: nil)
                }
            }
            print(info)
        }
        dismiss(animated: true, completion: nil)
    }
}

