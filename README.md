# 프로젝트 이름 : Luvky

# 목차
1. 소개글

    1-1. 프로젝트 소개
   
    1-2. 프로젝트 최종단계
   
    1-3. 사용 기술

    1-4. 사용 환경

2. APP 구조도

    2-1. 전체 구조
   
    2-2. Auth
   
    &emsp;2-2-1. Login
   
    &emsp;2-2-2. Join
   
    2-3. TabBar

    2-4. Home
   
    &emsp;2-4-1. HomeTableView
   
    &emsp;2-4-2. AddArticle
   
    &emsp;2-4-3. DetailArticle
   
    &emsp;2-4-4. UpdateNotice

    2-5. Chat
   
    &emsp;2-5-1. ChatList
   
    &emsp;2-5-2. ChattingView

    2-6. Setting

    &emsp;2-6-1. SettingTableView & ProfileView

    &emsp;2-6-2. UserInfoView & ServiceView(서비스 이용약관, 개인정보 취급방침)
   
    &emsp;2-6-3. Setting Alert View

    &emsp;2-6-4. SettingProfileView


3. 기능 구현

    3-1. Database

    3-2. AWS Amplify CRUD

    3-3. Kakao Login with AWS Amplify

    3-4. Chatting System

 
<br></br><br></br>
---

# 1. 소개글

## 1-1. 프로젝트 소개

우리 동네 괜찮은 술집을 찾고 싶을 때?

동네 사람들의 후기를 찾아봐요.

우리 동네 괜찮은 술집을 찾았다면?

후기를 작성해서 서로 정보를 공유해봐요.

가고 싶은 술집이 있는데, 혼자라면?

게시물을 올리고 같이 술마실 사람을 찾아봐요.

늘 똑같은 사람과 장소를 선택하지 마요.

럽키가 도와줄게요.




## 1-2. 프로젝트 최종 단계

App store 앱 심사 탈락

사유 : 이미 너무 많이 존재하는 컨텐츠

![app_store_spam](https://github.com/user-attachments/assets/d642f14b-65ce-4ed9-86e5-d369abb8eb04)


## 1-3. 사용 기술    

![js](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white) ![js](https://img.shields.io/badge/Amazon_AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white) 

## 1-4. 사용 환경

![js](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white)

# 2. APP 구조도

## 2-1. 전체 구조

![all view](https://github.com/user-attachments/assets/ea9909f4-b2bd-4d66-bd63-0a60e92323c8)

<br></br>

## 2-2. Auth

![auth](https://github.com/user-attachments/assets/ed862c0e-a075-48ab-bf65-2232b88759a1)

APP 시작시 로그인 화면이 나오며 Kakao 로그인과 Apple 로그인 중 선택하여 로그인(회원가입)을 시작합니다.

이후 카카오로 회원가입을 이미 한 유저라면 Luvky 서비스를 정상적으로 사용하게 되고,

카카오로 최초 로그인이라면 kakao developer API를 이용해 받아온 데이터를 기반으로 JoinViewController로 이동하여 회원가입 절차를 완료하게 됩니다.

로그인 절차 성공시 token을 발급받게 되는데, APP 시작할 때 토큰 검사에 성공한다면 로그인 화면은 등장하지 않으며, 바로 Luvky 서비스를 시작 할 수 있습니다.

<br></br>

## 2-3. TabBar

![스크린샷 2024-10-05 오후 3 21 19](https://github.com/user-attachments/assets/383aa13f-de88-4f46-a39a-e2404a2f83f0)

본격적인 Luvky service 실행시 First Tab Bar View Controller가 실행되게 됩니다.

해당 TabBar에는 각각 Home, Chat, Setting의 Navigation Controller에 연결하여, TabBar 선택에 따른 View를 전환할 수 있게 됩니다.

해당 기술 구현에 대한 참조는 본인 블로그인 [Xcode 탭바 컨트롤러 이용해 여러 개의 뷰 넣기](https://pinlib.tistory.com/entry/Xcode-탭바-컨트롤러-이용해-여러-개의-뷰-넣기) 해당 게시물을 참조 부탁드립니다.

<br></br>

## 2-4. Home

![스크린샷 2024-10-05 오후 3 24 17](https://github.com/user-attachments/assets/82963cd8-e5f6-439e-af38-efea7d3804d5)

> ## 2-4-1. HomeTableView

TabBar에서 Home을 선택하게 되면 해당 Navigation Controller에 연결된 HomeTableViewController가 제일 먼저 나오게 됩니다.

<img width="336" alt="스크린샷 2024-10-05 오후 4 33 02" src="https://github.com/user-attachments/assets/62a9352e-80b5-4a09-a53d-e565df2b49f7">

HomeTableViewController에서는 유저들의 게시물이 올라오게 되고, 상단의 분류 항목 버튼에 따라, 지역, 성별, 인원, 나이별로 원하는 게시물을 화면에 띄울 수 있습니다.

HomeTableView에서 나오는 게시물들의 구조는 HomeTableViewCell에서 정의하여 구조화 합니다.

만들었던 과정은 본인 블로그인 [table view controller 만들기](https://pinlib.tistory.com/entry/table-view-controller-만들기) 해당 게시물에 매우 조그마하게 작성했었습니다.

<br></br>

> ## 2-4-2. AddArticle

게시물을 추가하기 위한 View입니다. 해당 View의 경우 HomeTableView에서 상단 바에 존재하는 +가 있는 말풍선 모양의 Icon을 선택하면 이동하게 됩니다.

AddArticleViewController에서는 게시물에 올릴 이미지와 제목, 내용, 현재 지역, 현재 인원들을 작성하고 게시물에 등록하게 됩니다.

<br></br>

> ## 2-4-3. DetailArticle

HomeTableView에 있는 게시물을 터치하면 DetailArticle에 접근하게 되며 DetailArticleController가 작동되게 됩니다.

DetailArticle에서는 해당 게시물에 더 자세한 내용을 제공하며 해당 게시물의 작성자에게 채팅 보내기와 프로필 보기 기능을 제공합니다.

<br></br>

> ## 2-4-4. UpdateNotice

자신이 작성한 게시물에 대하여 내용을 수정할 수 있는 기능을 제공합니다.

<br></br><br></br>

## 2-5. Chat

![chat](https://github.com/user-attachments/assets/3dd47d72-8919-4cb1-a2e3-a8988aedf5d0)

Chat은 크게 채팅방 리스트와 채팅 화면으로 나뉘어져 있습니다.


> ## 2-5-1. ChatList

ChatList의 경우 채팅방 List들을 표시하는 것으로 ChatListTabViewController에서 ChatListTableViewCell에 정의한 구조를 기반으로 채팅방을 구조화합니다.

ChatList에는 현재 참여하고 있는 채팅방들이 나열됩니다.

<br></br>

> ## 2-5-2. ChattingView

ChattingView의 경우 ChatList에서 표시하는 Table에 해당하는 채팅방을 선택하면 입장하게 되는 채팅창입니다.

MessageKit라이브러리를 이용하여 제작하였으며 해당 라이브러리를 이용할 경우 UI는 자동으로 생성되고 기능적 설계만 하면 됩니다.

Message struct로 메시지에 대한 구조체를 생성합니다.

Sender struct로 채팅방 참여자에 대한 구조체를 생성합니다.

이에 대한 주 작업 파일은 ChattingViewController로 해당 controller가 MessageViewController를 상속하며 수행됩니다.

기능적 설계에 대한 자세한 내용은 항목 3-4 Chatting System을 참조해주시길 바랍니다.

<br></br>

## 2-6. Setting

TabBar에서 Settomg을 선택하게 되면 해당 Navigation Controller에 연결된 SettingTableViewController가 제일 먼저 나오게 됩니다.

![setting](https://github.com/user-attachments/assets/c316f716-2f35-4cc1-a3fc-b5366567e15b)

Setting 화면에서 상단에는 해당 유저의 프로필이 나오게 되며 프로필 변경하기 버튼을 누르게 되면 SettingProfileViewController로 전환되며 유저 정보를 수정할 수 있는 서비스를 제공합니다.

Setting 화면에서 유저 프로필 하단에는 TableView 형식으로 다양한 서비스를 제공하고 있습니다.

서비스 항목으로는 출석체크, 문의하기, 서비스 이용약관, 개인정보 취급방침, 버전정보, 로그아웃, 탈퇴하기 기능이 있습니다.

Swift의 tableView에서 각 셀 선택시 view를 전환하는 방법에 대해서는 본인 블로그인 [XCODE tableview에 segue 여러개 연결하여 view controller 여러개 사용하기](https://pinlib.tistory.com/entry/XCODE-tableview에-segue-여러개-연결하여-view-controller-여러개-사용하기) 해당 게시물에 작성하였으니 참고해주세요.

출석체크의 경우 alert형식으로 진행되며, 오늘 하루 로그인 내역이 없다면, 당일 최초 로그인 시 글을 작성할 수 있는 point를 제공합니다.

문의하기와 버전정보, 로그아웃, 탈퇴하기 역시 alert형식으로 서비스를 제공합니다.

Swift의 tableView에서 각 셀 선택시 alert View로 제공하는 기능은 본인 블로그인 [xcode에서 swift를 이용하여 tableView에서 alert기능(팝업메시지) 구현하기](https://pinlib.tistory.com/entry/xcode에서-swift를-이용하여-tableView에서-alert기능팝업메시지-구현하기) 해당 게시물에 작성하였으니 참고해주세요.

서비스 이용약관과 개인정보 취급방침의 경우 WebKit라이브러리를 이용하여 본인 블로그에 작성한 게시물이 web view 형식으로 나오게 제작하였습니다.


<br></br>

# 3. 기능 구현

## 3-1. Database

Database의 경우 AWS Amplify에서 권장하는 graphql을 이용하여 제작하였습니다.

저의 데이터 베이스 구조도의 경우 아래와 같습니다.

![Luvky_DB](https://github.com/user-attachments/assets/9968ac1a-560d-4b9e-aedf-ffbc61aa65e9)


이미 만든 graphql의 수정방법에 대해서는 본인 블로그인 [ios에서 AWS Amplify를 사용할 때 GraphQL 수정방법](https://pinlib.tistory.com/entry/ios%EC%97%90%EC%84%9C-AWS-Amplify%EB%A5%BC-%EC%82%AC%EC%9A%A9%ED%95%A0-%EB%95%8C-GraphQL-%EC%88%98%EC%A0%95%EB%B0%A9%EB%B2%95) 해당 게시물에 작성하였으니 참고해주세요.

<br></br>

## 3-2. AWS Amplify CRUD

Luvky의 경우 AWS Amplify를 서버로 사용하였습니다.

SWIFT에서 AWS Amplify를 이용해 CRUD를 구현하는 방법은 본인 블로그인 [[SWIFT] IOS 에서 AWS Amplify를 이용해 CRUD 구현하기](https://pinlib.tistory.com/entry/amplify1) 해당 게시물에 작성하였으니 참조해주세요.

SWIFT에서 AWS S3를 이용하여 image를 upload & download하는 방법의 경우 아래의 본인 블로그링크 참조 부탁드립니다.

1. 이론편 [ios에서 AWS Amplify S3를 이용하여 image upload, download하기](https://pinlib.tistory.com/entry/ios%EC%97%90%EC%84%9C-AWS-Amplify-S3%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%98%EC%97%AC-image-upload-download%ED%95%98%EA%B8%B0)

2. 실습예제 [[SWIFT] IOS에서 AWS Amplify를 이용해 이미지 저장과 불러오기(S3 storage)](https://pinlib.tistory.com/entry/amplify2)

<br></br>

# 3-3. Kakao Login with AWS Amplify

Luvky의 경우 항목 2-2 Auth에서도 언급했지만 Kakao Login 서비스를 제공하고 있습니다.

Kakao Login의 경우 Kakao Developer에서 제공하는 api를 이용하여 제작하였습니다.

![스크린샷 2024-10-06 오전 12 14 12](https://github.com/user-attachments/assets/b1a004d1-cbdc-44e2-9493-96a0aa73af44)

해당 기술에 대한 내용은 제가 블로그에 작성했던 [[SWIFT] IOS에서 카카오 로그인 구현하기 with AWS Amplify](https://pinlib.tistory.com/entry/amplify3) 해당 게시물을 참고 부탁드립니다.

<br></br>

# 3-4. Chatting System 

Chatting System의 경우 AWS Amplify를 서버로 구현하였습니다.

해당 기술에 대한 내용은 아래의 본인 블로그링크 참조 부탁드립니다.

1편 [[SWIFT] IOS에서 채팅기능 구현하기(1) with AWS Amplify](https://pinlib.tistory.com/entry/amplify4)

2편 [[SWIFT] IOS에서 채팅기능 구현하기(2) with AWS Amplify](https://pinlib.tistory.com/entry/amplify5)

3편 [[SWIFT] IOS에서 채팅기능 구현하기(3) with AWS Amplify](https://pinlib.tistory.com/entry/amplify6)

   




