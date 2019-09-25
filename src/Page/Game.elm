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
    ( {adderess = "Hello", game = "game", currentAvail = 1}, Cmd.none )

--Model


type alias Model =
    { adderess: String
    , game: String
    , currentAvail: Int
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
        h3[][text "hello from Game"]
        , div[][
            h3[][text "Your Network"]
            , div[class "control"][
                div[class "select"]
                    [
                        select[][
                            option[][text "NBC"]
                            , option[][text "ABC"]
                        ]
                    ]
            , div[class "control"][
            --    <button class="button is-primary">Submit</button>
                button[class "button is-primary"][text "Choose"]
            ]
            ]
        ] 
        , div [ class "button",  onClick  NavigateShows ] [ text "Choose your Shows" ]
    ]
    
