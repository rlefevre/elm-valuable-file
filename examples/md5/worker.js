importScripts('https://cdnjs.cloudflare.com/ajax/libs/spark-md5/3.0.0/spark-md5.js');

onmessage = function (e) {
  var file = e.data;
  console.log('Received file', file);

  var blobSlice = File.prototype.slice || File.prototype.mozSlice || File.prototype.webkitSlice,
    // Read in chunks of 2MB
    chunkSize = 2097152,
    chunks = Math.ceil(file.size / chunkSize),
    currentChunk = 0,
    spark = new SparkMD5.ArrayBuffer(),
    fileReader = new FileReader();

  fileReader.onload = function (e) {
    console.log(file.name, 'read chunk', currentChunk + 1, 'of', chunks);
    // Append array buffer
    spark.append(e.target.result);
    currentChunk++;

    if (currentChunk < chunks) {
      loadNext();
    } else {
      console.log(file.name, 'finished loading');
      var md5 = spark.end();
      console.info(file.name, 'computed hash', md5);
      postMessage({ file: file, hash: md5 });
    }
  };

  fileReader.onerror = function () {
    console.warn(file.name, 'oops, something went wrong.');
  };

  function loadNext() {
    var start = currentChunk * chunkSize,
      end = ((start + chunkSize) >= file.size) ? file.size : start + chunkSize;

    fileReader.readAsArrayBuffer(blobSlice.call(file, start, end));
  }

  loadNext();
}
