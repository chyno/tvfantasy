module Page.Game exposing (Model, Msg(.. ), init, subscriptions, update, view)
import Html exposing (..)

type Msg = Foo
type Model = Some String


init : String  -> ( Model, Cmd Msg )
init username = 
    (Some username, Cmd.none )

-- Subcriptions
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    (model, Cmd.none)

-- View
view : Model -> Html Msg
view model =  
    div[][]