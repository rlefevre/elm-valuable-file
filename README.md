# ValuableFile

Similar to [elm/file](https://package.elm-lang.org/packages/elm/file/latest)
[`File`](https://package.elm-lang.org/packages/elm/file/latest/File#File)
but can be decoded **and encoded** to go through ports as a
[JavaScript File](https://developer.mozilla.org/en-US/docs/Web/API/File).

## Roundtrip Through Ports Example
Maybe you want to process a file in javascript? Maybe you need to get the
result back in Elm, for example to send it later with
[elm/http](https://package.elm-lang.org/packages/elm/http/latest)?

```elm
port module Main exposing (main)

import Browser
import Html exposing (..)
import Json.Decode as Decode exposing (Decoder)
import ValuableFile exposing (ValuableFile)
import ValuableFile.Input as Input


port gotFile : (Decode.Value -> msg) -> Sub msg


port sendFile : Decode.Value -> Cmd msg


type alias Model =
    Maybe ValuableFile


view : Model -> Html Msg
view model =
    div []
        [ Input.file [ Input.onFile FileSelected ] []
        , case model of
            Just file ->
                div [] [ text (ValuableFile.name file) ]

            Nothing ->
                text ""
        ]


type Msg
    = FileSelected ValuableFile
    | FileReceived (Result Decode.Error ValuableFile)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileSelected file ->
            ( model
            , sendFile (ValuableFile.encode file)
            )

        FileReceived (Ok file) ->
            ( Just file, Cmd.none )

        FileReceived (Err _) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    gotFile (Decode.decodeValue ValuableFile.decoder >> FileReceived)


main : Program () Model Msg
main =
    Browser.element
        { init = always ( Nothing, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
```

The HTML and JavaScript code with ports is straighforward:
```html
<html lang="en">
<head>
  <meta charset="utf8">
  <script src="elm.js"></script>
</head>
<body>
  <main></main>
  <script>
    var app = Elm.Main.init({ node: document.querySelector('main') })
    app.ports.sendFile.subscribe(function(file) {
      // Process the file here, then send the result back:
      app.ports.gotFile.send(file);
    });
  </script>
</body>
</html>
```
