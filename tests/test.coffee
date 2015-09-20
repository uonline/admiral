#!/usr/local/bin/coffee
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



test = (eventName, data) ->
	response_text = 'not assigned'
	robot = makeRobot (room, msg) ->
		console.log "#{green '>>>'} #{yellow eventName} #{green Array(60-1-name.length).join '-'}"
		console.log "#{magenta 'response:'} #{response_text}"
		console.log "#{magenta 'room:'} #{room}"
		console.log magenta 'message:'
		console.log msg
		console.log green ">>> #{Array(60).join '-'}"
		console.log ''
	
	ghScript(robot)
	
	ghHandler(
		{ headers: { 'x-github-event': eventName }, body: data }
		{ send: (text) -> response_text = text }
	)

httptest = ->
	t = files.pop()
	if not t?
		return
	name = t.match(/^(.*)\.json$/)[1]
	t = "#{__dirname}/#{t}"
	console.log "#{green '>>>'} #{yellow name} #{green Array(60-1-name.length).join '-'}"
	options =
		method: 'POST'
		uri: 'http://localhost:3217/hubot/github'
		headers:
			'x-github-event': name
	fs.createReadStream(t).pipe request.post options, (error, response, body) ->
		if error?
			console.log error
			return
		if response.statusCode != 200
			console.log "Status code is #{response.statusCode}, expected 200"
			return
		httptest()

USE_HTTP = false

files = fs.readdirSync(__dirname).filter (name) -> name.match /\.json$/
if USE_HTTP
	files = files.reverse()
	httptest()
else
	for file in files
		data = JSON.parse(fs.readFileSync(__dirname+'/'+file))
		name = file.match(/^(.*)\.json$/)[1]
		test(name, data)
