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

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Button as Button
import Bootstrap.Navbar as Navbar

init : Key ->  ( Model, Cmd Msg )
init key  =
    let
        ( navbarState, navbarCmd ) = Navbar.initialState NavbarMsg
    in
    
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
        , navbarState = navbarState
        }, navbarCmd) 



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
    , navbarState : Navbar.State
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
    | NavbarMsg Navbar.State

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [hedgeHogloginResult DoneLogin, Navbar.subscriptions model.navbarState NavbarMsg]

createAccountView : Model -> Html Msg
createAccountView model =
     div []
    [ 
        Form.form []
        [   Form.group []
                [ Form.label [for "myusername"] [ text "Username"]
                , Input.text [ Input.id "myusername", Input.onInput UpdateUserName, Input.value model.userInfo.userName ]
                , Form.help [] [ text "Enter User Name" ]
                ]
            
            , Form.group []
                [ Form.label [for "mypwd"] [ text "Password"]
                , Input.password [ Input.id "mypwd", Input.onInput UpdateNewPassword, Input.value model.userInfo.password ]
                ]
            , Form.group []
                [ Form.label [for "mypwdconfirm"] [ text "Confirm Password"]
                , Input.password [ Input.id "mypwdconfirm", Input.onInput UpdateNewConfirmPassword, Input.value model.userInfo.passwordConfimation ]
                ]
            
        ]
        , div[class "button-group"][
                Button.button [ Button.primary,  Button.onClick RegisterUser ] [ text "Create my Account" ]
                , Button.button [ Button.secondary, Button.onClick (TabNavigate 0) ] [ text "Cancel" ]
            ]
    ]



-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )
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
        Form.form []
        [   Form.group []
                [ Form.label [for "myusername"] [ text "Username"]
                , Input.text [ Input.id "myusername", Input.onInput UpdateUserName, Input.value model.userInfo.userName ]
                , Form.help [] [ text "Enter User Name" ]
                ]
            
            , Form.group []
                [ Form.label [for "mypwd"] [ text "Password"]
                , Input.password [ Input.id "mypwd", Input.onInput UpdatePassword, Input.value model.userInfo.password ]
                ]
            
        ]
        , div[class "button-group"][
                Button.button [ Button.primary,  Button.onClick StartLoginOrCancel ] [ text "Login" ]
                , Button.button [ Button.secondary ] [ text "Cancel" ]
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
        Navbar.config NavbarMsg
        |> Navbar.withAnimation
        |> Navbar.light 
        |> Navbar.items
            [ Navbar.itemLinkActive [ href "#",  onClick (TabNavigate 0)  ] [ text "Login" ]
            , Navbar.itemLink [ href "#",  onClick (TabNavigate 1) ] [ text "Create Account" ]
            ]
        |> Navbar.view model.navbarState
        
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