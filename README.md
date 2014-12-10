# real-nock

> Create stubbed `HTTP` servers that you can modify on the fly.

## Sample usage

Say you have a program that queries a backend system, and multiplies its response by 2.
You might want to do some **black-box** testing, spinning up an actual HTTP server
so see how it reacts.

```coffee
Stub = require 'real-nock'

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
```

That's it :smile:

## Why black-box testing?

In many cases, mocking outbound `HTTP` calls is a great option.
However, sometimes you might need to rely on a real backend server:

- if you can to test the actual HTTP connection
- if you want to write tests that are completely independant of the implementations
- if the program you're testing isn't written in `Node`

## That's great, what type of stubs can I set up?

`real-nock` uses [nock](https://github.com/pgte/nock) behind the scenes,
so you should refer to their documentation for all possible operations.

For example:

```coffee
backend.stub
  .get('/')
  .twice()
  .delay(1000)
  .reply(200, 'Hello world')
```
