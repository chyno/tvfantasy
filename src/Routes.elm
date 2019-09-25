module Routes exposing (Route(..), parseUrl, showPath, showsPath, loginPath, gamePath)

import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = ShowsRoute
    | ShowRoute String
    | LoginRoute
    | GameRoute
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LoginRoute top
       , map ShowsRoute (s "shows")
       , map GameRoute (s "game")
        , map ShowRoute (s "show" </> string)
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
        GameRoute ->
            "/game"
        ShowRoute id ->
            "/show/" ++ id

        NotFoundRoute ->
            "/"

loginPath =
    pathFor LoginRoute

showsPath =
    pathFor ShowsRoute

gamePath =
    pathFor GameRoute


showPath id =
    pathFor (ShowRoute id)
