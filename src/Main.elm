port module Main exposing (main)
import Route exposing (Route)
import Browser
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
import Model exposing (..)
import Show exposing (..)
import Login exposing(..)


init : String -> ( Model, Cmd Msg )
init flag =
    let
        root = Auth initdata
    in 
        ( root, Cmd.none )

type Model
    = Auth AuthModel
    | Shows ShowsModel

initdata : AuthModel
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
    , activeTab = LoggingInTab
    , loadState = Loading.Off
    }

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
    --loginResult DoneLogin
    --  showResults ShowResults



-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case  ( msg, model ) of
    ( GotLoginMsg subMsg, Auth amdl ) ->     
        loginUpdate subMsg amdl |>
            updateWith Auth GotLoginMsg model
    ( GotShowMsg subMsg, Shows smdl ) ->     
        showUpdate subMsg smdl |>
            updateWith Shows GotShowMsg model
    ( GotLoginMsg _, Shows _) ->
        (model, Cmd.none)
    ( GotShowMsg _, Auth _ ) ->
        (model,Cmd.none)

-- For update function
updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )
  

showUpdate : ShowMsg -> ShowsModel -> ( ShowsModel, Cmd ShowMsg )
showUpdate msg model =
    case msg of
        ShowResults  ->
            (model, Cmd.none)
        
-- (a -> msg) -> Cmd a -> Cmd msg
loginUpdate : LoginMsg -> AuthModel -> ( AuthModel, Cmd LoginMsg )
loginUpdate msg model =
    case msg of
        TabNavigate tab ->
            updateTab tab model
          
        DoneLogin data ->
            case data.isLoggedIn of
                True ->
                    ( { model
                        | loginResult = data
                        , activeTab = LoggedInTab
                        , loadState = Loading.Off
                      }
                    , Cmd.none
                    )

                False ->
                    ( { model
                        | loginResult = data
                        , loadState = Loading.Off
                      }
                    , Cmd.none
                    )

        UpdateNewConfirmPassword pswd ->
            let
                li =
                    model.userInfo
            in
            ( { model | userInfo = { li | passwordConfimation = pswd } }, Cmd.none )

        UpdatePassword pswd ->
            let
                li =
                    model.userInfo
            in
            ( { model | userInfo = { li | password = pswd } }, Cmd.none )

        UpdateNewPassword pswd ->
            let
                li =
                    model.userInfo
            in
            ( { model | userInfo = { li | password = pswd } }, Cmd.none )

        UpdateUserName usrname ->
            let
                li =
                    model.userInfo
            in
            ( { model | userInfo = { li | userName = usrname } }, Cmd.none )

        StartLoginOrCancel ->
          if model.loadState == Loading.Off then 
            ( { model
                | loginResult =
                    { isLoggedIn = False
                    , address = "-"
                    , message = ""
                    }
                , loadState = Loading.On
                 
              }
            , loginUser model.userInfo
            ) 
            else
              ({ model | loadState = Loading.Off } , Cmd.none )  

        Logout ->
            ( initdata, logoutUser model.userInfo )

        RegisterUser ->
            ( model, registerUser model.userInfo )



view : Model -> Html Msg
view model =
    let
        toView mdl =
            case mdl of
                Shows smdl->
                    Html.map GotShowMsg  (showsView smdl)                    
                Auth amdl ->
                    Html.map GotLoginMsg  (tabView amdl)
    in
    div [ id "root" ]
        [ div [ class "app" ]
            [ model |> toView    ]
        ]

main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }

-- Outgoing ports
port registerUser : UserInfo -> Cmd msg
port loginUser : UserInfo -> Cmd msg
port logoutUser : UserInfo -> Cmd msg
port startLoadShows : UserInfo -> Cmd msg

-- Incoming Ports
port loginResult : (LoginResultInfo -> msg) -> Sub msg
port showResults : (List ShowInfo -> msg) -> Sub msg