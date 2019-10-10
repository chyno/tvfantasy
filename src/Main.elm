port module Main exposing (init, main, subscriptions)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Page.Login as Login
import Page.Show as Show
import Page.Game as Game
import Routes exposing (Route)
import Shared exposing (..)
import Url exposing (Url)
import Material
import Material.Button as Button
import Material.Options as Options

type alias Model =
    { flags : Flags
    , navKey : Key
    , route : Route
    , page : Page
    , userName : String
    , mdc : Material.Model Msg
    }


type Page
    = PageNone
    | PageLogin Login.Model
    | PageShow Show.Model
    | PageGame Game.Model


type Msg
    = OnUrlChange Url
    | LinkClicked UrlRequest
    | LoginMsg Login.Msg
    | ShowMsg Show.Msg
    | GameMsg Game.Msg
    | Logout
    | Mdc (Material.Msg Msg)



init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        ( lgModel, lgCmd ) =  Login.init navKey

        model =
            { flags = flags
            , navKey = navKey
            , route = Routes.parseUrl url
            , page =   PageLogin lgModel
            , userName = ""
            , mdc = Material.defaultModel
            }
    in
       loadCurrentPage  ( model, Material.init Mdc )


loadCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
loadCurrentPage ( model, cmd ) =
    case model.route of
        Routes.ShowsRoute ->
            let
                ( pageModel, pageCmd ) = Show.init model.flags
            in
             ( { model | page = PageShow pageModel }, Cmd.batch [ cmd, (Cmd.map ShowMsg pageCmd) ] )
                    -- ( PageShow pageModel, Cmd.map ShowMsg pageCmd )

        Routes.LoginRoute ->
            let
                ( pageModel, pageCmd ) = Login.init model.navKey
            in
                ( { model | page = PageLogin pageModel }, Cmd.batch [ cmd,  (Cmd.map LoginMsg pageCmd) ] )
                    -- ( PageLogin pageModel, Cmd.map LoginMsg pageCmd )

        Routes.GameRoute  maybeVal->
            let
                mdl = case maybeVal of
                        Just val ->
                            {model | userName = val}
                        Nothing  ->
                            model 

                (pageModel, pageCmd ) = Game.init
            in
                ( { mdl | page = PageGame pageModel }, Cmd.batch [ cmd,  (Cmd.map GameMsg pageCmd) ] )
                        -- ( PageGame pageModel, Cmd.map GameMsg pageCmd )
    
        Routes.ShowRoute showId ->
            ( { model | page = PageNone }, Cmd.none )
                    -- ( PageNone, Cmd.none )

        Routes.NotFoundRoute ->
            ( { model | page = PageNone }, Cmd.none )
                    -- ( PageNone, Cmd.none )
    -- in
    -- ( { model | page = page }, Cmd.batch [ cmd, newCmd ] )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSubs = 
            case model.page of
                PageLogin pageModel ->
                    Sub.map LoginMsg (Login.subscriptions pageModel)

                PageShow pageModel ->
                    Sub.map ShowMsg (Show.subscriptions pageModel)
                PageGame pageModel ->
                    Sub.map GameMsg (Game.subscriptions pageModel)
                PageNone ->
                    Sub.none
    in
        Sub.batch[pageSubs, Material.subscriptions Mdc model]
        

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdc msg_ ->
            Material.update Mdc msg_ model
        _ ->
            case ( msg, model.page ) of
                ( LinkClicked urlRequest, _ ) ->
                    case urlRequest of
                        Browser.Internal url ->
                            ( model
                            , Nav.pushUrl model.navKey (Url.toString url)
                            )

                        Browser.External url ->
                            ( model
                            , Nav.load url
                            )
                ( OnUrlChange url, _ ) ->
                    let
                        newRoute =
                            Routes.parseUrl url
                        
                    in
                    ( { model | route = newRoute}, Cmd.none )
                        |> loadCurrentPage
                ( LoginMsg subMsg, PageLogin pageModel ) ->
                    let
                        ( newPageModel, newCmd ) =
                            Login.update  subMsg pageModel
                    in
                    ( { model | page = PageLogin newPageModel }
                    , Cmd.map LoginMsg newCmd
                    )
                (ShowMsg subMsg, PageShow pageModel ) ->
                    let
                        ( newPageModel, newCmd ) =
                            Show.update  subMsg pageModel
                    in
                    ( { model | page = PageShow newPageModel }
                    , Cmd.map ShowMsg newCmd
                    )
                (GameMsg subMsg, PageGame pageModel ) ->
                    let
                        ( newPageModel, newCmd ) =
                            Game.update  subMsg pageModel
                    in
                    ( { model | page = PageGame newPageModel }
                    , Cmd.map GameMsg newCmd
                    )
                (Logout, _) ->
                    let
                        ( lgModel, lgCmd ) =  Login.init model.navKey
                    in
                        ({model | page = PageLogin lgModel, userName = ""}, logoutUser  "Logout")
                (_,_ )  ->
                    Debug.todo "loginmsg pageshow"

main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = OnUrlChange
        }

-- VIEWS
view : Model -> Browser.Document Msg
view model =
    let
        hdrVw =  case model.page of
                        PageLogin _ ->
                            loginHeaderView
                        _ ->
                            (headerView model)

    in
    
    { title = "App"
    , body = [ 
        div[ class "wrapper" ][
             div[class "box header"] [hdrVw]
            , div [class "box sidebar"][text "Sidebar"]
            , div [class "box content"] [currentPage model]
            , div [class "box footer"] [footerView]
        ]
        
    ]
    }


currentPage : Model -> Html Msg
currentPage model =
    case model.page of
        PageLogin pageModel ->
            Login.view pageModel
                |> Html.map LoginMsg
        PageShow pageModel ->
            Show.view pageModel
                |> Html.map ShowMsg
        PageGame pageModel ->
            Game.view pageModel
                |> Html.map GameMsg
        PageNone ->
            notFoundView
    



notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found..."
        ]

loginHeaderView: Html msg
loginHeaderView =
    nav [ class "navbar is-white" ]
    [ div [ class "container" ]
        [ div [ class "navbar-brand" ]
            [ a [ class "navbar-item brand-text", href "../" ]
                [ text "Tv Fantasy Network        " ]
            , div [ class "navbar-burger burger", attribute "data-target" "navMenu" ]
                [ span []
                    []
                , span []
                    []
                , span []
                    []
                ]
            ]
        , div [   id "navMenu" ]
            [ ]
        ]
    ]

headerView: Model ->  Html Msg
headerView model = 
    nav [ class "navbar is-white" ]
    [ div [ class "container" ]
        [ div [ class "navbar-brand" ]
            [ a [ class "navbar-item brand-text", href "../" ]
                [ text "Tv Fantasy Network        " ]
            , div [ class "navbar-burger burger", attribute "data-target" "navMenu" ]
                [ span []
                    []
                , span []
                    []
                , span []
                    []
                ]
            ]
        , div [ class "navbar-menu", id "navMenu" ]
            [ div [ class "navbar-start" ]
                [ a [ class "navbar-item", href "game" ]
                    [ text "Home          " ]
                , a [ class "navbar-item", href "shows" ]
                    [ text "Shows          " ]
                , a [ class "navbar-item", href "#" ]
                    [ text "Status          " ]
                , a [ class "navbar-item", href "#" ]
                    [ text "Past Games          " ]
                ]
            ]
        , span [][text model.userName]
        ,  Button.view Mdc "my-button" model.mdc
              [ Button.ripple
              , Options.onClick Logout
              ]
              [ text "Logout" ]
        ]
    ]

footerView : Html msg
footerView =
    footer [ class "footer" ]
    [ div [ class "content has-text-centered" ]
        [ p []
            [ strong []
                [ text "TV Fantasy  " ]
            , text " by "
            , a [ href "https://www.chynologic.com" ]
                [ text "John Chynoweth" ]
            , text ". The source code is licensed      "
            , a [ href "http://opensource.org/licenses/mit-license.php" ]
                [ text "MIT" ]
            , text ". The website content is licensed "
            , a [ href "http://creativecommons.org/licenses/by-nc-sa/4.0/" ]
                [ text "CC BY NC SA 4.0" ]
            , text ".    "
            ]
        ]
    ]

port logoutUser :   String -> Cmd msg
