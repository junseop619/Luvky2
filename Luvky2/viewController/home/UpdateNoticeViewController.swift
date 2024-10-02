//
//  UpdateNoticeViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/08/11.
//

import UIKit
import Amplify
import Combine

class UpdateNoticeViewController: UIViewController {
    
    var addArticle = [String:String]()
    var addArticleUser = [String:String]()
    
    var progressSink: AnyCancellable?
    var resultSink: AnyCancellable?
    
    var noticeSubscription:  AmplifyAsyncThrowingSequence<MutationEvent>?

    
    var selectedFileName: String?
    var selectedFileUrl: URL?
    
    var memberCount: String?
    
    let picker = UIImagePickerController()
    
    @IBOutlet weak var noticeImage: UIImageView!
    
    @IBOutlet var noticeTitle: UITextField!
    
    @IBOutlet var noticeText: UITextField!
    
    @IBOutlet weak var noticeLocalBtn: UIButton!
    
    @IBOutlet weak var noticeMemberCount: UILabel!
    
    @IBOutlet weak var noticeStepper: UIStepper!
    
    var testLocal: String!
    
    //detail view로부터 data를 받아 올 variable
    var idData : String = ""
    var localData : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task{
            await getNotice(idData)
        }
        picker.delegate = self
        
        let local = UIAction(title: localData, handler: {_ in
            print(self.localData)
            self.testLocal = self.localData
        })
        let local1 = UIAction(title: "경기도", handler: {_ in
            print("경기도")
            self.testLocal = "경기도"
        })
        let local2 = UIAction(title: "충남", handler: {_ in
            print("충남")
            self.testLocal = "충남"
        })
        
        self.noticeLocalBtn.menu = UIMenu(title: "지역을 선택하세요", identifier: nil, options: .displayInline, children: [local, local1, local2])
        self.noticeLocalBtn.showsMenuAsPrimaryAction = true
        self.noticeLocalBtn.changesSelectionAsPrimaryAction = true
        
        //detail view -> update view (notice.id data send)
    }
    
    
    //keyboard touch method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //Get Notice
    private func getNotice(_ noticeId: String) async {
        do{
            //let notices = try await Amplify.DataStore.query(Notice.self)
            let notices = try await Amplify.DataStore.query(Notice.self,
                                                          where: Notice.keys.id.eq(noticeId))
            for notice in notices {
                noticeTitle.text = notice.noticeTitle
                noticeText.text = ""
                noticeMemberCount.text = notice.Member
                
                //image
                Task {
                    let image = await downloadImage(fileName: notice.ImageName)
                    noticeImage.image = image
                }
            }

        } catch {
            print("Could not query DataStore: \(error)")
        }
    }
    
    //Update Part
    private func updateNotice(_ noticeId: String) async {
        do {
            let notices = try await Amplify.DataStore.query(Notice.self,
                                                          where: Notice.keys.id.eq(noticeId))
            guard notices.count == 1, var updatedNotice = notices.first else {
                print("Did not find exactly one todo, bailing")
                return
            }
            updatedNotice.noticeTitle = "File quarterly taxes"
            updatedNotice.noticeText = ""
            updatedNotice.Local = ""
            
            //image
            let fileName = selectedFileName
            let fileUrl = selectedFileUrl
            
            updatedNotice.ImageName = fileName!
            updatedNotice.ImageUrl = fileUrl?.absoluteString ?? ""
            
            let savedNotice = try await Amplify.DataStore.save(updatedNotice)
            
        } catch {
            print("Unable to perform operation: \(error)")
        }
    }
    
    //refresh db
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
    
    
    @IBAction func updateImageBtn(_ sender: Any) {
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
    
    
    @IBAction func updateNoticeBtn(_ sender: UIButton) {
        Task {
            await updateNotice(idData)
            await subscribeToNotice()
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func stepperPress(_ sender: UIStepper) {
        noticeMemberCount.text = Int(sender.value).description + "명"
        memberCount = noticeMemberCount.text
    }
    
    //base image download
    func downloadImage(fileName: String) async -> UIImage {
        let url: URL
        do {
            url = try await Amplify.Storage.getURL(key: fileName)
        } catch {
            print("Failed to get URL for image: \(error)")
            return UIImage(named: "test1.jpeg")!
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
            //let imageData = try Data(contentsOf: url)
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data) ?? UIImage(named: fileName)!
            //try await downloadTask.value
            print("Completed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            //return UIImage(data: imageData) ?? UIImage(named: fileName)!
            
            //test
            selectedFileName = fileName
            selectedFileUrl = url
            
            return image
        } catch {
            print("--------------------------------------------------------------------------------Failed to get URL for image: \(error)")
            print(url)
            return UIImage(named: "test1.jpeg")!
        }
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

    
    // MARK: - Navigation



}

extension UpdateNoticeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            noticeImage.image = image
            
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
                    print("Handle the error, i.e. disk can be full")
                }
            }
            print(info)
        }
        dismiss(animated: true, completion: nil)
    }
}
