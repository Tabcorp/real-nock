unirest = require 'unirest'
Stub = require '../src/index'

describe 'behaviour for unknown stubs', ->

  backend = new Stub(port: 9000)

  before (done) -> backend.start(done)
  after  (done) -> backend.stop(done)
  beforeEach    -> backend.reset()

  it 'ignores them by default (connection will timeout)', (done) ->
    backend.default = null
    unirest.get('http://localhost:9000/users/1')
           .timeout(10)
           .end (res) ->
             res.error.code.should.eql 'ETIMEDOUT'
             done()

  it 'can be configured to send a custom status code', (done) ->
    backend.default = 404
    unirest.get('http://localhost:9000/users/1')
           .end (res) ->
             res.status.should.eql 404
             done()

  it 'can be configured to reset the connection', (done) ->
    backend.default = 'reset'
    unirest.get('http://localhost:9000/users/1')
           .end (res) ->
             res.error.code.should.eql 'ECONNRESET'
             res.error.message.should.eql 'socket hang up'
             done()

  it 'can be configured to apply a custom function', (done) ->
    backend.default = (req, res) -> res.end('hello')
    unirest.get('http://localhost:9000/users/1')
           .end (res) ->
             res.body.should.eql('hello')
             done()
