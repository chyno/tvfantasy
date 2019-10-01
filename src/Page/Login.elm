port module Page.Login exposing (subscriptions, LoginResultInfo, Model, Msg(..), view, init, update)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Browser.Navigation as Nav exposing (Key)
import Http exposing (..)
import Shared exposing (..)
import Routes exposing (gamePath)
import Json.Encode as E
import Loading
    exposing
        ( LoaderType(..)
        , LoadingState
        , defaultConfig
        , render
        )




init : Key ->  ( Model, Cmd Msg )
init key  =
    ( { navKey = key
        ,loginResult =
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
    }, Cmd.none) 

tabClassString : Model -> ActiveLoginTab ->  String
tabClassString model tab =
    if model.activeTab == tab then
        "is-active"
    else
        ""

-- Model
type alias LoginResultInfo =
    { isLoggedIn : Bool
    , address : String
    , message : String
    }

type alias Model =
    { userInfo : UserInfo
    , loginResult : LoginResultInfo
    , activeTab : ActiveLoginTab
    , loadState : LoadingState
    , navKey : Key
    }
type alias UserInfo =
    { userName : String
    , password : String
    , passwordConfimation : String
    }

type ActiveLoginTab
    = CreateAccountTab
    | LoggingInTab



-- Message
type Msg
    = TabNavigate ActiveLoginTab
    | UpdateUserName String
    | UpdatePassword String
    | UpdateNewPassword String
    | UpdateNewConfirmPassword String
    | StartLoginOrCancel
    | RegisterUser
    | DoneLogin LoginResultInfo
    


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





-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [hedgeHogloginResult DoneLogin]


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
        DoneLogin data ->
            case data.isLoggedIn of
                True ->
                    Debug.log "Success  .."
                    (model, (Nav.pushUrl model.navKey  Routes.gamePath) )
                      
                False ->
                    Debug.log "Fail  .."
                    ( { model
                    | loginResult =
                        { isLoggedIn = False
                        , address = "-"
                        , message = data.message
                        }
                    , loadState = Loading.Off
                  } , Cmd.none ) 
            


loginView : Model -> Html Msg
loginView model =
    div []
    [ 
        div [ class "field" ]
        [ label [ class "label" ]
            [ text "Username" ]
        , div [ class "control has-icons-left has-icons-right" ]
            [ input [ class "input is-success", placeholder "User Name", type_ "text", onInput UpdateUserName, value model.userInfo.userName ]
                []
            , span [ class "icon is-small is-left" ]
                [ i [ class "fas fa-user" ]
                    []
                ]
            , span [ class "icon is-small is-right" ]
                [ i [ class "fas fa-check" ]
                    []
                ]
            ]
        -- , p [ class "help is-success" ]
        --     [ text "This username is available" ]
        ]
    , div [ class "field" ]
        [ label [ class "label" ]
            [ text "Password" ]
        , div [ class "control has-icons-left has-icons-right" ]
            [ input [ class "input", placeholder "Password input", type_ "password", onInput UpdatePassword, value model.userInfo.password ]
                []
            , span [ class "icon is-small is-left" ]
                [ i [ class "fas fa-envelope" ]
                    []
                ]
            , span [ class "icon is-small is-right" ]
                [ i [ class "fas fa-exclamation-triangle" ]
                    []
                ]
            ]
        -- , p [ class "help is-danger" ]
        --     [ text "This password is invalid" ]
        ]
    , div [ class "field is-grouped" ]
        [ div [ class "control" ]
            [ button [ class "button is-link", onClick StartLoginOrCancel ]
                [ text "Log in " ]
            ]
        , div [ class "control" ]
            [ button [ class "button is-text" ]
                [ text "Cancel" ]
            ]
        ]
    ]

    
    -- let
    --     buttonText =
    --         if model.loadState == Loading.Off then
    --             "Login"
    --         else
    --             "Cancel"
    -- in
    -- div [ class "content" ]
    --     [ div [ class "form" ]
    --         [ div [ class "fields" ]
    --             [ input [ placeholder "Username", onInput UpdateUserName, value model.userInfo.userName ]
    --                 []
    --             , div []
    --                 [ input [ placeholder "Password", type_ "password", onInput UpdatePassword, value model.userInfo.password ]
    --                     []
    --                 , p [ class "error" ]
    --                     []
    --                 ]
    --             ]
    --         , div [ class "buttons" ]
    --             [ button [ onClick StartLoginOrCancel ]
    --                 [ text buttonText ]
    --             , button [ class "link", onClick (TabNavigate CreateAccountTab) ]
    --                 [ span []
    --                     [ text "Create Account" ]
    --                 ]
    --             ]
    --         ]
    --     ]


-- View
view : Model -> Html Msg
view model =
   div []
        [ (contentView model)
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


contentView : Model -> Html Msg
contentView model =
    div [class "columns"]
        [
            div [class "column is-2"] [ 
                case model.activeTab of
                    CreateAccountTab ->
                        div[][text "create account dec"]
                    LoggingInTab ->
                        div[][text "logging in desc"]
            ]
            , div [class "column is-10"][
               div [ class "tabs" ]
    [ ul []
        [ li [class (tabClassString model LoggingInTab) ]
            [ a[ onClick(TabNavigate LoggingInTab), href "#"]
                [ text "Login" ]
            ]
        , li [ class (tabClassString model CreateAccountTab)]
            [ a [onClick (TabNavigate CreateAccountTab), href "#"]
                [ text "Create An Account" ]
            ]  
        ]
    ]
    , div [class "content"] [
        case model.activeTab of
            CreateAccountTab ->
                createAccountView model
            LoggingInTab ->
                loginView model
    ] 
            ]
        ]
   

    -- div [ id "root" ]
    --     [ div [ class "app" ]
    --         [ div [ class "tabs" ]
    --             [ ul [ class "headers" ]
    --                 [ li
    --                     [ class
    --                         (tabClassString model CreateAccountTab)
    --                     , onClick (TabNavigate CreateAccountTab)
    --                     ]
    --                     [ text "Create Account" ]
    --                 , li
    --                     [ class (tabClassString model LoggingInTab)
    --                     , onClick (TabNavigate LoggingInTab)
    --                     ]
    --                     [ text "Log In" ]
    --                 ]
    --             , case model.activeTab of
    --                 CreateAccountTab ->
    --                     createAccountView model

    --                 LoggingInTab ->
    --                     loginView model
    --             ]
    --         , div [ class "message unauthenticated" ]
    --             [ div [ class "pill red" ]
    --                 [ text "unauthenticated" ]
    --             , h1 []
    --                 [ text "You're Not Signed In" ]
    --             , p []
    --                 [ text "You are currently unauthenticated / signed out." ]
    --             , p []
    --                 [ text "Go ahead and create an account just like you would a centralized service." ]
    --             ]
    --         ]
    --     ]


port registerUser : UserInfo -> Cmd msg
port loginUser : UserInfo -> Cmd msg
port hedgeHogloginResult : (LoginResultInfo -> msg) -> Sub msg