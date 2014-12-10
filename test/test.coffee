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

  it 'returns a 404 if the stub is not defined', (done) ->
    unirest.get('http://localhost:6789/users/1')
           .end (res) ->
             res.should.have.status(404)
             done()
