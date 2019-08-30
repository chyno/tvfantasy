module Model exposing (..)

import Loading exposing (LoadingState)


type alias AuthModel =
    { userInfo : UserInfo
    , loginResult : LoginResultInfo
    , activeTab : ActiveLoginTab
    , loadState : LoadingState
    }

type alias ShowsModel =
    { 
     showInfos : List ShowInfo
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

type Msg
    = GotLoginMsg LoginMsg 
    | GotShowMsg ShowMsg


type LoginMsg
    = TabNavigate ActiveLoginTab
    | DoneLogin LoginResultInfo
    | UpdateUserName String
    | UpdatePassword String
    | UpdateNewPassword String
    | UpdateNewConfirmPassword String
    | StartLoginOrCancel
    | Logout
    | RegisterUser

type ShowMsg
    =  ShowResults  --(List ShowInfo)
         
   
