module  Model exposing(..)

type alias Model =
  {
    userInfo : UserInfo,
    loginResult: LoginResultInfo,
    activeTab: ActiveLoginTab,
    activePage: ActivePage
  }

type alias ShowInfo =
  {
    name: String,
    description: String
  }

type alias LoginResultInfo =
  {
     isLoggedIn : Bool
    , address: String
    , message: String
    , showInfos: List ShowInfo
  }

type alias UserInfo =
  {
    userName : String,
    password: String,
    passwordConfimation: String
  }

type ActiveLoginTab =  CreateAccountTab
                       | LoggingInTab
                       | LoggedInTab

type ActivePage =  LoginPage  
                   | ShowsPage 

type Msg = PageNavigate ActivePage
            | TabNavigate ActiveLoginTab
            |   SuccessLogin LoginResultInfo
            |   UpdateUserName String
            |   UpdatePassword String
            |   UpdateNewPassword String
            |   UpdateNewConfirmPassword String
            |   StartLogin
            |   Logout
            |   RegisterUser
    
 