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


init : String -> ( Model, Cmd Msg )
init flag =
    ( initdata, Cmd.none )


tabClassString : Model -> ActiveLoginTab -> String
tabClassString model tab =
    if model.activeTab == tab then
        "tab active"

    else
        "tab"


initdata : Model
initdata =
    { loginResult =
        { isLoggedIn = False
        , address = "-"
        , message = ""
        , showInfos = []
        }
    , userInfo =
        { userName = ""
        , password = ""
        , passwordConfimation = ""
        }
    , activeTab = LoggingInTab
    , activePage = LoginPage
    , loadState = Loading.Off
    }



-- adaptionView : Model -> Html Msg
-- adaptionView model =
--     div [][
--             p [][ text "Your wallet address is:" ]
--             , p [ class "address" ]
--                 [ text model.loginResult.address ]
--             , div [ class "button", onClick  (PageNavigate LoginPage   ) ]
--                 [ text "Log Out"  ]
--     ]


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

                    LoggedInTab ->
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


loginView : Model -> Html Msg
loginView model =
    let
        buttonText = if model.loadState == Loading.Off then "Login" else "Cancel"
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
                    , showInfos = []
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



-- type ActivePage =  LoginPage
--                    | AdaptionPage


updatePage : ActivePage -> Model -> ( Model, Cmd Msg )
updatePage msg model =
    ( { model | activePage = msg }, Cmd.none )


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

        LoggedInTab ->
            ( { model | activeTab = LoggedInTab }, Cmd.none )

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


subscriptions : Model -> Sub Msg
subscriptions model =
    loginResult DoneLogin


signedInView : Model -> Html Msg
signedInView model =
    div [ class "message" ]
        [ div [ class "pill green" ]
            [ text "authenticated" ]
        , h1 []
            [ text "You're Signed In!" ]
        , p []
            [ text "You just created an account using Hedgehog! Now, if you log out you will be able to sign back in with the same credentials." ]
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

                LoggedInTab ->
                    signedInView model
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


port loginResult : (LoginResultInfo -> msg) -> Sub msg
