//
//  AddArticleViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/12.
//

import UIKit
import Amplify
import Combine

class AddArticleViewController: UIViewController {
    
    //test
    var progressSink: AnyCancellable?
    var resultSink: AnyCancellable?
    
    var selectedFileName: String?
    var selectedFileUrl: URL?
    //---
    
    let picker = UIImagePickerController()
    
    var addArticle = [String:String]()
    
    @IBOutlet var articleTitle: UITextField!
    
    @IBOutlet var articleText: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                print("Error: File information is missing.")
                return
            }
            
            await addNotice(articleTitle.text!, "9시에 가능함", "서울", "1명", fileName, fileUrl.absoluteString, .high, "tempo")
            await subscribeTodos()
            
            articleTitle.text = ""
            _ = navigationController?.popViewController(animated: true)
        }
        /*
        Task { @MainActor in
            //await addNotice(articleTitle.text!, "9시에 가능함", "서울", "1명", "test3.jpeg", .high, "tempo0")
            await addNotice(articleTitle.text!, "9시에 가능함", "서울", "1명", selectedFileName!, selectedFileUrl!, .high, "tempo")
            await subscribeTodos()
            
            articleTitle.text=""
            _ = navigationController?.popViewController(animated: true)
        }*/
    }
    
    //dataStore code -------------------------------------------------------------------------------------
    //create
    private func addNotice(_ title: String, _ text: String, _ local: String, _ Member: String, _ ImageName: String, _ ImageUrl: String, _ priority: Priority, _ User: String) async {
        
        do{
            let item = Notice(id: UUID().uuidString, title: title, text: text, local: local, Member: Member, ImageName: ImageName, ImageUrl: ImageUrl, priority: priority, User: User)
            
            _ = try await Amplify.DataStore.save(item)
            //print("Saved Item: \(savedItem.name)")
        } catch {
            print("Could not save item to dataStore: \(error)")
        }
    }

    // refresh code
    func subscribeTodos() async {
      do {
          let mutationEvents = Amplify.DataStore.observe(Todo.self)
          for try await mutationEvent in mutationEvents {
              print("Subscription got this value: \(mutationEvent)")
              do {
                  let todo = try mutationEvent.decodeModel(as: Todo.self)
                  
                  switch mutationEvent.mutationType {
                  case "create":
                      print("Created: \(todo)")
                  case "update":
                      print("Updated: \(todo)")
                  case "delete":
                      print("Deleted: \(todo)")
                  default:
                      break
                  }
              } catch {
                  print("Model could not be decoded: \(error)")
              }
          }
      } catch {
          print("Unable to observe mutation events")
      }
    }
    
    // S3 storage test code -------------------------------------------------
    //image upload to s3 in my Iphone
    
    //test code
    func uploadImageOrigin(url: URL, fileName: String){  //or func uploadImageOrigin(image: UIImage)
        
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
    
    /*
    // MARK: - Navigation
    */

}

extension AddArticleViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image // or imageView?.image = image
            
            let uuid = UUID().uuidString
            let fileName = "\(uuid).jpeg"
                        
            let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(uuid, isDirectory: false)
                .appendingPathExtension("jpeg")
            
            
            // Then write to disk
            if let data = image.jpegData(compressionQuality: 0.8) {
                do {
                    try data.write(to: url)
                    
                    self.selectedFileName = fileName
                    self.selectedFileUrl = url
                    
                    uploadImageOrigin(url: url, fileName: fileName) //Call the updated function to store to AWS bucket
                    print("last test(add)----------------------------------------------------------------------------------------")
                    print(url)
                    print(fileName)
                    print("last test(add)----------------------------------------------------------------------------------------")
                    
                } catch {
                    print("Handle the error, i.e. disk can be full")
                }
            }
            print(info)
            //uploadImage(image: image)
            
        
        }
        
        
        dismiss(animated: true, completion: nil)
      
    }
}

