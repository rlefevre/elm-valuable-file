This is an example of an Elm program that uses ports and a web worker to compute asynchronously and in parallel the MD5 of several files in chunks of 2MB.

#### Notes
* The file is selected from Elm and available in the Model once its MD5 has been computed
* No custom element is used
* The file is read only once in chunks to compute its MD5
