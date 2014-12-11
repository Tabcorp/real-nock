# real-nock

> Create stubbed HTTP servers that you can modify on the fly.

[![NPM](http://img.shields.io/npm/v/real-nock.svg?style=flat)](https://npmjs.org/package/real-nock)
[![License](http://img.shields.io/npm/l/real-nock.svg?style=flat)](https://github.com/TabDigital/real-nock)

[![Build Status](http://img.shields.io/travis/TabDigital/real-nock.svg?style=flat)](http://travis-ci.org/TabDigital/real-nock)
[![Dependencies](http://img.shields.io/david/TabDigital/real-nock.svg?style=flat)](https://david-dm.org/TabDigital/real-nock)
[![Dev dependencies](http://img.shields.io/david/dev/TabDigital/real-nock.svg?style=flat)](https://david-dm.org/TabDigital/real-nock)

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

  it 'fails gracefully when the backend is slow', (done) ->
    backend.stub.get('/value').delayConnection(1000).reply('slow')
    program.multiply (err, val) ->
      err.message.should.eql 'Failed to call backend'
      done()
```

## Why black-box testing?

In many cases, mocking outbound HTTP calls is a great option.
However, sometimes you might need to rely on a real backend server:

- if you want to test the actual HTTP connection
- if you want to write tests that are completely independant of the implementation
- if the program you're testing isn't written in Node

## That's great, what type of stubs can I set up?

`real-nock` uses [nock](https://github.com/pgte/nock) behind the scenes,
so you should refer to their documentation for all possible operations.
For example:

```coffee
# reply with hello world after 1 second
backend.stub
  .get('/')
  .delay(1000)
  .reply(200, 'Hello world')

# reply with the contents of a file
# if the request payload matches
backend.stub
  .post('/users', name: 'Bob')
  .replyWithFile(200, __dirname + '/bob.json');
```

Note that stubs are consumed as soon as they are called.
Any subsequent call will be considered an *unknown* route,
and trigger the default behaviour (see below).

This allows you to define two stubs in series,
and get the corresponding responses in that order:

```coffee
backend.stub.get('/message').reply(200, 'hello')
backend.stub.get('/message').reply(200, 'goodbye')
```

You can also configure them to apply more than once:

```coffee
backend.stub
  .get('/value')
  .times(5)
  .reply(200, 'hello world')
```

## Default behaviour

By default, the HTTP server will ignore any route that wasn't stubbed explicitly,
or where the stub has been consumed. The corresponding request will get `ETIMEDOUT`.

You can also configure the following:

```coffee
# default behaviour (ETIMEDOUT)
new Stub(port: 6789, default: 'timeout')

# request will get ECONNRESET
new Stub(port: 6789, default: 'reset')

# request will get a custom status code
new Stub(port: 6789, default: 404)

# apply a custom (req, res) function
new Stub(port: 6789, default: myHandler)
```

This behaviour can be changed at runtime by setting the `default` property.

```coffee
backend.default = 'reset'
```

## Troubleshooting

For debugging, you can log most events on the stub server to `stdout`.

```coffee
backend = new Stub(port: 9000, debug: true)
```

which prints

```
[localhost:8001] Starting
[localhost:8001] Started
[localhost:8001] GET /users/1 (not stubbed)
[localhost:8001] GET /users/2 (HTTP 200)
[localhost:8001] Stopping
[localhost:8001] Stopped
```
