#!/usr/local/bin/coffee
fs = require 'fs'
chalk = require 'chalk'
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

files = fs.readdirSync(__dirname).filter (name) -> name.match /\.json$/
for file in files
	data = JSON.parse(fs.readFileSync(__dirname+'/'+file))
	name = file.match(/^(.*)\.json$/)[1]
	test(name, data)
