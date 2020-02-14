module Routes exposing (Route(..), parseUrl, loginPath, playGamePath)

import Url exposing (Url)
import Url.Parser exposing (..)
import Url.Parser.Query as Query

type Route
    = LoginRoute
    | PlayGameRoute String
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LoginRoute top
        , map PlayGameRoute (s "playgame" </> string)
        , map LoginRoute (s "login")
        ]


parseUrl : Url -> Route
parseUrl url =
    case parse matchers url of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


pathFor : Route -> String
pathFor route =
    case route of
        LoginRoute ->
            "/login"         
        PlayGameRoute userName ->
            "/playgame/" ++ userName
        NotFoundRoute ->
            "/"

loginPath =
    pathFor LoginRoute


playGamePath userName =
    pathFor (PlayGameRoute userName)
