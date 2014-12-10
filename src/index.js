var http = require('http');
var nock = require('nock');
var url  = require('url');
var httpProxy = require('http-proxy');

var PROXY_HOST = 'stub-nock-proxy-host';
var PROXY_COUNT = 0;

module.exports = Stub;

function Stub(opts) {
  var self = this;
  this.host = PROXY_HOST + (++PROXY_COUNT);
  this.port = opts.port;
  this.stub = nock('http://' + this.host + ':9999');
  this.proxy = httpProxy.createProxyServer({
    target: 'http://' + this.host + ':9999'
  });
  this.server = http.createServer(function(req, res, next) {
    self.proxy.web(req, res, {});
  });
}

Stub.prototype.start = function(done) {
  console.log('Starting local server: http://localhost:' + this.port);
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
      path: u.path
    });
  });
};
