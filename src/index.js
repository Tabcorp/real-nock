var nock = require('nock');
var url  = require('url');
var httpProxy = require('http-proxy');

var PROXY_HOST = 'stub-nock-proxy-host';
var PROXY_COUNT = 0;

module.exports = Stub;

function Stub(opts) {
  this.host = PROXY_HOST + (++PROXY_COUNT);
  this.port = opts.port;
  this.stub = nock('http://' + this.host + ':9999');
  this.server = httpProxy.createProxyServer({
    target: 'http://' + this.host + ':9999'
  });
  this.server.on('error', function(err, req, res) {
    res.writeHead(404);
    res.end('Stub not implemented');
  });
}

Stub.prototype.start = function(done) {
  this.server.listen(this.port, done);
};

Stub.prototype.stop = function(done) {
  this.server.close(done);
};

Stub.prototype.reset = function() {
  this.stub.pendingMocks().forEach(function(mock) {
    var u = url.parse(mock.replace(/^[A-Z]+ /, ''));
    nock.removeInterceptor({
      hostname: u.hostname,
      path: u.path,
      port: 9999
    });
  });
};
