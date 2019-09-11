port module Login exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Json.Encode as E
import Loading
    exposing
        ( LoaderType(..)
        , LoadingState
        , defaultConfig
        , render
        )
import Model exposing (..)


tabClassString : Model -> ActiveLoginTab -> String
tabClassString model tab =
    if model.activeTab == tab then
        "tab active"

    else
        "tab"


updateTab : ActiveLoginTab -> Model -> ( Model, Cmd Msg )
updateTab msg model =
    case msg of
        LoggingInTab ->
            ( { model
                | activeTab = LoggingInTab
                , userInfo =
                    { userName = ""
                    , password = ""
                    , passwordConfimation = ""
                    }
              }
            , Cmd.none
            )

        CreateAccountTab ->
            ( { model
                | activeTab = CreateAccountTab
                , userInfo =
                    { userName = ""
                    , password = ""
                    , passwordConfimation = ""
                    }
              }
            , Cmd.none
            )


headersView : Model -> Html Msg
headersView model =
    div [ id "root" ]
        [ div [ class "app" ]
            [ div [ class "tabs" ]
                [ div [ class "headers" ]
                    [ div
                        [ class
                            (tabClassString model CreateAccountTab)
                        , onClick (TabNavigate CreateAccountTab)
                        ]
                        [ text "Create Account" ]
                    , div
                        [ class (tabClassString model LoggingInTab)
                        , onClick (TabNavigate LoggingInTab)
                        ]
                        [ text "Log In" ]
                    ]
                , case model.activeTab of
                    CreateAccountTab ->
                        createAccountView model

                    LoggingInTab ->
                        loginView model
                ]
            , div [ class "message unauthenticated" ]
                [ div [ class "pill red" ]
                    [ text "unauthenticated" ]
                , h1 []
                    [ text "You're Not Signed In" ]
                , p []
                    [ text "You are currently unauthenticated / signed out." ]
                , p []
                    [ text "Go ahead and create an account just like you would a centralized service." ]
                ]
            ]
        ]


type Msg
    = TabNavigate ActiveLoginTab
    | UpdateUserName String
    | UpdatePassword String
    | UpdateNewPassword String
    | UpdateNewConfirmPassword String
    | StartLoginOrCancel
    | RegisterUser
    

-- Model
-- Auth Model


 

type alias Model =
    { userInfo : UserInfo
    , loginResult: Model.LoginResultInfo
    , activeTab : ActiveLoginTab
    , loadState : LoadingState
    }





type alias UserInfo =
    { userName : String
    , password : String
    , passwordConfimation : String
    }


type ActiveLoginTab
    = CreateAccountTab
    | LoggingInTab



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
    


-- toMsgNoParams: LoginMsg -> Msg
-- toMsgNoParams subMsg   =
--   GotLoginMsg subMsg


createAccountView : Model -> Html Msg
createAccountView model =
    div [ class "content" ]
        [ div [ class "form" ]
            [ div [ class "fields" ]
                [ input [ placeholder "Username", onInput UpdateUserName, value model.userInfo.userName ]
                    []
                , input [ placeholder "Password", type_ "password", onInput UpdateNewPassword, value model.userInfo.password ]
                    []
                , div []
                    [ input [ placeholder "Confirm Password", type_ "password", onInput UpdateNewConfirmPassword, value model.userInfo.passwordConfimation ]
                        []
                    , p [ class "error" ]
                        []
                    ]
                ]
            , div [ class "buttons", onClick RegisterUser ]
                [ div [ class "button fullWidth" ]
                    [ text "Create My Account" ]
                , div [ class "link", onClick (TabNavigate LoggingInTab) ]
                    [ span []
                        [ text "I already have an account." ]
                    ]
                ]
            ]
        ]



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        
        TabNavigate tab ->
            updateTab tab model

        
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
                ( { model | loadState = Loading.Off }, Cmd.none )

        RegisterUser ->
            ( model, registerUser model.userInfo )






loginView : Model -> Html Msg
loginView model =
    let
        buttonText =
            if model.loadState == Loading.Off then
                "Login"

            else
                "Cancel"
    in
    div [ class "content" ]
        [ div [ class "form" ]
            [ div [ class "fields" ]
                [ input [ placeholder "Username", onInput UpdateUserName, value model.userInfo.userName ]
                    []
                , div []
                    [ input [ placeholder "Password", type_ "password", onInput UpdatePassword, value model.userInfo.password ]
                        []
                    , p [ class "error" ]
                        []
                    ]
                ]
            , div [ class "buttons" ]
                [ div [ class "button fullWidth", onClick StartLoginOrCancel ]
                    [ text buttonText ]
                , div [ class "link", onClick (TabNavigate CreateAccountTab) ]
                    [ span []
                        [ text "Create Account" ]
                    ]
                ]
            ]
        ]


tabView : Model -> Html Msg
tabView model =
    let
        vw =
            case model.activeTab of
                CreateAccountTab ->
                    headersView model

                LoggingInTab ->
                    headersView model
    in
    div []
        [ vw
        , div []
            [ Loading.render
                Spinner
                -- LoaderType
                { defaultConfig | color = "#333" }
                -- Config
                model.loadState

            -- LoadingState
            ]
        , div [] [ text model.loginResult.message ]
        ]


port registerUser : UserInfo -> Cmd msg

port loginUser : UserInfo -> Cmd msg



-- Incoming Ports


