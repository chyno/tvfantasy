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
import Subscriptions exposing (..)

init : String -> ( Model, Cmd Msg )
init flag =
    ( initdata, Cmd.none )


initdata : Model
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
    , activePage = LoginPage
    , loadState = Loading.Off
    , showInfos = []
    }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TabNavigate tab ->
            updateTab tab model

        PageNavigate page ->
            updatePage page model

        DoneLogin data ->
            case data.isLoggedIn of
                True ->
                    ( { model
                        | loginResult = data
                        , activeTab = LoggedInTab
                        , activePage = ShowsPage
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
                , showInfos = []
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
            case model.activePage of
                LoginPage ->
                    tabView model
                ShowsPage ->
                    showsView model
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


port registerUser : UserInfo -> Cmd msg
port loginUser : UserInfo -> Cmd msg
port logoutUser : UserInfo -> Cmd msg
-- port startLoadShows : UserInfo -> Cmd msg
