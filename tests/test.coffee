#!/usr/bin/coffee
fs = require 'fs'
chalk = require 'chalk'
request = require 'request'
ghScript = require '../scripts/m1kc.coffee'

green = chalk.green
magenta = chalk.magenta
yellow = chalk.yellow

ghHandler = null

makeRobot = (onMessage) ->
	robot =
		router:
			post: (url, func) ->
				ghHandler = func
		logger:
			info: ->
		hear: ->
		respond: ->
		brain:
			get: ->
				'wassup_jedi'
		messageRoom: onMessage
	return robot



localtest = (test, data) ->
	response_text = 'not assigned'
	robot = makeRobot (room, msg) ->
		console.log "#{green '>>>'} #{yellow test.name} #{green Array(60-1-test.name.length).join '-'}"
		console.log "#{magenta 'response:'} #{response_text}"
		console.log "#{magenta 'room:'} #{room}"
		console.log magenta 'message:'
		console.log msg
		console.log green ">>> #{Array(60).join '-'}"
		console.log ''
	
	ghScript(robot)
	
	ghHandler(
		{ headers: { 'x-github-event': test.event }, body: data }
		{ send: (text) -> response_text = text }
	)

httptest = ->
	test = tests.pop()
	if not test?
		return
	fname = "#{__dirname}/#{test.fname}"
	console.log "#{green '>>>'} #{yellow test.name} #{green Array(60-1-test.name.length).join '-'}"
	options =
		method: 'POST'
		uri: 'http://localhost:3217/hubot/github'
		headers:
			'x-github-event': test.event
	fs.createReadStream(fname).pipe request.post options, (error, response, body) ->
		if error?
			console.log error
			return
		if response.statusCode != 200
			console.log "Status code is #{response.statusCode}, expected 200"
			return
		httptest()

USE_HTTP = !!process.env['USE_HTTP']

tests = fs.readdirSync(__dirname)
	.filter (name) -> name.match /\.json$/
	.map (name) ->
		m = name.match /^(.*?)(?:__(\d+))?\.json$/
		{fname:name, event:m[1], name:m[1]+(if m[2]? then " (#{m[2]})" else '')}
if USE_HTTP
	tests = tests.reverse()
	httptest()
else
	for test in tests
		data = JSON.parse(fs.readFileSync(__dirname+'/'+test.fname))
		localtest(test, data)
