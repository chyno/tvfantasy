module Page.Game.ShowsManage exposing (Model, ModelData(..), Msg(..), TvApiShowInfo, fetchShows, subscriptions, update, view)

import Api.InputObject exposing (ShowInput, ShowInputOptionalFields, buildShowInput)
import Api.Mutation as Mutation
import Api.Scalar exposing (Id(..))
import Bootstrap.Button as Button
import Bootstrap.Form.Checkbox as Checkbox exposing (checkbox, checked)
import Graphql.Http exposing (Error)
import Graphql.OptionalArgument exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (..)
import Json.Decode as D
import RemoteData exposing (RemoteData)
import Shared exposing (..)
import TvApi exposing (showSelection)

 
type ManageShowMsg =
    AddShows
    | SelectShow String

type PageShowMsg = OnFetchShows (Result Http.Error (List TvApiShowInfo))
    | GotShowAddResponse (RemoteData (Graphql.Http.Error ShowInfo) ShowInfo)
    | DoneMsg
   


type Msg =
    PageShow PageShowMsg
    |  ManageShow ManageShowMsg


-- Model
type alias LoadingModel =
    { showInfosLoading : RemoteDataMsg (List TvApiShowInfo) }


type alias LoadedModel =
    { showInfos : List TvApiShowInfo
    , selectedShows : List String
    }


type alias Model =
    { errorMessage : String
    , gameId :  Maybe String
    , modelData : ModelData
    }


type ModelData
    = StartLoad 
    | LoadingData LoadingModel
    | LoadedData LoadedModel
    


type alias TvApiShowInfo =
    { name : String
    , overview : String
    , firstAirDate : String
    , voteAverage : Float
    }


fetchShows :  Cmd PageShowMsg
fetchShows  =
    Debug.log "*********** fetching shows ************"
        Http.get
        { url = "https://api.themoviedb.org/3/discover/tv?api_key=6aec6123c85be51886e8f69cd9a3a226&first_air_date.gte=2019-01-01&page=1"
        , expect = Http.expectJson OnFetchShows listOfShowsDecoder
        }


getShowRelationData : String -> Api.InputObject.ShowGameRelationRaw
getShowRelationData gameId =
    { create = Absent
    , connect = Present (Id gameId)
    }


unWrap : Api.InputObject.ShowGameRelationRaw -> Api.InputObject.ShowGameRelation
unWrap x =
    Api.InputObject.ShowGameRelation x


gameOptBuilder : String -> ShowInputOptionalFields -> ShowInputOptionalFields
gameOptBuilder gameId gStart =
    { gStart
        | game = Present (unWrap (getShowRelationData gameId))
    }


showAddData : String -> TvApiShowInfo -> ShowInput
showAddData gameId gameData =
    buildShowInput
        { showName = gameData.name
        , rating = 0
        , showDescription = gameData.overview
        }
        (gameOptBuilder gameId)


createShowCmd : String -> TvApiShowInfo -> Cmd PageShowMsg
createShowCmd gameId showData =
    Mutation.createShow { data = showAddData gameId showData } showSelection
        |> Graphql.Http.mutationRequest faunaEndpoint
        |> Graphql.Http.withHeader "Authorization" faunaAuth
        |> Graphql.Http.send (RemoteData.fromResult >> GotShowAddResponse)

loadedModelUpdate: ManageShowMsg -> LoadedModel -> Maybe String -> ( LoadedModel, Cmd Msg )
loadedModelUpdate msg model maybeGameId =
    case msg of
        AddShows ->
            let
                maybeShow = getSelectedShow model.showInfos
            in
                case maybeShow of
                    Just aShow ->
                        case maybeGameId of
                            Just gameId ->
                                ( model, Cmd.map PageShow (createShowCmd gameId aShow) )                  
                            Nothing ->
                                 ( model, Cmd.none )
                    Nothing ->
                        ( model, Cmd.none )       
        SelectShow name ->
             ( { model | selectedShows = toggleShowsSelected name model.selectedShows }, Cmd.none )
       

            
    

updateFetchResult: Model -> (Result Http.Error (List TvApiShowInfo)) -> Model
updateFetchResult model results =
    case results of
        OnFetchShows (Ok shows) ->
            Debug.log "ok shows .."
            { model | modelData =  LoadedData { showInfos = shows, selectedShows = [] }}
        OnFetchShows (Err err) ->
            Debug.log "error .."
            { model | modelData =  LoadingData { showInfosLoading = Failure }}
        _ ->
            model
            
update :  Msg -> Model -> ( Model, Cmd Msg )
update  msg model =
    case msg of
        PageShow pmsg ->
            case pmsg of
                OnFetchShows fetchResults ->
                    (updateFetchResult model fetchResults, Cmd.none)
                GotShowAddResponse response ->
                    case response of
                        RemoteData.Loading ->
                            (  model , Cmd.none )
                        RemoteData.Success data ->
                            ( { model |   errorMessage = "Show added" }, Cmd.none )
                        RemoteData.Failure _ ->
                            ( { model | errorMessage = "err" }, Cmd.none )
                        RemoteData.NotAsked ->
                            ( { model | errorMessage = "not asked" }, Cmd.none )
                DoneMsg ->
                    ( { model | gameId = Nothing}, Cmd.none)
        ManageShow mmsg ->
            case model.modelData of
                LoadedData loadedModel ->
                    let
                        (newLoadedModel, newCmd) = loadedModelUpdate mmsg loadedModel model.gameId
                    in
                       ( { model | modelData = newLoadedModel  }, newCmd)
                _ ->
                    (model, Cmd.none)   
            
            

getSelectedShow : List TvApiShowInfo -> Maybe TvApiShowInfo
getSelectedShow shows =
    List.head shows


toggleShowsSelected : String -> List String -> List String
toggleShowsSelected name items =
    let
        newlist =
            List.filter (\x -> not (x == name)) items

        newcount =
            List.length newlist
    in
    if List.length items == newcount then
        name :: newlist

    else
        newlist


-- updateData :  String -> Msg -> ModelData -> ( ModelData, Cmd Msg )
-- updateData  gameId msg model =
--     case model of
--         StartLoad  ->
--             ( LoadingData { showInfosLoading = Loading }, fetchShows )

--         LoadedData mdl ->
--             case msg of
--                 SelectShow name ->
--                     ( LoadedData { mdl | selectedShows = toggleShowsSelected name mdl.selectedShows }, Cmd.none )

--                 AddShows ->
--                     let
--                         maybeShow =
--                             getSelectedShow mdl.showInfos
--                     in
--                     case maybeShow of
--                         Just aShow ->
--                             ( model, createShowCmd gameId aShow )

--                         Nothing ->
--                             ( model, Cmd.none )

--                 _ ->
--                     Debug.todo "Loaded Data Handle messge"

--         LoadingData _ ->
--             case msg of
--                 OnFetchShows (Ok shows) ->
--                     Debug.log "ok shows .."
--                         ( LoadedData { showInfos = shows, selectedShows = [] }, Cmd.none )

--                 -- (LoadedData { showInfos =  shows, selectedShowInfos = Nothing}, LoadSelectedShows )
--                 OnFetchShows (Err err) ->
--                     Debug.log "error .."
--                         ( LoadingData { showInfosLoading = Failure }, Cmd.none )

--                 _ ->
--                     Debug.todo "Loading data ...Handle messge"



-- -- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Views


view : Model -> Html Msg
view model =
    let
        vw =
            case model.modelData of
                LoadingData mdl1 ->
                    loadingView mdl1

                LoadedData mdl2 ->
                    loadedView mdl2

                _ ->
                    div [] [ text "Begin Loading shows.." ]
    in
    div []
        [ vw
        , div [] [ text model.errorMessage ]
        ]


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


isRowSeleted : String -> List String -> Bool
isRowSeleted name items =
    (List.filter (\x -> x == name) items
        |> List.length
    )
        > 0


showRow : List String -> TvApiShowInfo -> Html Msg
showRow selecteItems show =
    tr []
        [ td []
            [ checkbox [ Checkbox.checked (isRowSeleted show.name selecteItems) ] show.name
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
        , Button.button [ Button.secondary, Button.onClick DoneMsg ] [ text "Back To Game" ]
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
