var http = require('http');

function sayHello(name) {
    return 'Hello, ' + name + '!';
};

var count = 0;
http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.write('<!doctype html><script>setInterval(' +
            'function(){window.location.reload();},200);</script>');
    res.end('<h1>' + sayHello('Paul') + ' ' + count + '</h1>');
    count++;
}).listen(1234);
