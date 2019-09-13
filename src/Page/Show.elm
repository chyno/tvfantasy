module Page.Show exposing (Model, view, Msg(..), update, subscriptions, init, ShowInfo)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Loading exposing (LoadingState)
import Shared exposing (..)
import Json.Decode as D
import Json.Encode as E

type Msg =  OnFetchShows (Result Http.Error (List ShowInfo))
    

init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { showInfos = Loading }, fetchShows flags )

-- Model


type alias Model =
    { showInfos : RemoteData (List ShowInfo)
    }

type alias ShowInfo =
    { name : String
    , --   country: String,
      overview : String
    , firstAirDate : String
    , voteAverage : Float
    }

fetchShows : Flags -> Cmd Msg
fetchShows flags =
    Http.get
        { url = flags.api
        , expect = Http.expectJson OnFetchShows listOfShowsDecoder
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnFetchShows (Ok shows) ->
            ( { model | showInfos = Loaded shows }, Cmd.none )
        OnFetchShows (Err err) ->
            ( { model | showInfos = Failure }, Cmd.none )
       


        
-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    let
        content =
            case model.showInfos of
                NotAsked ->
                    text "not asked"

                Loading ->
                    text "Page is Loading "

                Loaded players ->
                    viewWithData players

                Failure ->
                    text "Error"
    in
    section [ class "p-4" ]
        [ content ]

viewWithData : List ShowInfo -> Html Msg
viewWithData shows =
    let
        showDetails =
            \x ->
                tr []
                    [ td [] [ text x.name ]

                    -- ,td[][text x.country]
                    , td [] [ text x.overview ]
                    , td [] [ text x.firstAirDate ]
                    , td [] [ text (String.fromFloat x.voteAverage) ]
                    ]
    in
    div [ class "message" ]
        [ h1 [] [ text "These are your shows:" ]
        , table []
            (tr []
                [ th [] [ text "Name" ]

                -- ,th[][text "Country"]
                , th [] [ text "Description" ]
                , th [] [ text "First Aired" ]
                , th [] [ text "Vote Average" ]
                ]
                :: List.map showDetails shows
            )
        , div [ class "button" ] [ text "Log Out" ]
        ]

showDecoder : D.Decoder ShowInfo
showDecoder =
    D.map4
        ShowInfo
        (D.field "name" D.string)
        -- (D.field "country" D.string))
        (D.field "overview" D.string)
        (D.field "first_air_date" D.string)
        (D.field "vote_average" D.float)


listOfShowsDecoder : D.Decoder (List ShowInfo)
listOfShowsDecoder =
    D.field "results" (D.list showDecoder)

-- , onClick  Logout
-- , onClick StartLogout
