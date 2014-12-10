unirest = require 'unirest'
Stub = require '../src/index'

describe 'unit tests', ->

  backend = new Stub(port: 6789)

  before (done) -> backend.start(done)
  after  (done) -> backend.stop(done)
  beforeEach    -> backend.reset()

  it 'can set up a stub for a given route', (done) ->
    backend.stub.get('/users/1').reply(200, name: 'Alice')
    unirest.get('http://localhost:6789/users/1')
           .end (res) ->
             res.error.should.eql(false)
             res.body.should.eql(name: 'Alice')
             done()

  it 'can setup multiple stubs with conditions', (done) ->
    backend.stub.post('/users', name: 'Alice').reply(200, id: 1)
    backend.stub.post('/users', name: 'Bob'  ).reply(200, id: 2)
    unirest.post('http://localhost:6789/users')
           .send(name: 'Bob')
           .end (res) ->
             res.error.should.eql(false)
             res.body.should.eql(id: 2)
             done()

  describe 'unknown routes', ->

    it 'ignores them by default (connection will timeout)', (done) ->
      backend.default = null
      unirest.get('http://localhost:6789/users/1')
             .timeout(10)
             .end (res) ->
               res.error.code.should.eql 'ETIMEDOUT'
               done()

    it 'can be configured to send a custom status code', (done) ->
      backend.default = 404
      unirest.get('http://localhost:6789/users/1')
             .end (res) ->
               res.should.have.status(404)
               done()

    it 'can be configured to reset the connection', (done) ->
      backend.default = 'reset'
      unirest.get('http://localhost:6789/users/1')
             .end (res) ->
               res.error.code.should.eql 'ECONNRESET'
               res.error.message.should.eql 'socket hang up'
               done()

    it 'can be configured to apply a custom function', (done) ->
      backend.default = (req, res) -> res.end('hello')
      unirest.get('http://localhost:6789/users/1')
             .end (res) ->
               res.body.should.eql('hello')
               done()
