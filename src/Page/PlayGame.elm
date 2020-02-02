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



-- ((User.games fillArgs gamePageSelection) |> SelectionSet.map gameDataParser)


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


makeUserInfoRequest : Cmd Msg
makeUserInfoRequest =
    Query.findUserByID { id = Id "256087277788201490" } userSelection
        |> Graphql.Http.queryRequest "https://graphql.fauna.com/graphql"
        |> Graphql.Http.withHeader "Authorization" " Basic Zm5BRGprSEpKa0FDRkNvZThnamFsMC13bWJEVDZPZkdBWXpORVo1UDp0dmZhbnRhc3k6c2VydmVy"
        |> Graphql.Http.send (RemoteData.fromResult >> GotUserInfoResponse)


type Model
    = LoadingExistingNetworks String
    | DisplayGame UserInfo


type alias Response =
    Maybe UserInfo


type alias Foo =
    RemoteData (Graphql.Http.Error Response) Response


type Msg
    = AddNewNetwork
    | EditExistingNetwork
    | GotUserInfoResponse Foo



-- View


view : Model -> Html Msg
view model =
    case model of
        LoadingExistingNetworks mdl ->
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
--                 LoadingExistingNetworks mdl ->
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
    case ( msg, model ) of
        ( EditExistingNetwork, LoadingExistingNetworks _ ) ->
            ( LoadingExistingNetworks "Load ? ...", Cmd.none )

        ( AddNewNetwork, _ ) ->
            ( model, makeUserInfoRequest )

        ( EditExistingNetwork, DisplayGame mdl ) ->
            ( model, Cmd.none )

        ( GotUserInfoResponse response, _ ) ->
            case response of
                RemoteData.Loading ->
                    ( LoadingExistingNetworks "starting to make reuest...", Cmd.none )

                RemoteData.Success maybeData ->
                    case maybeData of
                        Just data ->
                            ( DisplayGame data, Cmd.none )

                        Nothing ->
                            ( LoadingExistingNetworks "Can not get data", Cmd.none )
                RemoteData.Failure err ->
                   ( LoadingExistingNetworks  (errorToString err), Cmd.none )
                RemoteData.NotAsked ->
                    ( LoadingExistingNetworks "Not Asked", Cmd.none )


-- Helpers

errorToString : Error Response -> String
errorToString err =
    "Error Response. Error: "
    -- case err of
    --     Timeout ->
    --         "Timeout exceeded"

    --     NetworkError ->
    --         "Network error"
    --     BadStatus meta resp ->
    --          resp
    --     BadPayload jsonErro  ->
    --         "Unexpected response from api: "

    --     BadUrl url ->
    --         "Malformed url: " ++ url
    
        

     
        
    
       
            
    

init : String -> ( Model, Cmd Msg )
init username =
    ( LoadingExistingNetworks "loading page foo ...", makeUserInfoRequest )
