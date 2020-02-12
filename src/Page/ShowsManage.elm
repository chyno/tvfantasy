module Page.ShowsManage exposing (Model, Msg(..), TvApiShowInfo, init, subscriptions, update, view)

import Bootstrap.Form.Checkbox exposing (checkbox, checked, onCheck)
import Browser.Navigation as Nav
import Bootstrap.Button as Button
import Bootstrap.Form.Checkbox as Checkbox
import Html exposing (..)
import Html.Attributes exposing (..)
import Api.Scalar exposing (Id(..))
import Html.Events exposing (onClick)
import Http exposing (..)
import Json.Decode as D
import Shared exposing (..)
import Graphql.Http exposing (Error)
import Graphql.OptionalArgument exposing (..)
import Api.Mutation as Mutation
import Api.InputObject exposing (buildShowInput, ShowInput)
import TvApi exposing (showSelection)
import RemoteData exposing (RemoteData)
import Api.InputObject exposing (GameShowsRelation, ShowInputOptionalFields, ShowGameRelationRaw )
type Msg
    = OnFetchShows (Result Http.Error (List TvApiShowInfo))
    | NavigateGame
    | AddShows
    | SelectShow  String 
    | GotShowAddResponse (RemoteData (Graphql.Http.Error  ShowInfo)   ShowInfo)


init : Flags -> String -> ( Model, Cmd Msg )
init flags gameId =
    ( { modelData =  LoadingData { showInfosLoading = Loading }, gameId = gameId }, fetchShows flags )


-- Model
type alias LoadingModel =
    { showInfosLoading : RemoteDataMsg (List TvApiShowInfo) }


type alias LoadedModel =
    { showInfos : List TvApiShowInfo
      , selectedShows : List String
   
    }

type alias Model = 
    {
        gameId : String
        , modelData : ModelData
    }

type ModelData
    = LoadingData LoadingModel
    | LoadedData LoadedModel

type alias TvApiShowInfo =
    { 
     name : String
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



getShowRelationData : String -> Api.InputObject.ShowGameRelationRaw
getShowRelationData gameId =
    {
     create =  Absent
      , connect = Present (Id gameId)
    }

unWrap : Api.InputObject.ShowGameRelationRaw -> Api.InputObject.ShowGameRelation
unWrap x = Api.InputObject.ShowGameRelation x


gameOptBuilder: String -> ShowInputOptionalFields -> ShowInputOptionalFields
gameOptBuilder gameId gStart = 
    { gStart | game = Present  (unWrap (getShowRelationData gameId))

    }

showAddData : String ->  TvApiShowInfo -> ShowInput
showAddData gameId  gameData =
    buildShowInput
             {  showName = gameData.name
                , rating = 0
                , showDescription = gameData.overview
            }
            (gameOptBuilder gameId)

createShowCmd : String ->  TvApiShowInfo -> Cmd Msg
createShowCmd gameId showData =
    Mutation.createShow { data = showAddData gameId showData } showSelection
        |> Graphql.Http.mutationRequest faunaEndpoint
        |> Graphql.Http.withHeader "Authorization" faunaAuth
        |> Graphql.Http.send (RemoteData.fromResult >> GotShowAddResponse)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( mData, cmdMsg ) = updateData model.gameId msg model.modelData
    in
        ({model | modelData = mData}, cmdMsg)


getSelectedShow: List TvApiShowInfo -> Maybe TvApiShowInfo
getSelectedShow shows = 
     List.head shows

toggleShowsSelected : String -> List String -> List String
toggleShowsSelected name items =
    let
        newlist = List.filter (\x -> not (x == name)) items
        newcount = List.length newlist
    in
        if List.length items == newcount then
            name::newlist
        else
            newlist

updateData : String -> Msg -> ModelData -> ( ModelData, Cmd Msg )
updateData gameId  msg model =
    case model of
        LoadedData mdl ->
            case msg of
                SelectShow  name   ->
                        (LoadedData {mdl | selectedShows = toggleShowsSelected name mdl.selectedShows }, Cmd.none )
                AddShows ->
                    let
                        maybeShow = getSelectedShow mdl.showInfos
                    in
                        case maybeShow of
                            Just aShow ->
                                (model, createShowCmd gameId aShow)
                            Nothing ->
                                (model, Cmd.none)
                _ ->
                    Debug.todo "Handle messge"
                     
        LoadingData _ ->
            case msg of
                OnFetchShows (Ok shows) ->
                    Debug.log "ok shows .."
                        ( LoadedData { showInfos =  shows, selectedShows = [] }, Cmd.none )

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
    case model.modelData of
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

                Loaded _ ->
                    text "Loaded"

                Failure ->
                    text "Error"
    in
    section [ class "p-4" ]
        [ content ]

isRowSeleted:  String -> List String -> Bool
isRowSeleted name items = 
    (List.filter (\x -> x == name) items |>
    List.length ) > 0

showRow : List String -> TvApiShowInfo  -> Html Msg
showRow selecteItems show  =
    tr []
        [ td [] [
             checkbox [ Checkbox.checked (isRowSeleted show.name selecteItems)] show.name 
             ]
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
                    :: List.map (showRow model.selectedShows) model.showInfos 
                )
            ]
         , Button.button [ Button.primary, Button.onClick AddShows ] [ text "Add Shows" ]
        ,  Button.button [ Button.secondary, Button.onClick NavigateGame ] [ text "Back To Game" ]
      
        ]


-- Decoders
showDecoder : D.Decoder TvApiShowInfo
showDecoder =
    D.map4 TvApiShowInfo
        (D.field "name" D.string)
        (D.field "overview" D.string)
        (D.field "first_air_date" D.string)
        (D.field "vote_average" D.float)
    
    
listOfShowsDecoder : D.Decoder (List TvApiShowInfo)
listOfShowsDecoder =
    D.field "results" (D.list showDecoder)
   