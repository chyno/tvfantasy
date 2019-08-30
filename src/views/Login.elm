module Login exposing (..)

import Browser
import Html exposing ( ..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as E
import Model exposing (..)
 
import Loading
    exposing
        ( LoaderType(..)
        , defaultConfig
        , render
        )

tabClassString : AuthModel -> ActiveLoginTab -> String
tabClassString model tab =
    if model.activeTab == tab then
        "tab active"

    else
        "tab"


updateTab : ActiveLoginTab -> AuthModel -> ( AuthModel, Cmd LoginMsg )
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


headersView : AuthModel -> Html LoginMsg
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


createAccountView : AuthModel -> Html LoginMsg
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


loginView : AuthModel -> Html LoginMsg
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

tabView : AuthModel -> Html LoginMsg
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

signedInView : AuthModel -> Html LoginMsg
signedInView model =
    div [ class "message" ]
        [ div [ class "pill green" ]
            [ text "authenticated" ]
        , h1 []
            [ text "You're Signed In!" ]
        , p []
            [ text "You just created an account using Hedgehog! Now, if you log out you will be able to sign back in with the same credentials." ]
        ]