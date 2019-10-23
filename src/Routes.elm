module Routes exposing (Route(..), parseUrl, showPath, showsPath, loginPath, gamePath, gamePathLogin)

import Url exposing (Url)
import Url.Parser exposing (..)
import Url.Parser.Query as Query

type Route
    = ShowsRoute
    | ShowRoute String
    | LoginRoute
    | GameRoute  (Maybe String)
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LoginRoute top
       , map ShowsRoute (s "shows")
       , map GameRoute (s "game" <?> Query.string "q")
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
        GameRoute un ->
            let
              rtPth = case un of
                  Just val ->
                      "/game?" ++ val
                  option2 ->
                        "/game"
            in
                rtPth
                
        ShowRoute id ->
            "/show/" ++ id

        NotFoundRoute ->
            "/"

loginPath =
    pathFor LoginRoute

showsPath =
    pathFor ShowsRoute

gamePath =
    pathFor (GameRoute Nothing)

gamePathLogin: Int -> String
gamePathLogin val =
    pathFor (GameRoute  (Just  ("q=" ++ String.fromInt val)))


showPath id =
    pathFor (ShowRoute id)
