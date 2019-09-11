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
import Login as Login
import Model 
import Show as Show
import Url exposing (Url)


type Msg
    = GotAuthMsg Login.Msg
    | GotShowMsg Show.Msg
    | ShowsResult (Result Http.Error (List Model.ShowInfo))
    | DoneLogin Model.LoginResultInfo

init : String -> ( Model, Cmd Msg )
init flag =
    let
        root =
            Auth initdata
    in
    ( root, Cmd.none )



type Model
    = Auth Login.Model
    | Shows Show.Model
   
    

initShowsData : Show.Model
initShowsData =
    { showInfos = [] }


initdata : Login.Model
initdata =
    { loginResult =
        { isLoggedIn = False
        , address = "-"
        , message = ""
        }
    , userInfo =
        { userName = ""
        , password = ""
        , passwordConfimation = ""
        }
    , activeTab = Login.LoggingInTab
    , loadState = Loading.Off
    }


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
                    (Shows initShowsData, getTvShows)  
                False ->
                    ( mdl , Cmd.none
                    ) 
            
        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


getTvShows : Cmd Msg
getTvShows =
    Http.get
        { url = "https://api.themoviedb.org/3/discover/tv?api_key=6aec6123c85be51886e8f69cd9a3a226&first_air_date.gte=2019-01-01&page=1"
        , expect = Http.expectJson ShowsResult Model.listOfShowsDecoder
        }

-- GotShows result ->
--     case result of
--         Ok shows ->
--             (Shows { initShowsData | showInfos = shows }, Cmd.none)
--         Err _ ->
--             case  model  of
--                 Auth amdl  ->
--                     (model, Cmd.none)
--                 _ ->
--                     (model, Cmd.none)
-- Logout ->
--     (Auth initdata, logoutUser "logging out..." )
-- _ ->
--     case  model  of
--         Auth amdl  ->
--             loginUpdate msg amdl |>
--                     updateWith Auth
--         Shows smdl  ->
--             showUpdate msg smdl |>
--                 updateWith Shows


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
                    Show.showsView smdl |> Html.map GotShowMsg

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

port hedgeHogloginResult : (Model.LoginResultInfo -> msg) -> Sub msg
