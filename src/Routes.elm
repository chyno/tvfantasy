module Routes exposing (Route(..), parseUrl, showsPath, loginPath, playGamePath)

import Url exposing (Url)
import Url.Parser exposing (..)
import Url.Parser.Query as Query

type Route
    = ShowsRoute
    | LoginRoute
    | PlayGameRoute String
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LoginRoute top
       , map ShowsRoute (s "shows")
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
        ShowsRoute ->
            "/shows"
        LoginRoute ->
            "/login"         
        PlayGameRoute userName ->
            "/playgame/" ++ userName
        NotFoundRoute ->
            "/"

loginPath =
    pathFor LoginRoute

showsPath =
    pathFor ShowsRoute


playGamePath userName =
    pathFor (PlayGameRoute userName)