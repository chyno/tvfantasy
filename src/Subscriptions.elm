port module Subscriptions exposing (..)
import Model exposing (..)

subscriptions : Model -> Sub Msg
subscriptions model =
    loginResult DoneLogin

port loginResult : (LoginResultInfo -> msg) -> Sub msg
--  port showResults : (List ShowInfo -> msg) -> Sub msg