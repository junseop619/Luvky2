//
//  HomeTableViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/12.
//

import UIKit
import Amplify

var articleList = [[String:String]  ]()

class HomeTableViewController: UITableViewController {
    
    var addArticle = [String:String]()
    
    let refreshControll = UIRefreshControl()

    @IBOutlet var articleListView: UITableView!
    @IBOutlet weak var localBtn: UIButton!
    @IBOutlet weak var sexBtn: UIButton!
    @IBOutlet var memberBtn: UIButton!
    @IBOutlet var ageBtn: UIButton!
    
    var testLocal: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articleListView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        //tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        
        initRefresh()
        
        Task.init{
            //let _: () = await deleteTodo("같이 술먹자 준섭아")
            let _: () = await deleteAllTodos()
            let _: () = await subscribeNotice()
            
        }

        
        //local button tempo
        let local = UIAction(title: "전체지역", handler: {_ in print("a")})
        let local1 = UIAction(title: "경기도", handler: {_ in print("b")})
        let local2 = UIAction(title: "충남", handler: {_ in print("c")})
        
        self.localBtn.menu = UIMenu(title: "지역", identifier: nil, options: .displayInline, children: [local, local1, local2])
        self.localBtn.showsMenuAsPrimaryAction = true
        self.localBtn.changesSelectionAsPrimaryAction = true
        
        
        //sex button setting
        let allSex = UIAction(title: "전체성별" , handler: {_ in print("a")})
        let male = UIAction(title: "남성", handler: {_ in print("b")})
        let female = UIAction(title: "여성", handler: {_ in print("c")})
        
        self.sexBtn.menu = UIMenu(title: "성별", identifier: nil, options: .displayInline, children: [allSex,male, female])
        self.sexBtn.showsMenuAsPrimaryAction = true
        self.sexBtn.changesSelectionAsPrimaryAction = true
        
        //member button setting
        let allMember = UIAction(title: "전체인원", handler: {_ in print("a")})
        let member1 = UIAction(title: "1명", handler: {_ in print("b")})
        let member2 = UIAction(title: "2명", handler: {_ in print("c")})
        
        self.memberBtn.menu = UIMenu(title: "인원", identifier: nil, options: .displayInline, children: [allMember, member1, member2])
        self.memberBtn.showsMenuAsPrimaryAction = true
        self.memberBtn.changesSelectionAsPrimaryAction = true
        
        //age button setting
        let allAge = UIAction(title: "전체나이", handler: {_ in print("a")})
        let age20 = UIAction(title: "20대", handler: {_ in print("b")})
        let age30 = UIAction(title: "30대", handler: {_ in print("c")})
        
        self.ageBtn.menu = UIMenu(title: "나이", identifier: nil, options: .displayInline, children: [allAge, age20, age30])
        self.ageBtn.showsMenuAsPrimaryAction = true
        self.ageBtn.changesSelectionAsPrimaryAction = true
        
    
        //base database
        //let item1 = ["userImg":"test1.jpeg","name":"카리나","sex":"여성","age":"24","local":"충남","member":"1명","titleImg":"test1.jpeg","title":"술먹을 준섭이 구함"]
        //articleList = [item1]
        
        //read Notice code
        Task.init{
            let _: () = await readNotice()
            print("suuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu")
        }
    }
    
    //table view pull down recycling
    func initRefresh(){
        refreshControll.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        articleListView.refreshControl = refreshControll
    }
    
    @objc func refreshTable(refresh: UIRefreshControl){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.articleListView.reloadData()
            refresh.endRefreshing()
        }
    }
    
    
    // database refresh
    func subscribeNotice() async {
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
    
    
    //image download (original)
    func downloadImage(fileName: String, filePath: URL){
        /*
        let downloadToFileName = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(fileName)*/

        let downloadTask = Amplify.Storage.downloadFile(
            key: fileName,
            local: filePath,
            options: nil
        )
        _ = downloadTask
            .inProcessPublisher
            .sink { progress in
                print("Progress: \(progress)")
            }

        _ = downloadTask
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
            receiveValue: {
            
                print("Completed")
                print("read image test----------------------------------------")
                print(fileName)
            }
    }
    
    
    
    
    func downloadImage2(fileName: String) -> UIImage {

        let downloadToFileName = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(fileName)

        let downloadTask = Amplify.Storage.downloadFile(
            key: fileName,
            local: downloadToFileName,
            options: nil
        )
        let progressSink = downloadTask
            .inProcessPublisher
            .sink { progress in
                print("Progress: \(progress)")
            }

        let resultSink = downloadTask
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
            receiveValue: {
                print("Completed")
            }
        let imageData = try? Data(contentsOf: downloadToFileName)
        let image = UIImage(data: imageData!)
        return image!
        
    }
    
    func downloadImage3(fileName: String, filePath: URL, completion: @escaping (UIImage?) -> Void) {
        let downloadTask = Amplify.Storage.downloadFile(
            key: fileName,
            local: filePath,
            options: nil
        )
        
        _ = downloadTask.inProcessPublisher.sink { progress in
            print("Progress: \(progress)")
        }

        _ = downloadTask.resultPublisher.sink {
            if case let .failure(storageError) = $0 {
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                completion(nil) // Call completion with nil when download fails
            }
        } receiveValue: { _ in
            let imageData = try? Data(contentsOf: filePath)
            let image = UIImage(data: imageData!)
            completion(image) // Call completion with the downloaded image
        }
    }
    
    func testImage(fileName: String, filePath: URL) -> UIImage {
        let downloadTask = Amplify.Storage.downloadFile(
            key: fileName,
            local: filePath,
            options: nil
        )
        _ = downloadTask.inProcessPublisher.sink { progress in
            print("Progress: \(progress)")
        }

        _ = downloadTask.resultPublisher.sink {
            if case let .failure(storageError) = $0 {
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        } receiveValue: { _ in
            print("Completed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        }
        //return UIImage(named: "sampleImage")!
        if let imageData = try? Data(contentsOf: filePath) {
            return UIImage(data: imageData) ?? UIImage(named: fileName)!
        } else {
            // Handle the case when the image data cannot be fetched
            return UIImage(named: fileName)!
        }
    }

    
    
    //'GET' DB method
    private func readNotice() async {
        do{
            let notices = try await Amplify.DataStore.query(Notice.self)
            for notice in notices {
                addArticle = ["userImg":"test2.jpeg","sex":"여성","age":"23","local":notice.local,"member":notice.Member,"titleImgName":notice.ImageName,"titleImgUrl":notice.ImageUrl,"title":notice.title]
                articleList.append(addArticle)
                print("it is right?????????????????????????????????????????????????")
                print(notice.ImageName)
                print(notice.ImageUrl)
            }
        } catch {
            print("Could not query DataStore: \(error)")
        }
    }
    
    
    private func deleteTodo(_ title: String) async {
        do {
            let todos = try await Amplify.DataStore.query(Notice.self,
                                                          where: Notice.keys.title.eq("File quarterly taxes"))
            guard todos.count == 1, let toDeleteTodo = todos.first else {
                print("Did not find exactly one todo, bailing")
                return
            }
            try await Amplify.DataStore.delete(toDeleteTodo)
            print("Deleted item: \(toDeleteTodo.title)")
        } catch {
            print("Unable to perform operation: \(error)")
        }
    }
    
    private func deleteAllTodos() async {
        do {
            let todos = try await Amplify.DataStore.query(Notice.self)
            
            for todo in todos {
                try await Amplify.DataStore.delete(todo)
                print("Deleted item: \(todo.title)")
            }
        } catch {
            print("Unable to perform operation: \(error)")
        }
    }
    
    //update in dataStore
    private func updateTodo(_ title: String) async {
        do {
            let todos = try await Amplify.DataStore.query(Todo.self,
                                                          where: Todo.keys.name.eq("Finish quarterly taxes"))
            guard todos.count == 1, var updatedTodo = todos.first else {
                print("Did not find exactly one todo, bailing")
                return
            }
            updatedTodo.name = "File quarterly taxes"
            let savedTodo = try await Amplify.DataStore.save(updatedTodo)
            print("Updated item: \(savedTodo.name)")
        } catch {
            print("Unable to perform operation: \(error)")
        }
    }
  

    
    override func viewWillAppear(_ animated: Bool) { //new add list motion
        articleListView.reloadData() //add function & reload table view
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articleList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
        let dictTemp = articleList[indexPath.row]
        
        
        
        let imageName = dictTemp["titleImgName"]
        let imageUrlString = dictTemp["titleImgUrl"] ?? "" // Get the URL string from the dictionary, if available
        let imageUrl = URL(string: imageUrlString) // Convert the URL string to a URL object
    
        /*
        downloadImage3(fileName: dictTemp["titleImgName"]!, filePath: imageUrl ?? URL(fileURLWithPath: "")) { image in
            DispatchQueue.main.async {
                if let image = image {
                    cell.articleTitleImg.image = image
                } else {
                    // You may want to display a placeholder image or handle the case when the image download fails.
                    print("fffuccccckckfjdskjfhsdlkjfhaslkfjhwalkjfhasdlkjfghslkjgfhsdlkjfghsalkjghlakjghslkjghsdlkjghdflkjghdflkgjhdfkg")
                }
            }
        }*/
        
        
        cell.articleUserImg.image = UIImage(named: dictTemp["userImg"]!)
        cell.articleUserName.text = dictTemp["name"]
        cell.articleUserSex.text = dictTemp["sex"]
        cell.articleUserAge.text = dictTemp["age"]
        cell.articleUserLocal.text = dictTemp["local"]
        cell.articleUserMember.text = dictTemp["member"]
        cell.articleTitleImg.image = testImage(fileName: dictTemp["titleImgName"]!, filePath: imageUrl ?? URL(fileURLWithPath: ""))
        
        
        //cell.articleTitleImg.image = UIImage(named: image)
        //cell.articleTitleImg.image = UIImage(named: dictTemp["titleImg"]!)
        //cell.articleTitleImg.image = UIImage(named: downloadImage2(fileName: dictTemp["titleImg"]!))
        //cell.articleTitleImg.image = UIImage(named: (downloadImage(fileName: dictTemp["titleImgName"]!, filePath: dictTemp["titleImgUrl"])))
        //cell.articleTitleImg.image = downloadImage2(fileName: dictTemp["titleImg"]!)
        
        //cell.articleTitleImg.image = UIImage(named: dictTemp["titleImg"]!)
        cell.articleTitle.text = dictTemp["title"]
        
        return cell
    }
    
    //-----------------
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Return the desired height for the cell at the specified indexPath
        return 550.0 // Adjust this value to your desired cell height
        //return UITableView.automaticDimension
    }
    //-----------------
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "homeDetail" {
            let cell = sender as! UITableViewCell
            let indexPath = self.articleListView.indexPath(for: cell)
            let detailView = segue.destination as! DetailArticleViewController
            //detailView.receiveItem(items[((indexPath! as NSIndexPath).row)])
            //detailView.receiveImgItem(itemsImageFile[((indexPath! as NSIndexPath).row)])
            detailView.detailData = articleList[(self.tableView.indexPathForSelectedRow)!.row]
        }
    }

}
