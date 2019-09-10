port module Main exposing (main)
import Show as Show
import Login as Login

import Json.Decode as Decode exposing (Value)
import Browser
import Browser.Navigation as Nav
import Url exposing (Url)
import Html exposing (..)
import Browser exposing (Document)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as E
import Loading
    exposing
        ( LoaderType(..)
        , defaultConfig
        , render
        )
import Http exposing (..)

type Msg = GotAuth Login.Msg
           | GotShow  Show.Msg
           | DoneLogin Login.LoginResultInfo
           | Logout


init : String -> ( Model, Cmd Msg )
init flag =
    let
        root = Auth initdata
    in 
        ( root, Cmd.none )

type Model
    = Auth Login.Model
    | Shows Show.Model

initShowsData : Show.Model
initShowsData = { showInfos = []}

initdata : Login.Model
initdata =
    { loginResult =
        { isLoggedIn = False
        , address = "-"
        , message = ""
        }
    , userInfo =
        { userName = ""
        , password = ""
        , passwordConfimation = ""
        }
    , activeTab = Login.LoggingInTab
    , loadState = Loading.Off
    }

getTvShows : Cmd Msg
getTvShows =
    Cmd.none
--   Http.get
--     { url = "https://api.themoviedb.org/3/discover/tv?api_key=6aec6123c85be51886e8f69cd9a3a226&first_air_date.gte=2019-01-01&page=1"
--     , expect = Http.expectJson GotShow (Show.ShowsResult Show.listOfShowsDecoder)
--     }

subscriptions : Model -> Sub Msg
subscriptions model =
   Sub.batch [
        hedgeHogloginResult DoneLogin 
    ]
    -- case model of
    --     Auth auth ->
    --         Sub.map GotAuth (Login.subscriptions auth)
    --     Shows shows ->
    --         Sub.map GotShow (Show.subscriptions shows)

    
    --  

-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotAuth loginMsg ->
            (model, Cmd.none)
        GotShow shwMsg ->
            (model, Cmd.none)
        DoneLogin  res ->
            (model, Cmd.none)
        Logout ->
            (model, Cmd.none)


        -- GotShows result ->
        --     case result of
        --         Ok shows ->
        --             (Shows { initShowsData | showInfos = shows }, Cmd.none)
        --         Err _ ->
        --             case  model  of
        --                 Auth amdl  ->
        --                     (model, Cmd.none)
        --                 _ ->
        --                     (model, Cmd.none)
                    
        -- Logout ->
        --     (Auth initdata, logoutUser "logging out..." ) 
        -- _ ->
        --     case  model  of
        --         Auth amdl  ->
        --             loginUpdate msg amdl |> 
        --                     updateWith Auth    
        --         Shows smdl  -> 
        --             showUpdate msg smdl |>
        --                 updateWith Shows 
                                        
-- updateWith : (subModel -> Model)   -> ( subModel, Cmd Msg ) -> ( Model, Cmd Msg )
-- updateWith toModel   ( subModel, cmd ) =
--     ( toModel subModel
--     , cmd
--     )


-- showUpdate : Msg -> ShowsModel -> ( ShowsModel, Cmd Msg )
-- showUpdate msg model =
--     case msg of
--         _ ->  
--             (model, Cmd.none)

        
-- -- (a -> msg) -> Cmd a -> Cmd msg
-- loginUpdate : Msg -> AuthModel -> ( AuthModel, Cmd Msg )
-- loginUpdate msg model =
--     case msg of
--         TabNavigate tab ->
--             updateTab tab model          
--         DoneLogin data ->
--             case data.isLoggedIn of
--                 True ->
--                     ( { model
--                         | loginResult = data
--                         , loadState = Loading.Off
--                       }
--                     , getTvShows
--                     )  

--                 False ->
--                     ( { model
--                         | loginResult = data
--                         , loadState = Loading.Off
--                       }
--                     , Cmd.none
--                     ) 

--         UpdateNewConfirmPassword pswd ->
--             let
--                 li =
--                     model.userInfo
--             in
--             ( { model | userInfo = { li | passwordConfimation = pswd } }, Cmd.none ) 

--         UpdatePassword pswd ->
--             let
--                 li =
--                     model.userInfo
--             in
--             ( { model | userInfo = { li | password = pswd } }, Cmd.none ) 

--         UpdateNewPassword pswd ->
--             let
--                 li =
--                     model.userInfo
--             in
--             ( { model | userInfo = { li | password = pswd } }, Cmd.none ) 

--         UpdateUserName usrname ->
--             let
--                 li =
--                     model.userInfo
--             in
--             ( { model | userInfo = { li | userName = usrname } }, Cmd.none ) 

--         StartLoginOrCancel ->
--           if model.loadState == Loading.Off then 
--             ( { model
--                 | loginResult =
--                     { isLoggedIn = False
--                     , address = "-"
--                     , message = ""
--                     }
--                 , loadState = Loading.On
                 
--               }
--             , loginUser model.userInfo
--             ) 
--             else
--               ({ model | loadState = Loading.Off } , Cmd.none )  


--         RegisterUser ->
--             ( model, registerUser model.userInfo )         
--         _ ->
--            (model,  Cmd.none)  

view : Model -> Html Msg
view model =
    let
        toView mdl =
            case mdl of
                Shows smdl->
                    Show.showsView smdl |> Html.map GotShow                   
                Auth amdl ->
                    Login.tabView amdl |> Html.map GotAuth
    in
    div [ id "root" ]
        [ div [ class "app" ]
            [ model |> toView    ]
        ]

-- main : Program Value Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }

-- Outgoing ports
port registerUser : Login.UserInfo -> Cmd msg
port loginUser : Login.UserInfo -> Cmd msg
port logoutUser : String -> Cmd msg

-- Incoming Ports
port hedgeHogloginResult : (Login.LoginResultInfo -> msg) -> Sub msg
