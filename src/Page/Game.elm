module Page.Game exposing (Model, view, Msg(..), update, subscriptions, init)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Routes exposing (showsPath)
import Shared exposing (..)

init : ( Model, Cmd Msg )
init  =
    ( { networks = ["ABC", "NBC", "CBS", "ESPN"]}, Cmd.none )

--Model


type alias Model =
    { 
     networks: List String
    }

-- Msg
type Msg = NavigateShows

--Subcriptions
-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

--Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavigateShows ->
            (model, (Nav.load  Routes.showsPath) )


-- View
view : Model -> Html Msg
view model =
    div[][
        h3[][text "Manage Your Network"]
        , div   [ class "field" ]
                [ label [ class "label" ] [ text "Available Networks" ]
                , div   [ class "control" ]
                        [ div [ class "select" ]
                            [ select []  (List.map (\x ->  option [] [ text x ]) model.networks)
                            ]
                        ]
                ]   
    ]
    
