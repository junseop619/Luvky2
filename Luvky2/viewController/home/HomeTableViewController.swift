//
//  HomeTableViewController.swift
//  Luvky2
//
//  Created by 황준섭 on 2023/07/12.
//

import UIKit
import Amplify

var articleList = [[String:String]]()


class HomeTableViewController: UITableViewController {
    
    var addArticle = [String:String]()
    var addArticleUser = [String:String]()
    let refreshControll = UIRefreshControl()
    var noticeSubscription:  AmplifyAsyncThrowingSequence<MutationEvent>?

    @IBOutlet var articleListView: UITableView!
    @IBOutlet weak var localBtn: UIButton!
    @IBOutlet weak var sexBtn: UIButton!
    @IBOutlet var memberBtn: UIButton!
    @IBOutlet var ageBtn: UIButton!
    
    //pull down btn에 대한 variable
    var testLocal: String! {
        didSet {
            DispatchQueue.main.async {
                Task {
                    await self.originReadNotice()
                    self.articleListView.reloadData()
                }
            }
        }
    }
    var testSex: String! {
        didSet {
            DispatchQueue.main.async {
                Task {
                    await self.originReadNotice()
                    self.articleListView.reloadData()
                }
            }
        }
    }
    var testMember: String! {
        didSet {
            DispatchQueue.main.async {
                Task {
                    await self.originReadNotice()
                    self.articleListView.reloadData()
                }
            }
        }
    }
    var testAge: Int! {
        didSet {
            DispatchQueue.main.async {
                Task {
                    await self.originReadNotice()
                    self.articleListView.reloadData()
                }
            }
        }
    }
    
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task{
            //await deleteAllTodos()
            //await readNotice()
            //await originReadNotice()
            await subscribeToNotice()
        }
        articleListView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        initRefresh()
        
        
        //local button tempo
        let local = UIAction(title: "전체지역", handler: {_ in self.testLocal = "전체지역"})
        let local1 = UIAction(title: "경기도", handler: {_ in
            self.testLocal = "경기도"
        })
        let local2 = UIAction(title: "충남", handler: {_ in self.testLocal = "충남"})
        
        self.localBtn.menu = UIMenu(title: "지역", identifier: nil, options: .displayInline, children: [local, local1, local2])
        self.localBtn.showsMenuAsPrimaryAction = true
        self.localBtn.changesSelectionAsPrimaryAction = true
        
        
        //sex button setting
        let allSex = UIAction(title: "전체성별" , handler: {_ in self.testSex = "전체성별"})
        let male = UIAction(title: "남성", handler: {_ in self.testSex = "남성"})
        let female = UIAction(title: "여성", handler: {_ in self.testSex = "여성"})
        
        self.sexBtn.menu = UIMenu(title: "성별", identifier: nil, options: .displayInline, children: [allSex,male, female])
        self.sexBtn.showsMenuAsPrimaryAction = true
        self.sexBtn.changesSelectionAsPrimaryAction = true
        
        //member button setting
        let allMember = UIAction(title: "전체인원", handler: {_ in self.testMember = "전체인원"})
        let member1 = UIAction(title: "1명", handler: {_ in self.testMember = "1명"})
        let member2 = UIAction(title: "2명", handler: {_ in self.testMember = "2명"})
        
        self.memberBtn.menu = UIMenu(title: "인원", identifier: nil, options: .displayInline, children: [allMember, member1, member2])
        self.memberBtn.showsMenuAsPrimaryAction = true
        self.memberBtn.changesSelectionAsPrimaryAction = true
        
        //age button setting
        let allAge = UIAction(title: "전체나이", handler: {_ in self.testAge = 0})
        let age20 = UIAction(title: "20대", handler: {_ in self.testAge = 2})
        let age30 = UIAction(title: "30대", handler: {_ in self.testAge = 3})
        
        self.ageBtn.menu = UIMenu(title: "나이", identifier: nil, options: .displayInline, children: [allAge, age20, age30])
        self.ageBtn.showsMenuAsPrimaryAction = true
        self.ageBtn.changesSelectionAsPrimaryAction = true
        
        
        
    }
    

    func initRefresh(){
        refreshControll.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        articleListView.refreshControl = refreshControll
    }
    @objc func refreshTable(refresh: UIRefreshControl){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Task{
                await self.subscribeToNotice()
                await self.originReadNotice()
                self.articleListView.reloadData()
            }
            refresh.endRefreshing()
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
    

    // 'Read' - Notice
    private func readNotice() async {
        do{
            let notices = try await Amplify.DataStore.query(Notice.self)
            for notice in notices {
                addArticle = ["noticeId":notice.id,"local":notice.Local,"member":notice.Member,"titleImgName":notice.ImageName,"titleImgUrl":notice.ImageUrl,"title":notice.noticeTitle,"User":notice.User,"Date":notice.Date]
                articleList.append(addArticle)
                let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(notice.User))
                for user in users{
                    addArticleUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl,"sex":user.UserSex,"age":user.UserAge]
                    articleList.append(addArticleUser)
                }
            }
            articleList.reverse()
            
        } catch {
            print("Could not query DataStore: \(error)")
        }
    }
    
        
    private func originReadNotice() async {
        var notices: [Notice] = []
        articleList = []
        
        do{
            if(testLocal != nil && testLocal != "전체지역"){
                if(testMember != nil && testMember != "전체인원"){
                    notices = try await Amplify.DataStore.query(Notice.self, where: Notice.keys.Local.eq(testLocal) && Notice.keys.Member.eq(testMember))
                } else {
                    notices = try await Amplify.DataStore.query(Notice.self, where: Notice.keys.Local.eq(testLocal))
                }
            } else { //전체 지역 고려
                if(testMember != nil && testMember != "전체인원"){
                    notices = try await Amplify.DataStore.query(Notice.self, where: Notice.keys.Member.eq(testMember))
                } else{ //전체 인원 고려(o)
                    notices = try await Amplify.DataStore.query(Notice.self)
                }
            }
            
            for notice in notices {
                addArticle = ["noticeId":notice.id,"local":notice.Local,"member":notice.Member,"titleImgName":notice.ImageName,"titleImgUrl":notice.ImageUrl,"title":notice.noticeTitle,"text":notice.noticeText ,"User":notice.User,"Date":notice.Date]
                articleList.append(addArticle)
                
                if(testSex != nil && testSex != "전체성별"){
                    if(testAge != nil && testAge != 0){
                        switch testAge {
                        case 0:
                            let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(notice.User) && User.keys.UserSex.eq(testSex))
                            for user in users{
                                addArticleUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl,"sex":user.UserSex,"age":user.UserAge]
                                articleList.append(addArticleUser)
                            }
                        case 2:
                            let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(notice.User) && User.keys.UserSex.eq(testSex) && User.keys.UserAge >= 20 && User.keys.UserAge < 30)
                            for user in users{
                                addArticleUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl,"sex":user.UserSex,"age":user.UserAge]
                                articleList.append(addArticleUser)
                            }
                        case 3:
                            let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(notice.User) && User.keys.UserSex.eq(testSex) && User.keys.UserAge >= 30 && User.keys.UserAge < 40)
                            for user in users{
                                addArticleUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl,"sex":user.UserSex,"age":user.UserAge]
                                articleList.append(addArticleUser)
                            }
                        default:
                            return
                        }
                    } else {
                        let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(notice.User) && User.keys.UserSex.eq(testSex))
                        for user in users{
                            addArticleUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl,"sex":user.UserSex,"age":user.UserAge]
                            articleList.append(addArticleUser)
                        }
                    }
                    
                } else {
                    if(testAge != nil && testAge != 0){
                        switch testAge {
                        case 0:
                            let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(notice.User))
                            for user in users{
                                addArticleUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl,"sex":user.UserSex,"age":user.UserAge]
                                articleList.append(addArticleUser)
                            }
                        case 2:
                            let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(notice.User) && User.keys.UserAge >= 20 && User.keys.UserAge < 30)
                            for user in users{
                                addArticleUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl,"sex":user.UserSex,"age":user.UserAge]
                                articleList.append(addArticleUser)
                            }
                        case 3:
                            let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(notice.User) && User.keys.UserAge >= 30 && User.keys.UserAge < 40)
                            for user in users{
                                addArticleUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl,"sex":user.UserSex,"age":user.UserAge]
                                articleList.append(addArticleUser)
                            }
                        default:
                            return
                        }
                    } else {
                        let users = try await Amplify.DataStore.query(User.self, where: User.keys.id.eq(notice.User))
                        for user in users{
                            addArticleUser = ["userNickName":user.UserNickName,"userImgName":user.UserImageName,"userImgUrl":user.UserImageUrl,"sex":user.UserSex,"age":user.UserAge]
                            articleList.append(addArticleUser)
                        }
                    }
                    
                }
            }
            articleList.reverse()
        } catch {
            print("Could not query DataStore: \(error)")
        }
    }

    
    
    // just test code ------------------------------------------------------------------------------------
    
    //delete test code
    private func deleteTodo(_ title: String) async {
        do {
            let todos = try await Amplify.DataStore.query(Notice.self,
                                                          where: Notice.keys.noticeTitle.eq("File quarterly taxes"))
            guard todos.count == 1, let toDeleteTodo = todos.first else {
                print("Did not find exactly one todo, bailing")
                return
            }
            try await Amplify.DataStore.delete(toDeleteTodo)
        } catch {
            print("Unable to perform operation: \(error)")
        }
    }
    
    //simulator test code
    private func deleteAllTodos() async {
        do {
            let todos = try await Amplify.DataStore.query(Notice.self)
            
            for todo in todos {
                try await Amplify.DataStore.delete(todo)
            }
        } catch {
            print("Unable to perform operation: \(error)")
        }
    }
    
    // ------------------------------------------------------------------------------------------------------------

    


    override func viewWillAppear(_ animated: Bool) {
        //articleListView.reloadData()
        Task{
            //await readNotice()
            //await subscribeToNotice()
            await originReadNotice()
            articleListView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleList.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
        let dictTemp = articleList[indexPath.row]
        
        let imageUrlString = dictTemp["titleImgUrl"] ?? ""
        let imageUrl = URL(string: imageUrlString)
        
        let imageUrlString2 = dictTemp["userImgUrl"] ?? ""
        let imageUrl2 = URL(string: imageUrlString2)
        
        cell.articleUserName.text = dictTemp["userNickName"]
        cell.articleUserSex.text = dictTemp["sex"]
        cell.articleUserAge.text = dictTemp["age"]
        cell.articleUserLocal.text = dictTemp["local"]
        cell.articleUserMember.text = dictTemp["member"]
        Task {
            let image = await downloadImage(fileName: dictTemp["titleImgName"] ?? "")
            cell.articleTitleImg.image = image
            let userImage = await downloadImage(fileName: dictTemp["userImgName"] ?? "")
            cell.articleUserImg.image = userImage
        }
        cell.articleTitle.text = dictTemp["title"]
        cell.articleDate.text = dictTemp["Date"]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 550.0
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeDetail" {
            let cell = sender as! UITableViewCell
            let indexPath = self.articleListView.indexPath(for: cell)
            let detailView = segue.destination as! DetailArticleViewController
            detailView.detailData = articleList[(self.tableView.indexPathForSelectedRow)!.row]
        }
    }

}
