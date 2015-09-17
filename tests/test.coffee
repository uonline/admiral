#!/usr/local/bin/coffee
fs = require 'fs'
chalk = require 'chalk'
request = require 'request'
ghScript = require '../scripts/m1kc.coffee'

green = chalk.green
magenta = chalk.magenta
yellow = chalk.yellow

ghHandler = null

robot =
	router: { post: (url,func) -> ghHandler = func }
	logger: { info: -> }
	hear: ->
	respond: -> ,
	brain: { get: -> 'test_room_#1' },
	messageRoom: (r,m) -> console.log(magenta('room:')+" #{r}\n"+magenta('message:')+"\n#{m}")

ghScript(robot)

test = (eventName, data) ->
	console.log green(">>>")+yellow(" #{eventName} ")+green(Array(60-1-eventName.length).join('-'))
	ghHandler(
		{ headers:{'x-github-event':eventName}, body:data }
		{ send: (text) -> console.log(magenta('response: ')+text) }
	)
	console.log green '>>> '+Array(60).join('-')+'\n'

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
		headers: {
			'x-github-event': name
		}
	fs.createReadStream(t).pipe request.post options, (error, response, body) ->
		if error?
			console.log error
			return
		if response.statusCode != 200
			console.log "Status code is #{response.statusCode}, expected 200"
			return
		httptest()

USE_HTTP = true

files = fs.readdirSync(__dirname).filter (name) -> name.match /\.json$/
if USE_HTTP
	files = files.reverse()
	httptest()
else
	for file in files
		data = JSON.parse(fs.readFileSync(__dirname+'/'+file))
		name = file.match(/^(.*)\.json$/)[1]
		test(name, data)
