module Routes exposing (Route(..), parseUrl, showPath, showsPath, loginPath)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = ShowsRoute
    | ShowRoute String
    | LoginRoute
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LoginRoute top
        , map ShowRoute (s "shows" </> string)
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
        ShowRoute id ->
            "/show/" ++ id

        NotFoundRoute ->
            "/"

loginPath =
    pathFor LoginRoute

showsPath =
    pathFor ShowsRoute


showPath id =
    pathFor (ShowRoute id)
