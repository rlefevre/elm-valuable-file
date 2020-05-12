port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder, Value)
import ValuableFile exposing (ValuableFile)
import ValuableFile.Input as Input



-- MODEL


type alias Model =
    List ( ValuableFile, String )



-- VIEW


view : Model -> Html Msg
view files =
    div []
        [ Input.file [ Input.onFile FileSelected ] []
        , ul [] (List.map viewFile files)
        ]


viewFile : ( ValuableFile, String ) -> Html msg
viewFile ( file, hash ) =
    li []
        [ text (ValuableFile.name file)
        , br [] []
        , text hash
        ]



-- PORTS


port gotFile : (Value -> msg) -> Sub msg


port sendFile : Value -> Cmd msg



-- UPDATE


type Msg
    = FileSelected ValuableFile
    | FileReceived (Result Decode.Error ( ValuableFile, String ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileSelected file ->
            ( model, sendFile <| ValuableFile.encode file )

        FileReceived (Ok ( file, hash )) ->
            ( ( file, hash ) :: model, Cmd.none )

        FileReceived (Err _) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    gotFile (Decode.decodeValue decodeFile >> FileReceived)


decodeFile : Decoder ( ValuableFile, String )
decodeFile =
    Decode.map2 Tuple.pair
        (Decode.at [ "file" ] ValuableFile.decoder)
        (Decode.at [ "hash" ] Decode.string)



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = always ( [], Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
