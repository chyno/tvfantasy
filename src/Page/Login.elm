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
    }, Cmd.none) 



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
  

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [hedgeHogloginResult DoneLogin]

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
                , div [ class "link", onClick (TabNavigate 0) ]
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
            , div[][
                Button.button [ Button.primary,  Button.onClick StartLoginOrCancel ] [ text "Login" ]
                , Button.button [ Button.secondary ] [ text "Cancel" ]
            ]
        ]
    -- div [ class "field" ]
    --     [ label [ class "label" ]
    --         [ text "Username" ]
    --     , div [ class "control has-icons-left has-icons-right" ]
    --         [ input [ class "input is-success", placeholder "User Name", type_ "text", onInput UpdateUserName, value model.userInfo.userName ]
    --             []
    --         , span [ class "icon is-small is-left" ]
    --             [ i [ class "fas fa-user" ]
    --                 []
    --             ]
    --         , span [ class "icon is-small is-right" ]
    --             [ i [ class "fas fa-check" ]
    --                 []
    --             ]
    --         ]
    --     -- , p [ class "help is-success" ]
    --     --     [ text "This username is available" ]
    --     ]
    -- , div [ class "field" ]
    --     [ label [ class "label" ]
    --         [ text "Password" ]
    --     , div [ class "control has-icons-left has-icons-right" ]
    --         [ input [ class "input", placeholder "Password input", type_ "password", onInput UpdatePassword, value model.userInfo.password ]
    --             []
    --         , span [ class "icon is-small is-left" ]
    --             [ i [ class "fas fa-envelope" ]
    --                 []
    --             ]
    --         , span [ class "icon is-small is-right" ]
    --             [ i [ class "fas fa-exclamation-triangle" ]
    --                 []
    --             ]
    --         ]
    --     -- , p [ class "help is-danger" ]
    --     --     [ text "This password is invalid" ]
    --     ]



        -- , div [ class "field is-grouped" ]
        --     [ div [ class "control" ]
        --     [ button [ class "button is-link", onClick StartLoginOrCancel ]
        --         [ text "Log in " ]
        --     ]
        -- , div [ class "control" ]
        --     [ button [ class "button is-text" ]
        --         [ text "Cancel" ]
        --     ]
        -- ]
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
         contentView
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