port module Page.Login exposing (LoginResultInfo, Model, Msg(..), init, subscriptions, update, view)

-- import Api.Object exposing (User)

import Api.InputObject exposing (..)
import Api.Mutation exposing (CreateUserRequiredArguments, createUser)
import Api.Object
import Api.Object.User as User
import Api.Scalar exposing (Id(..))
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Tab as Tab
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Navigation as Nav exposing (Key)
import Graphql.Operation exposing (RootMutation)
import Graphql.OptionalArgument exposing (..)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Loading
    exposing
        ( LoaderType(..)
        , LoadingState
        , defaultConfig
        , render
        )
import RemoteData exposing (RemoteData)
import Routes exposing (playGamePath)
import Shared exposing (..)


type alias Response =
    { id : Id }



-- Model


type alias LoginResultInfo =
    { isLoggedIn : Bool
    , address : String
    , message : String
    }


type alias CreateUserResultInfo =
    { isCreated : Bool
    , message : String
    }


type alias Model =
    { userName : String
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
    { userName : String
    , password : String
    }


type alias UserIdUpdate =
    { username : String
    , id : String
    }



-- End Model *****************************************
-- getMutArgs : String -> String -> CreateUserRequiredArguments
-- getMutArgs username walletAddress =
--     {
--         data =   (getUserDataRaw username walletAddress)
--     }


init : Key -> ( Model, Cmd Msg )
init key =
    ( { navKey = key
      , walletAddress = ""
      , message = ""
      , userName = ""
      , password = ""
      , passwordConfimation = ""
      , activeTab = 0
      , loadState = Loading.Off
      , tabState = Tab.initialState
      , userId = Nothing
      }
    , Cmd.none
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
    Sub.batch [ hedgeHogloginResult DoneLogin, hedgeHogCreateUserResult DoneAddHedgeHogAccount ]


createAccountView : Model -> Html Msg
createAccountView model =
    div [ class "flex-container-login" ]
        [ div [ class "flex-item-login" ]
            [ Form.form []
                [ Form.group []
                    [ Form.label [ for "myusername" ] [ text "User Name" ]
                    , Input.text [ Input.id "myusername", Input.onInput UpdateUserName, Input.value model.userName ]
                    , Form.help [] [ text "Enter User Name" ]
                    ]
                , Form.group []
                    [ Form.label [ for "mypwd" ] [ text "Password" ]
                    , Input.password [ Input.id "mypwd", Input.onInput UpdateNewPassword, Input.value model.password ]
                    , Form.help [] [ text "Enter Password" ]
                    ]
                , Form.group []
                    [ Form.label [ for "mypwdconfirm" ] [ text "Confirm Password" ]
                    , Input.password [ Input.id "mypwdconfirm", Input.onInput UpdateNewConfirmPassword, Input.value model.passwordConfimation ]
                    , Form.help [] [ text "Enter Password again" ]
                    ]
                ]
            ]
        , div [ class "flex-item-login" ]
            [ div [ class "button-group" ]
                [ Button.button [ Button.primary, Button.onClick RegisterUser ] [ text "Create my Account" ]
                , Button.button [ Button.secondary, Button.onClick (TabNavigate 0) ] [ text "Cancel" ]
                ]
            ]
        ]



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoneAddHedgeHogAccount createInfo ->
            ( { model | message = "User added to Lgin Account",  loadState = Loading.Off }, Cmd.none )

        TabMsg state ->
            ( { model | tabState = state, loadState = Loading.Off }
            , Cmd.none
            )

        TabNavigate tabIndex ->
            ( { model | activeTab = tabIndex, loadState = Loading.Off }, Cmd.none )

        UpdateNewConfirmPassword pswd ->
            ( { model | passwordConfimation = pswd }, Cmd.none )

        UpdatePassword pswd ->
            ( { model | password = pswd }, Cmd.none )

        UpdateNewPassword pswd ->
            ( { model | password = pswd }, Cmd.none )

        UpdateUserName usrname ->
            ( { model | userName = usrname }, Cmd.none )

        StartLoginOrCancel ->
            if model.loadState == Loading.Off then
                ( { model | walletAddress = "-", message = "logging in ..", loadState = Loading.On }
                , loginUser { userName = model.userName, password = model.password }
                )

            else
                ( { model | walletAddress = "-", message = "", loadState = Loading.Off }, Cmd.none )

        RegisterUser ->
            ( { model | message = "Adding User. Please Wait", loadState = Loading.On }, registerUser { userName = model.userName, password = model.password } )

        DoneLogin data ->
            if data.isLoggedIn then
                Debug.log "Success  .."
                    ( { model| loadState = Loading.Off}, Nav.pushUrl model.navKey (Routes.playGamePath model.userName) )

            else
                Debug.log "Fail  .."
                    ( { model | walletAddress = "-", message = data.message, loadState = Loading.Off }
                    , Cmd.none
                    )


loginView : Model -> Html Msg
loginView model =
    div [ class "flex-container-login" ]
        [ div [ class "flex-item-login" ]
            [ Form.form [  ]
                [ Form.group []
                    [ Form.label [ for "myusername" ] [ text "User Name" ]
                    , Input.text [ Input.id "myusername", Input.onInput UpdateUserName, Input.value model.userName ]
                    , Form.help [] [ text "Enter User Name" ]
                    ]
                , Form.group []
                    [ Form.label [ for "mypwd" ] [ text "Password" ]
                    , Input.password [ Input.id "mypwd", Input.onInput UpdatePassword, Input.value model.password ]
                    , Form.help [] [ text "Enter Password" ]
                    ]
                ]
            ]
        , div [ class "flex-item-login" ]
            [ div [ class "button-group" ]
                [ Button.button [ Button.primary,  Button.onClick StartLoginOrCancel ] [ text "Login" ]
                , Button.button [ Button.secondary, Button.onClick StartLoginOrCancel ] [ text "Cancel" ]
                ]
            ]
        ]



-- View


view : Model -> Html Msg
view model =
    div []
        [ Tab.config TabMsg
            |> Tab.items
                [ Tab.item
                    { id = "tabLogin"
                    , link = Tab.link [] [ text "Log In" ]
                    , pane =
                        Tab.pane [ Spacing.mt3 ]
                            [ loginView model ]
                    }
                , Tab.item
                    { id = "tabCreateUser"
                    , link = Tab.link [] [ text "Create User" ]
                    , pane =
                        Tab.pane [ Spacing.mt3 ]
                            [ createAccountView model ]
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


port registerUser : UserInfo -> Cmd msg


port loginUser : UserInfo -> Cmd msg


port hedgeHogloginResult : (LoginResultInfo -> msg) -> Sub msg


port hedgeHogCreateUserResult : (CreateUserResultInfo -> msg) -> Sub msg
