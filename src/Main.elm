port module Main exposing (main)
import Route exposing (Route)
import Json.Decode as Decode exposing (Value)
import Browser
import Browser.Navigation as Nav
import Url exposing (Url)
import Html exposing (..)
import Browser exposing (Document)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as E
import Loading
    exposing
        ( LoaderType(..)
        , defaultConfig
        , render
        )
import Model exposing (..)
import Show exposing (..)
import Login exposing(..)



init : String -> ( Model, Cmd Msg )
init flag =
    let
        root = Auth initdata
    in 
        ( root, Cmd.none )

type Model
    = Auth AuthModel
    | Shows ShowsModel

initShowsData : ShowsModel
initShowsData = { showInfos = []}

initdata : AuthModel
initdata =
    { loginResult =
        { isLoggedIn = False
        , address = "-"
        , message = ""
        }
    , userInfo =
        { userName = ""
        , password = ""
        , passwordConfimation = ""
        }
    , activeTab = LoggingInTab
    , loadState = Loading.Off
    }

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [
        loginResult DoneLogin,
        showApiResults ShowResults 
    ]
    --  



-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case  model  of
        Auth amdl  ->
            loginUpdate msg amdl |> 
                    updateWith Auth    
        Shows smdl  -> 
            showUpdate msg smdl |>
                updateWith Shows 
        
                        
updateWith : (subModel -> Model)   -> ( subModel, Cmd Msg ) -> ( Model, Cmd Msg )
updateWith toModel   ( subModel, cmd ) =
    ( toModel subModel
    , cmd
    )
-- For update function
 
  

showUpdate : Msg -> ShowsModel -> ( ShowsModel, Cmd Msg )
showUpdate msg model =
    case msg of
        ShowResults shws ->
           ( { model | showInfos = shws }, Cmd.none)
        StartViewShows  -> 
            (initShowsData , startLoadShows "usrInfo")     
        _ ->  
            (model, Cmd.none)

        
-- (a -> msg) -> Cmd a -> Cmd msg
loginUpdate : Msg -> AuthModel -> ( AuthModel, Cmd Msg )
loginUpdate msg model =
    case msg of
        TabNavigate tab ->
            updateTab tab model          
        DoneLogin data ->
            case data.isLoggedIn of
                True ->
                    ( { model
                        | loginResult = data
                        , activeTab = LoggedInTab
                        , loadState = Loading.Off
                      }
                    , startLoadShows "model.userInfo"
                    )  

                False ->
                    ( { model
                        | loginResult = data
                        , loadState = Loading.Off
                      }
                    , startLoadShows "should be command none"
                    ) 

        UpdateNewConfirmPassword pswd ->
            let
                li =
                    model.userInfo
            in
            ( { model | userInfo = { li | passwordConfimation = pswd } }, Cmd.none ) 

        UpdatePassword pswd ->
            let
                li =
                    model.userInfo
            in
            ( { model | userInfo = { li | password = pswd } }, Cmd.none ) 

        UpdateNewPassword pswd ->
            let
                li =
                    model.userInfo
            in
            ( { model | userInfo = { li | password = pswd } }, Cmd.none ) 

        UpdateUserName usrname ->
            let
                li =
                    model.userInfo
            in
            ( { model | userInfo = { li | userName = usrname } }, Cmd.none ) 

        StartLoginOrCancel ->
          if model.loadState == Loading.Off then 
            ( { model
                | loginResult =
                    { isLoggedIn = False
                    , address = "-"
                    , message = ""
                    }
                , loadState = Loading.On
                 
              }
            , loginUser model.userInfo
            ) 
            else
              ({ model | loadState = Loading.Off } , Cmd.none )  

        Logout ->
            ( initdata, logoutUser model.userInfo ) 

        RegisterUser ->
            ( model, registerUser model.userInfo )         
        _ ->
           (model, Cmd.none)  

view : Model -> Html Msg
view model =
    let
        toView mdl =
            case mdl of
                Shows smdl->
                    showsView smdl                   
                Auth amdl ->
                    tabView amdl
    in
    div [ id "root" ]
        [ div [ class "app" ]
            [ model |> toView    ]
        ]

-- main : Program Value Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }

-- Outgoing ports
port registerUser : UserInfo -> Cmd msg
port loginUser : UserInfo -> Cmd msg
port logoutUser : UserInfo -> Cmd msg
port startLoadShows : String -> Cmd msg

-- Incoming Ports
port loginResult : (LoginResultInfo -> msg) -> Sub msg
port showApiResults : ((List ShowInfo) -> msg) -> Sub msg