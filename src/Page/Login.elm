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
import Api.Mutation as Mutation
import Graphql.Document as Document
import Graphql.Http
import Graphql.Operation exposing (RootMutation)
import Graphql.Internal.Builder.Object as Object
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Graphql.OptionalArgument exposing (..)

import Api.Object.User as User
import RemoteData exposing (RemoteData)
-- import Api.Object exposing (User)
import Api.Query as Query
import Api.Object
import Api.Scalar
import Api.Scalar exposing (Id(..))
import Api.Mutation exposing (CreateUserRequiredArguments, createUser)
import Json.Decode as Decode exposing (Decoder)
import Api.InputObject exposing (..)
import Api.ScalarCodecs


type alias Response =
    {
        id : Id
    }

-- Model
type alias LoginResultInfo =
    { isLoggedIn : Bool
    , address : String
    , message : String
    }

type alias CreateUserResultInfo =
    {
         isCreated: Bool
        , message: String
    }

type alias Model =
    { username : String
    , password : String
    , walletAddress : String
    , message : String
    , passwordConfimation : String
    , activeTab : Int
    , loadState : LoadingState
    , navKey : Key
    , tabState : Tab.State
    , userId : Maybe String
    }

type alias UserInfo =
    { username : String
    , password : String
    }

type alias UserIdUpdate =
    { username : String
    , id : String
    }

-- End Model *****************************************

selectUser : SelectionSet Response Api.Object.User
selectUser =
    SelectionSet.map Response
            User.id_ 

                      
addUser : CreateUserRequiredArguments ->  SelectionSet Response Graphql.Operation.RootMutation
addUser args  =
    createUser args selectUser


getUserDataRaw : String -> String -> UserInputRaw
getUserDataRaw username walletAddress = 
     {
        username =  Id username
        , walletAddress = walletAddress
        , networks = Absent
        , amount = Absent
        , end = Absent
        , start = Absent          
        
    }


-- getMutArgs : String -> String -> CreateUserRequiredArguments
-- getMutArgs username walletAddress = 
--     { 
--         data =   (getUserDataRaw username walletAddress)
--     }


init : Key ->  ( Model, Cmd Msg )
init key  =
    (   {   navKey = key
            , walletAddress = ""
            , message = ""
            , username = ""
            , password = ""
            , passwordConfimation = ""
            , activeTab = 0
            , loadState = Loading.Off
            , tabState = Tab.initialState
            , userId = Nothing
        }, Cmd.none
    ) 


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
    | DoneAddHedgeHogAccount CreateUserResultInfo
    | TabMsg Tab.State
   
   

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [hedgeHogloginResult DoneLogin, hedgeHogCreateUserResult DoneAddHedgeHogAccount]

createAccountView : Model -> Html Msg
createAccountView model =
     div []
    [ 
        Form.form []
        [   Form.group []
                [ Form.label [for "myusername"] [ text "Username"]
                , Input.text [ Input.id "myusername", Input.onInput UpdateUserName, Input.value model.username ]
                , Form.help [] [ text "Enter User Name" ]
                ]
            
            , Form.group []
                [ Form.label [for "mypwd"] [ text "Password"]
                , Input.password [ Input.id "mypwd", Input.onInput UpdateNewPassword, Input.value model.password ]
                , Form.help [] [ text "Enter Password" ]
                ]
            , Form.group []
                [ Form.label [for "mypwdconfirm"] [ text "Confirm Password"]
                , Input.password [ Input.id "mypwdconfirm", Input.onInput UpdateNewConfirmPassword, Input.value model.passwordConfimation ]
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
        DoneAddHedgeHogAccount createInfo ->
            
            ({model |  message = "User added to Lgin Account" }, Cmd.none)
        TabMsg state ->
            ( { model | tabState = state }
            , Cmd.none
            )
        TabNavigate tabIndex ->
             ( { model | activeTab = tabIndex, loadState = Loading.Off }, Cmd.none )

        UpdateNewConfirmPassword pswd ->
             ( { model |  passwordConfimation = pswd  }, Cmd.none )

        UpdatePassword pswd ->
            ( { model |  password = pswd }, Cmd.none )

        UpdateNewPassword pswd ->
            ( { model |  password = pswd  }, Cmd.none )
        UpdateUserName usrname ->
            ( { model | username = usrname }, Cmd.none )
        StartLoginOrCancel ->
            if model.loadState == Loading.Off then
                ( { model | walletAddress = "-" , message = "" , loadState = Loading.On }
                , loginUser {username = model.username, password = model.password }
                )

            else
                ( { model | walletAddress = "-" , message = "" , loadState = Loading.Off }, Cmd.none )

        RegisterUser ->
            ( { model | message = "Adding User. Please Wait", loadState = Loading.On }, registerUser {username = model.username, password = model.password }  )
        DoneLogin data ->
            case data.isLoggedIn of
                True ->
                    Debug.log "Success  .."
                    (model, (Nav.pushUrl model.navKey  (Routes.gamePathLogin model.username)) )
                      
                False ->
                    Debug.log "Fail  .."
                    ( { model | walletAddress = "-" , message = data.message , loadState = Loading.Off } 
                    , Cmd.none ) 
            
loginView : Model -> Html Msg
loginView model =
   div []
    [ 
        Form.form []
        [   Form.group []
                [ Form.label [for "myusername"] [ text "Username"]
                , Input.text [ Input.id "myusername", Input.onInput UpdateUserName, Input.value model.username ]
                , Form.help [] [ text "Enter User Name" ]
                ]
            
            , Form.group []
                [ Form.label [for "mypwd"] [ text "Password"]
                , Input.password [ Input.id "mypwd", Input.onInput UpdatePassword, Input.value model.password ]
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
        , div [] [ text model.message ]
        
    ]

port setUserGraphId : UserIdUpdate -> Cmd msg 
port registerUser : UserInfo -> Cmd msg
port loginUser : UserInfo -> Cmd msg
port hedgeHogloginResult : (LoginResultInfo -> msg) -> Sub msg
port hedgeHogCreateUserResult : (CreateUserResultInfo -> msg) -> Sub msg