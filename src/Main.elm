port module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Json.Decode as Decode exposing (Value)
import Json.Encode as E
import Loading
    exposing
        ( LoaderType(..)
        , defaultConfig
        , render
        )
import Page.Login as Login
import Page.Show as Show
import Url exposing (Url)
import Model

type Msg
    = GotAuthMsg Login.Msg
    | GotShowMsg Show.Msg
    | DoneLogin Login.LoginResultInfo

init : String -> ( Model, Cmd Msg )
init flag =
    let
        root =
            Auth Login.initdata
    in
    ( root, Cmd.none )

type Model
    = Auth Login.Model
    | Shows Show.Model

subscriptions : Model -> Sub Msg
subscriptions model =
    let childSub =
                case model of
                    Auth auth ->
                        Sub.map GotAuthMsg (Login.subscriptions auth)

                    Shows shows ->
                        Sub.map GotShowMsg (Show.subscriptions shows)
    in
        Sub.batch[hedgeHogloginResult DoneLogin, childSub]
   



-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotAuthMsg subMsg, Auth userInfo ) ->
            Login.update subMsg userInfo
                |> updateWith Auth GotAuthMsg model

        ( GotShowMsg subMsg, Shows shows ) ->
            Show.update subMsg shows
                |> updateWith Shows GotShowMsg model
        (DoneLogin data, mdl) ->
            case data.isLoggedIn of
                True ->
                    Show.update Show.InitShows Show.initShowsData
                        |> updateWith Shows GotShowMsg model
                      
                False ->
                    ( mdl , Cmd.none ) 
            
        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )



updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- -- (a -> msg) -> Cmd a -> Cmd msg


view : Model -> Html Msg
view model =
    let
        toView mdl =
            case mdl of
                Shows smdl ->
                    Show.view smdl |> Html.map GotShowMsg

                Auth amdl ->
                    Login.tabView amdl |> Html.map GotAuthMsg
    in
    div [ id "root" ]
        [ div [ class "app" ]
            [ model |> toView ]
        ]



-- main : Program Value Model Msg


main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }



-- Outgoing ports
port logoutUser : String -> Cmd msg

port hedgeHogloginResult : (Login.LoginResultInfo -> msg) -> Sub msg
