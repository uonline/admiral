# Description:
#   Find the build status of an open-source project on Travis
#   Can also notify about builds, just enable the webhook notification on travis http://about.travis-ci.org/docs/user/build-configuration/ -> 'Webhook notification'
#
# Dependencies:
#
# Configuration:
#   None
#
# Commands:
#   hubot does it pass - Returns the build status of uonline
#   hubot is it broken - Returns the build status of uonline
#   hubot travis me <user>/<repo> - Returns the build status of https://github.com/<user>/<repo>
#
# URLS:
#   POST /hubot/travis?room=<room>[&type=<type]
#     - for XMPP servers (such as HipChat) this is the XMPP room id which has the form id@server
#
# Author:
#   sferik
#   nesQuick
#   sergeylukin

url = require('url')
querystring = require('querystring')

go = (msg, project) ->
  msg.http("https://api.travis-ci.org/repos/#{project}")
      .get() (err, res, body) ->
        response = JSON.parse(body)
        if response.last_build_status == 0
          msg.send "Build status for #{project}: Passing"
        else if response.last_build_status == 1
          msg.send "Build status for #{project}: Failing"
        else
          msg.send "Build status for #{project}: Unknown"


module.exports = (robot) ->

  robot.respond /travis me (.*)/i, (msg) ->
    project = escape(msg.match[1])
    go(msg, project)

  robot.respond /does it pass/i, (msg) ->
    go(msg, 'uonline/uonline')
  robot.respond /is it broken/i, (msg) ->
    go(msg, 'uonline/uonline')

  robot.router.post "/hubot/travis", (req, res) ->
    query = querystring.parse url.parse(req.url).query

    user = {}
    user.room = query.room if query.room
    user.type = query.type if query.type

    try
      payload = JSON.parse req.body.payload

      robot.send user, "#{payload.status_message.toUpperCase()} build (#{payload.build_url}) on #{payload.repository.name}:#{payload.branch} by #{payload.author_name} with commit (#{payload.compare_url})"

    catch error
      console.log "travis hook error: #{error}. Payload: #{req.body.payload}"

    res.end JSON.stringify {
      send: true #some client have problems with and empty response, sending that response ion sync makes debugging easier
    }
