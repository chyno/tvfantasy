module Model exposing (..)

import Loading exposing (LoadingState)
import Http
import Json.Decode as D
-- exposing (Decoder, map2, field, string, int, list)

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
    --   country: String,
      overview: String,
      firstAirDate: String,
      voteAverage: Float
      
    }

showDecoder : D.Decoder ShowInfo
showDecoder =
    D.map4
        ShowInfo
        (D.field "name" D.string)
        -- (D.field "country" D.string))
        (D.field "overview" D.string)
        (D.field "first_air_date" D.string)
        (D.field "vote_average" D.float)
-- field "data" (field "image_url" string)

listOfShowsDecoder : D.Decoder (List ShowInfo)
listOfShowsDecoder =
   D.field "results" (D.list showDecoder)
    -- D.list showDecoder

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


type Msg
    = TabNavigate ActiveLoginTab
    | DoneLogin LoginResultInfo
    | UpdateUserName String
    | UpdatePassword String
    | UpdateNewPassword String
    | UpdateNewConfirmPassword String
    | StartLoginOrCancel
    | Logout
    | RegisterUser
    | InitShows 
    | GotShows (Result Http.Error (List ShowInfo))
    -- | ShowResults (List ShowInfo)
    
   
