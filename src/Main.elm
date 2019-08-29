port module Main exposing (main)

import Browser
import Html exposing (..)
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
    loginResult DoneLogin




-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case model of
        Shows smdl ->
            showUpdate msg smdl |> useModel Shows
        Auth amdl ->
            loginUpdate msg amdl |> useModel Auth

    

useModel: (subModel -> Model) -> ( subModel, Cmd Msg ) -> ( Model, Cmd Msg )
useModel toModel (subModel, cmd)  = 
  ((toModel subModel), cmd)

showUpdate : Msg -> ShowsModel -> ( ShowsModel, Cmd Msg )
showUpdate msg model =
   (model, Cmd.none)

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
                    , Cmd.none
                    )

                False ->
                    ( { model
                        | loginResult = data
                        , loadState = Loading.Off
                      }
                    , Cmd.none
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



 

view : Model -> Html Msg
view model =
    let
        vw =
            case model of
                Shows mdl->
                    showsView mdl         
                Auth mdl ->
                    tabView mdl 
                    
    in
    div [ id "root" ]
        [ div [ class "app" ]
            [ vw ]
        ]

main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }

port loginResult : (LoginResultInfo -> msg) -> Sub msg
port registerUser : UserInfo -> Cmd msg
port loginUser : UserInfo -> Cmd msg
port logoutUser : UserInfo -> Cmd msg


-- port startLoadShows : UserInfo -> Cmd msg
--  port showResults : (List ShowInfo -> msg) -> Sub msg