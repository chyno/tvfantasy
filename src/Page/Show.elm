module Page.Show exposing (Model, view, Msg(..), update, subscriptions, initShowsData)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Loading exposing (LoadingState)
import Model exposing (..)



type Msg
    =   InitShows
    | ShowsResult (Result Http.Error (List Model.ShowInfo))


-- Model


type alias Model =
    { showInfos : List ShowInfo
    }

initShowsData : Model
initShowsData = 
    {
        showInfos = []
    }

getTvShows : Cmd Msg
getTvShows =
    Http.get
        { url = "https://api.themoviedb.org/3/discover/tv?api_key=6aec6123c85be51886e8f69cd9a3a226&first_air_date.gte=2019-01-01&page=1"
        , expect = Http.expectJson ShowsResult Model.listOfShowsDecoder
        }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitShows ->
            (model, getTvShows)
        ShowsResult result ->
            case result of
                Ok shows ->
                    ({ model | showInfos = shows }, Cmd.none)
                Err _ ->
                    (model, Cmd.none)
         
             


-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



loadingView :  Html Msg
loadingView  =
    div[][text "Loading ...."]

view : Model -> Html Msg
view model =
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
                :: List.map showDetails model.showInfos
            )
        , div [ class "button" ] [ text "Log Out" ]
        ]



-- , onClick  Logout
-- , onClick StartLogout
