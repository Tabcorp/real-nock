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
backend.stub
  .get('/')
  .twice()
  .delay(1000)
  .reply(200, 'Hello world')
```

## Error handling

By default, the HTTP server will ignore any route that wasn't stubbed explicitly
(the corresponding request will get `ETIMEDOUT`).

You can also configure the following:

```coffee
# request will get a custom status code
new Stub(port: 6789, default: 404)

# request will get ECONNRESET
new Stub(port: 6789, default: 'reset')

# apply a custom (req, res) function
new Stub(port: 6789, default: myHandler)
```

This behaviour can be changed at runtime by setting the `default` property.

```coffee
backend.default = 'reset'
```
