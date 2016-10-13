unirest  = require 'unirest'
async    = require 'async'
should   = require 'should'
Stub     = require '../src/index'

describe 'stubs', ->

  backend = new Stub(port: 9000, default: 404, debug: true)

  beforeEach (done) ->
    backend.reset()
    backend.start done
    null

  afterEach -> console.log('after each')
  after  -> console.log('after')

  # after (done) ->
  #   console.log('after tests')
  #   backend.stop (err) ->
  #     console.log('backend stop after test', err)
  #     done(err)

  # it 'works', (done) ->
  #   done()

  # it 'can set up a stub for a given route', (done) ->
  #   backend.stub.get('/users/1').reply(200, name: 'Alice')
  #   unirest.get('http://localhost:9000/users/1')
  #          .end (res) ->
  #            res.error.should.eql false
  #            res.status.should.eql 200
  #            res.body.should.eql(name: 'Alice')
  #            done()
  #
  # it 'can setup multiple stubs with conditions', (done) ->
  #   backend.stub.post('/users', name: 'Alice').reply(200, id: 1)
  #   backend.stub.post('/users', name: 'Bob'  ).reply(200, id: 2)
  #   unirest.post('http://localhost:9000/users')
  #          .send(name: 'Bob')
  #          .end (res) ->
  #            res.error.should.eql false
  #            res.status.should.eql 200
  #            res.body.should.eql id: 2
  #            done()
  #
  # it 'consumes stubs so they can only be called once', (done) ->
  #   backend.stub.get('/users/1').reply(200, name: 'Alice')
  #   unirest.get('http://localhost:9000/users/1').end (res) ->
  #     res.status.should.eql 200
  #     unirest.get('http://localhost:9000/users/1').end (res) ->
  #       res.status.should.eql 404
  #       done()
  #
  # it 'can delay responses using the nock API', (done) ->
  #   backend.stub.get('/slow').delayConnection(500).reply(200)
  #   time = Date.now()
  #   unirest.get("http://localhost:9000/slow").end (res) ->
  #     res.status.should.eql 200
  #     total = Date.now() - time
  #     total.should.be.approximately 500, 50
  #     done()
  #
  # it 'can reset all stubbed routes', (done) ->
  #   backend.stub.get('/users/1').reply(200, name: 'Alice')
  #   backend.reset()
  #   unirest.get('http://localhost:9000/users/1').end (res) ->
  #     res.status.should.eql 404
  #     done()
  #
  # it 'has idempotent start/stop methods', (done) ->
  #   async.series [
  #     (next) -> backend.start next
  #     (next) -> backend.start next
  #     (next) -> backend.stop next
  #     (next) -> backend.stop next
  #   ], done

  it 'can shutdown the server while requests are pending', (done) ->
    # backend.stub.get('/users/1').delay(2000).reply(200, name: 'Alice')
    backend.stub.get('/users/1').reply(200, (uri, body, cb) ->
      setTimeout(->
        console.log('timeout callback')
        cb(null, {name: 'alice'})
      , 2000)
    )
    unirest.get('http://localhost:9000/users/1').end (res) ->
      # console.log(res.body)
      res.error.code.should.eql('ECONNRESET')
      done()
      null
    console.log 'shuttingdown'
    shutdown = -> backend.stop (err) ->
      console.log 'sdflksdfjlsdfl'
      should.not.exist(err)
      null
    null
    # shutdown()
    setTimeout(shutdown, 100)
    null
