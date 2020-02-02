module Page.PlayGame exposing (Model, Msg(..), init, subscriptions, update, view)

import Api.Object
import Api.Object.Game as Game
import Api.Object.GamePage as GamePage
import Api.Object.User as User
import Api.Query as Query
import Api.Scalar exposing (Id(..))
import Graphql.Http exposing (..)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html, div, h1, label, li, text, ul)
import Html.Events exposing (onClick)
import RemoteData exposing (RemoteData)
import Shared exposing (GameInfo, UserInfo)
import Json.Decode as Json


--  Model
type alias GameData =
    { data : List (Maybe GameInfo)
    }


gameDataParser : GameData -> List GameInfo
gameDataParser ndata =
    List.foldr foldrValues [] ndata.data


foldrValues : Maybe a -> List a -> List a
foldrValues item list =
    case item of
        Nothing ->
            list

        Just v ->
            v :: list


fillArgs : User.GamesOptionalArguments -> User.GamesOptionalArguments
fillArgs x =
    x


userSelection : SelectionSet UserInfo Api.Object.User
userSelection =
    SelectionSet.map3 UserInfo
        User.userName
        User.walletAddress
        (User.games fillArgs gamePageSelection |> SelectionSet.map gameDataParser)



gamePageSelection : SelectionSet GameData Api.Object.GamePage
gamePageSelection =
    SelectionSet.map GameData
        (GamePage.data gameSelection)


gameSelection : SelectionSet GameInfo Api.Object.Game
gameSelection =
    SelectionSet.map4 GameInfo
        Game.gameName
        Game.walletAmount
        Game.networkName
        Game.networkDescription


makeUserInfoRequest : String -> Cmd Msg
makeUserInfoRequest  userName =
    Query.userByUserName { userName = userName } userSelection
        |> Graphql.Http.queryRequest "https://graphql.fauna.com/graphql"
        |> Graphql.Http.withHeader "Authorization" " Basic Zm5BRGprSEpKa0FDRkNvZThnamFsMC13bWJEVDZPZkdBWXpORVo1UDp0dmZhbnRhc3k6c2VydmVy"
        |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)


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
            loadingView ("Loading Data for user ")
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



-- view : Model -> Html Msg
-- view model =
--     let
--         vw =
--             case model of
--                 ErrorLoading mdl ->
--                     loadingView
--                 DisplayGame mdl ->
--                     case mdl.games of
--                         Nothing ->
--                             div [] [ text "Create a Network to start a game" ]
--                         Just sel ->
--                             gameView sel
--     in
--     div []
--         [ vw
--         , Html.button [ onClick AddNewNetwork ] [ text "Add New Network " ]
--         ]


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
        LoadingData userName->
            ( model, makeUserInfoRequest userName)
        EditExistingNetwork ->
            ( ErrorLoading "Load ? ...", Cmd.none )

        AddNewNetwork ->
            ( model, makeUserInfoRequest "user123")

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
                   ( ErrorLoading  (errorToString err), Cmd.none )
                RemoteData.NotAsked ->
                    ( ErrorLoading "Not Asked", Cmd.none )


-- Helpers

errorToString : Error Response -> String
errorToString err =
    "Error Response. Error: "
   
   
init : String -> ( Model, Cmd Msg )
init username =
    ( LoadingExistingNetworks, makeUserInfoRequest username )
