module Page.PlayGame exposing (Model, Msg(..), init, subscriptions, update, view)

import Api.Query as Query
import Graphql.Http exposing (Error)
import Html exposing (Html, div, h1, label, li, text, ul)
import Html.Events exposing (onClick)
import RemoteData exposing (RemoteData)
import Shared exposing (GameInfo, UserInfo)
import TvApi exposing (userSelection)



--  Model


type Model
    = ErrorLoading String
    | DisplayGame UserInfo
    | LoadingExistingNetworks


type alias Response =
    Maybe UserInfo


type alias GameResponse =
    RemoteData (Graphql.Http.Error Response) Response


type Msg
    = LoadingData String
    | AddNewNetwork
    | EditExistingNetwork
    | GotUserInfoResponse GameResponse



-- View


view : Model -> Html Msg
view model =
    case model of
        LoadingExistingNetworks ->
            loadingView "Loading Data for user "

        ErrorLoading mdl ->
            loadingView mdl

        DisplayGame mdl ->
            gameView mdl


gameView : UserInfo -> Html Msg
gameView model =
    div []
        [ label [] [ text model.userName ]
        , ul [] (List.map (\x -> li [] [ text x.gameName ]) model.games)
        ]


loadingView : String -> Html Msg
loadingView msg =
    div []
        [ div [] [ text msg ]
        , Html.button [ onClick AddNewNetwork ] [ text "Reload" ]
        ]



-- gameView : NetworkInfo -> Html Msg
-- gameView netInfo =
--     div []
--         [ label [] [ text "Name: " ]
--         , div [] [ text netInfo.name ]
--         , label [] [ text "Rating: " ]
--         , div [] [ text "netInfo.rating" ]
--         , label [] [ text "Description: " ]
--         , div [] [ text netInfo.description ]
--         ]
--
-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadingData userName ->
            ( model, makeUserInfoRequest userName )

        EditExistingNetwork ->
            ( ErrorLoading "Load ? ...", Cmd.none )

        AddNewNetwork ->
            ( model, makeUserInfoRequest "user123" )

        GotUserInfoResponse response ->
            case response of
                RemoteData.Loading ->
                    ( ErrorLoading "starting to make reuest...", Cmd.none )

                RemoteData.Success maybeData ->
                    case maybeData of
                        Just data ->
                            ( DisplayGame data, Cmd.none )

                        Nothing ->
                            ( ErrorLoading "Can not get data", Cmd.none )

                RemoteData.Failure err ->
                    ( ErrorLoading (errorToString err), Cmd.none )

                RemoteData.NotAsked ->
                    ( ErrorLoading "Not Asked", Cmd.none )



-- Helpers


errorToString : Error Response -> String
errorToString err =
    "Error Response. Error: "


init : String -> ( Model, Cmd Msg )
init username =
    ( LoadingExistingNetworks, makeUserInfoRequest username )


makeUserInfoRequest : String -> Cmd Msg
makeUserInfoRequest userName =
    Query.userByUserName { userName = userName } userSelection
        |> Graphql.Http.queryRequest "https://graphql.fauna.com/graphql"
        |> Graphql.Http.withHeader "Authorization" " Basic Zm5BRGprSEpKa0FDRkNvZThnamFsMC13bWJEVDZPZkdBWXpORVo1UDp0dmZhbnRhc3k6c2VydmVy"
        |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)
