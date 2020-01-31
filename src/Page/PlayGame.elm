module Page.PlayGame exposing (Model, Msg(..), init, subscriptions, update, view)

import Api.Object
import Api.Object.Game as Game
import Api.Object.GamePage as GamePage
import Api.Object.Show as Show
import Api.Object.User as User
import Api.Query as Query
import Api.Scalar exposing (Id(..))
import Graphql.Document as Document
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html, div, h1, label, text)
import Html.Events exposing (onClick)
import Shared exposing (GameInfo, NetworkInfo, ShowInfo, UserInfo)



--  Model


type alias GameData =
    { data : List (Maybe GameInfo)
    }


gameDataParser : GameData -> List (Maybe GameInfo)
gameDataParser ndata =
    ndata.data


fillArgs : User.GamesOptionalArguments -> User.GamesOptionalArguments
fillArgs x =
    x


type alias GameModel =
    { userName : String
    , selectedNetwork : Maybe NetworkInfo
    , availableNetworks : List String
    }


showSelection : SelectionSet ShowInfo Api.Object.Show
showSelection =
    SelectionSet.map3 ShowInfo
        Show.showName
        Show.rating
        Show.showDescription



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



-- queryShow : SelectionSet (Maybe ShowInfo) RootQuery
-- queryShow =
--     Query.findShowByID { id = Id "256015281662460435" } showSelection


queryUser : String -> SelectionSet (Maybe UserInfo) RootQuery
queryUser userName =
    Query.userByUserName { userName = userName } userSelection


queryGame : String -> SelectionSet (Maybe GameInfo) RootQuery
queryGame gameId =
    Query.findGameByID { id = Id gameId } gameSelection


newNetwork : NetworkInfo
newNetwork =
    { name = ""
    , rating = 0
    , description = ""
    , shows = []
    }


type Model
    = LoadingExistingNetworks String
    | DisplayGame GameModel


type Msg
    = AddNewNetwork
    | EditExistingNetwork



-- View


view : Model -> Html Msg
view model =
    let
        vw =
            case model of
                LoadingExistingNetworks mdl ->
                    loadingView

                DisplayGame mdl ->
                    case mdl.selectedNetwork of
                        Nothing ->
                            div [] [ text "Create a Network to start a game" ]

                        Just sel ->
                            gameView sel
    in
    div []
        [ vw
        , Html.button [ onClick AddNewNetwork ] [ text "Add New Network " ]
        ]


loadingView : Html Msg
loadingView =
    div [] [ text "... Loading" ]


gameView : NetworkInfo -> Html Msg
gameView netInfo =
    div []
        [ label [] [ text "Name: " ]
        , div [] [ text netInfo.name ]
        , label [] [ text "Rating: " ]
        , div [] [ text "netInfo.rating" ]
        , label [] [ text "Description: " ]
        , div [] [ text netInfo.description ]
        ]



--
-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( AddNewNetwork, DisplayGame mdl ) ->
            Debug.log "Adding newwork"
                ( DisplayGame { mdl | selectedNetwork = Just newNetwork }, Cmd.none )

        ( EditExistingNetwork, DisplayGame mdl ) ->
            ( DisplayGame mdl, Cmd.none )

        _ ->
            ( model, Cmd.none )


initModel : String -> Model
initModel userName =
    DisplayGame
        { userName = userName
        , selectedNetwork = Nothing
        , availableNetworks = []
        }



-- Helpers


init : String -> ( Model, Cmd Msg )
init userName =
    ( initModel userName, Cmd.none )
