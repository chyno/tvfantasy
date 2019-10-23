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
import Bootstrap.Tab as Tab
import Bootstrap.Utilities.Spacing as Spacing

init : Key ->  ( Model, Cmd Msg )
init key  =
    (   { navKey = key
            ,loginResult =
            { isLoggedIn = False
            , address = "-"
            , message = ""
            , userId = 0
            }
        , userInfo =
            { userName = ""
            , password = ""
            , passwordConfimation = ""
            }
        , activeTab = 0
        , loadState = Loading.Off
        , tabState = Tab.initialState
        }, Cmd.none
    ) 


-- Model
type alias LoginResultInfo =
    { isLoggedIn : Bool
    , address : String
    , message : String
    , userId : Int
    }

type alias Model =
    { userInfo : UserInfo
    , loginResult : LoginResultInfo
    , activeTab : Int
    , loadState : LoadingState
    , navKey : Key
    , tabState : Tab.State
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
    | TabMsg Tab.State

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [hedgeHogloginResult DoneLogin]

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
                , Form.help [] [ text "Enter Password" ]
                ]
            , Form.group []
                [ Form.label [for "mypwdconfirm"] [ text "Confirm Password"]
                , Input.password [ Input.id "mypwdconfirm", Input.onInput UpdateNewConfirmPassword, Input.value model.userInfo.passwordConfimation ]
                , Form.help [] [ text "Enter Password again" ]
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
        TabMsg state ->
            ( { model | tabState = state }
            , Cmd.none
            )
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
                        , userId = 0
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
                    (model, (Nav.pushUrl model.navKey  (Routes.gamePathLogin data.userId)) )
                      
                False ->
                    Debug.log "Fail  .."
                    ( { model
                    | loginResult =
                        { isLoggedIn = False
                        , address = "-"
                        , message = data.message
                        , userId = 0
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
                , Form.help [] [ text "Enter Password" ]
                ]
            
        ]
        , div[class "button-group"][
                Button.button [ Button.primary,  Button.onClick StartLoginOrCancel ] [ text "Login" ]
                , Button.button [ Button.secondary ] [ text "Cancel" ]
            ]
    ]

    
 -- Todo : http://elm-bootstrap.info/tab 
-- View
view : Model -> Html Msg
view model =
    div []
    [
        Tab.config TabMsg
            |> Tab.items
                [ Tab.item
                    { id = "tabLogin"
                    , link = Tab.link [] [ text "Log In" ]
                    , pane =
                        Tab.pane [ Spacing.mt3 ]
                            [  loginView model]
                    }
                , Tab.item
                    { id = "tabCreateUser"
                    , link = Tab.link [] [ text "Create User" ]
                    , pane =
                        Tab.pane [ Spacing.mt3 ]
                            [ createAccountView model]
                    }
                ]
            |> Tab.view model.tabState
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