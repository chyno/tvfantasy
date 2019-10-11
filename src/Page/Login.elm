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

import Material.TabBar as TabBar
import Material
import Material.Options as Options
import Material.TextField as TextField
import Material.FormField as FormField


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
    , activeTab = 0
    , loadState = Loading.Off
    ,  mdc = Material.defaultModel
    }, Material.init Mdc) 



-- Model
type alias LoginResultInfo =
    { isLoggedIn : Bool
    , address : String
    , message : String
    }

type alias Model =
    { userInfo : UserInfo
    , loginResult : LoginResultInfo
    , activeTab : Int
    , loadState : LoadingState
    , navKey : Key
    , mdc : Material.Model Msg
    }
type alias UserInfo =
    { userName : String
    , password : String
    , passwordConfimation : String
    }


-- Message
type Msg
    = TabNavigate Int
    | UpdateUserName String
    | UpdatePassword String
    | UpdateNewPassword String
    | UpdateNewConfirmPassword String
    | StartLoginOrCancel
    | RegisterUser
    | DoneLogin LoginResultInfo
    | Mdc (Material.Msg Msg)

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [hedgeHogloginResult DoneLogin]

createAccountView : Model -> Html Msg
createAccountView model =
     div []
    [ 
        h3[][text "Enter Login"]
        , div [class "conent-wrapper"][
            FormField.view []
            [ 
                TextField.view Mdc "username-field" model.mdc
                [ TextField.label "User Name"
                , Options.onChange UpdateUserName
                , TextField.value model.userInfo.userName
                ]
                []
                ,  TextField.view Mdc "password-field" model.mdc
                [ TextField.label "Password"
                , Options.onChange UpdateNewPassword
                , TextField.type_ "password"
                , TextField.value model.userInfo.password
                ]
                []
                , TextField.view Mdc "passwordconfirm-field" model.mdc
                [ TextField.label "Password"
                , Options.onChange UpdateNewConfirmPassword
                , TextField.type_ "password"
                , TextField.value model.userInfo.passwordConfimation
                ]
                []

            ]
            , div   [ class "button-container" ]
                    [   button [ class "mdc-button mdc-button--raised next", onClick  RegisterUser ] [ span [ class "mdc-button__label" ] [ text "Create My Account      " ]]
                        , button [ class "mdc-button cancel", type_ "button", onClick (TabNavigate 0) ] [ span [ class "mdc-button__label" ] [ text "I already have an account." ] ]
                    ]
        ]
    ]



-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdc msg_ ->
            Material.update Mdc msg_ model
        TabNavigate tabIndex ->
             ( { model | activeTab = tabIndex }, Cmd.none )

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
                    (model, (Nav.pushUrl model.navKey  (Routes.gamePathLogin model.userInfo.userName)) )
                      
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
        h3[][text "Enter Login"]
        , div [class "conent-wrapper"][
            FormField.view []
            [ 
                TextField.view Mdc "username-field" model.mdc
                [ TextField.label "User Name"
                , Options.onChange UpdateUserName
                , TextField.value model.userInfo.userName
                ]
                []

            ]
            , FormField.view []
            [ 
                TextField.view Mdc "password-field" model.mdc
                [ TextField.label "Password"
                , Options.onChange UpdatePassword
                , TextField.type_ "password"
                , TextField.value model.userInfo.password
                ]
                []

            ] 
            , div   [ class "button-container" ]
                    [   button [ class "mdc-button mdc-button--raised next", onClick StartLoginOrCancel ] [ span [ class "mdc-button__label" ] [ text "Login        " ]]
                        , button [ class "mdc-button cancel", type_ "button" ] [ span [ class "mdc-button__label" ] [ text "Cancel        " ] ]
                    ]
        ]
    ]

    
  
-- View
view : Model -> Html Msg
view model =
    let
        contentView =
            case model.activeTab of
                0 ->
                    loginView model
                1 ->
                    createAccountView model
                _ ->
                    loginView model
    in

    div []
    [
        TabBar.view Mdc "my-tab-bar" model.mdc
            [ TabBar.activeTab model.activeTab]
            [ TabBar.tab [Options.onClick (TabNavigate 0)] [ text "Login" ]
            , TabBar.tab [Options.onClick (TabNavigate 1)] [ text "Create an Account" ]
            ]
        , contentView
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
port hedgeHogloginResult : (LoginResultInfo -> msg) -> Sub msg