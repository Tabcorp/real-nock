program = require './test-program'
Stub = require '../src/index'

describe 'my program', ->

  backend = new Stub(port: 6789)

  before (done) -> backend.start(done)
  after  (done) -> backend.stop(done)
  beforeEach    -> backend.reset()

  it 'multiplies the backend response by 2', (done) ->
    backend.stub.get('/value').reply(200, value: 4)
    program.multiply (err, val) ->
      val.should.eql 8
      done()

  it 'also works for large numbers', (done) ->
    backend.stub.get('/value').reply(200, value: 10000)
    program.multiply (err, val) ->
      val.should.eql 20000
      done()

  it 'fails gracefully when the backend is down', (done) ->
    backend.stub.get('/value').delayConnection(1000).reply('down')
    program.multiply (err, val) ->
      err.message.should.eql 'Failed to call backend'
      done()
