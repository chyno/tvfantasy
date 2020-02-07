module Page.ShowsManage exposing (Model, Msg(..), TvApiShowInfo, init, subscriptions, update, view)

import Bootstrap.Form.Checkbox exposing (checkbox, checked, onCheck)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (..)
import Json.Decode as D
import Shared exposing (..)
import Graphql.Http exposing (Error)
import Graphql.OptionalArgument exposing (..)
import Api.InputObject exposing (GameInput, GameInputRaw, buildGameInput)
import Api.Mutation as Mutation
import Api.InputObject exposing (buildShowInput, ShowInput)
import TvApi exposing (showSelection)
import RemoteData exposing (RemoteData)

type Msg
    = OnFetchShows (Result Http.Error (List TvApiShowInfo))
    | NavigateGame
    | AddShows
    | SelectShow String Bool
    | GotShowAddResponse (RemoteData (Graphql.Http.Error  ShowInfo)   ShowInfo)


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( LoadingData { showInfosLoading = Loading }, fetchShows flags )



-- Model


type alias LoadingModel =
    { showInfosLoading : RemoteDataMsg (List RemoteShowInfo) }


type alias LoadedModel =
    { showInfos : List TvApiShowInfo
    , selectedShowInfos : Maybe TvApiShowInfo
    }


type Model
    = LoadingData LoadingModel
    | LoadedData LoadedModel



-- type alias Model =
--     { showInfos : RemoteDataMsg (List TvApiShowInfo)
--     }


type alias RemoteShowInfo =
    { name : String
    , overview : String
    , firstAirDate : String
    , voteAverage : Float
    }


type alias TvApiShowInfo =
    { name : String
    , overview : String
    , firstAirDate : String
    , voteAverage : Float
    }


fetchShows : Flags -> Cmd Msg
fetchShows flags =
    Http.get
        { url = flags.api
        , expect = Http.expectJson OnFetchShows listOfShowsDecoder
        }


makeUserInfoRequest : String -> Cmd Msg
makeUserInfoRequest username =
    Cmd.none



-- queryUserInfo username
--     |> Graphql.Http.queryRequest "https://graphql.fauna.com/graphql"
--     |> Graphql.Http.withHeader "Authorization" ("Bearer fnADbMd3RLACEpjT90hoJSn6SXhN281PIgIZg375" )
--     |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)
-- Update




showAddData : TvApiShowInfo -> ShowInput
showAddData gameData =
    let
        funOp =
            \_ -> { game = Absent }
    in
        buildShowInput
             { showName =""
                , rating = 0
                , showDescription = ""
            }
            funOp

createShowCmd : TvApiShowInfo -> Cmd Msg
createShowCmd showData =
    Mutation.createShow { data = showAddData showData } showSelection
        |> Graphql.Http.mutationRequest faunaEndpoint
        |> Graphql.Http.withHeader "Authorization" faunaAuth
        |> Graphql.Http.send (RemoteData.fromResult >> GotShowAddResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        LoadedData mdl ->
            case msg of
                SelectShow name isCheck ->
                   if isCheck then
                        ( model, Cmd.none )
                    else
                        ( model, Cmd.none )
                AddShows ->
                    (model, Cmd.none )
                _ ->
                    Debug.todo "Handle messge"
                     
        LoadingData mdl ->
            case msg of
                OnFetchShows (Ok shows) ->
                    Debug.log "ok shows .."
                        ( LoadedData { showInfos = shows, selectedShowInfos = Nothing }, Cmd.none )

                -- (LoadedData { showInfos =  shows, selectedShowInfos = Nothing}, LoadSelectedShows )
                OnFetchShows (Err err) ->
                    Debug.log "error .."
                        ( LoadingData { showInfosLoading = Failure }, Cmd.none )

                NavigateGame ->
                    ( model, Cmd.none )
                    -- ( model, Nav.load Routes.gamePath )

                _ ->
                    Debug.todo "Handle messge"



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Views


view : Model -> Html Msg
view model =
    case model of
        LoadingData mdl1 ->
            loadingView mdl1
        LoadedData mdl2 ->
            loadedView mdl2


loadingView : LoadingModel -> Html Msg
loadingView model =
    let
        content =
            case model.showInfosLoading of
                NotAsked ->
                    text "not asked"

                Loading ->
                    text "Loading"

                Loaded players ->
                    text "Loaded"

                Failure ->
                    text "Error"
    in
    section [ class "p-4" ]
        [ content ]


showRow : TvApiShowInfo -> Html Msg
showRow show =
    tr []
        [ td [] [ checkbox [ SelectShow show.name |> onCheck ] "" ]
        , td [] [ text show.name ]
        , td [] [ text show.overview ]
        , td [] [ text show.firstAirDate ]
        , td [] [ text (String.fromFloat show.voteAverage) ]
        ]


loadedView : LoadedModel -> Html Msg
loadedView model =
    div [ class "message" ]
        [ h1 [] [ text "These are available shows:" ]
        , div [ id "wrapper" ]
            [ table []
                (tr []
                    [ th [] []
                    , th [] [ text "Name" ]
                    , th [] [ text "Description" ]
                    , th [] [ text "First Aired" ]
                    , th [] [ text "Vote Average" ]
                    ]
                    :: List.map showRow model.showInfos
                )
            ]
         , div [ class "button", onClick AddShows ] [ text "Add Shows" ]
        , div [ class "button", onClick NavigateGame ] [ text "Back to Your Tv Game" ]
        ]



-- Decoders
showDecoder : D.Decoder RemoteShowInfo
showDecoder =
    D.map4
        RemoteShowInfo
        (D.field "name" D.string)
        -- (D.field "country" D.string))
        (D.field "overview" D.string)
        (D.field "first_air_date" D.string)
        (D.field "vote_average" D.float)


listOfShowsDecoder : D.Decoder (List TvApiShowInfo)
listOfShowsDecoder =
    D.field "results" (D.list showDecoder)



-- port logoutUser : String -> Cmd msg
-- , onClick  Logout
-- , onClick StartLogout
