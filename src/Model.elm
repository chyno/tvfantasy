module Model exposing (..)

import Loading exposing (LoadingState)


type alias Model =
    { userInfo : UserInfo
    , loginResult : LoginResultInfo
    , activeTab : ActiveLoginTab
    , activePage : ActivePage
    , loadState : LoadingState
    , showInfos : List ShowInfo
    }


type alias ShowInfo =
    { 
      name: String,
      country: String,
      overview: String,
      firstAirDate: String,
      voteAverage: Float
      
    }


type alias LoginResultInfo =
    { isLoggedIn : Bool
    , address : String
    , message : String
    }


type alias UserInfo =
    { userName : String
    , password : String
    , passwordConfimation : String
    }


type ActiveLoginTab
    = CreateAccountTab
    | LoggingInTab
    | LoggedInTab


type ActivePage
    = LoginPage
    | ShowsPage


type Msg
    = PageNavigate ActivePage
    | TabNavigate ActiveLoginTab
    | DoneLogin LoginResultInfo
    | UpdateUserName String
    | UpdatePassword String
    | UpdateNewPassword String
    | UpdateNewConfirmPassword String
    | StartLoginOrCancel
    | Logout
    | RegisterUser
   
