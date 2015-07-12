# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md
#
# Commands:
#   hubot tell me your name - tell you the name
#   hubot talk to me - show your JID as hubot sees it
#   hubot talk to me in private - send you a direct message
#   hubot show me your brain - inspect hubot's brain
#
# Author:
#   m1kc

module.exports = (robot) ->

  robot.hear //i, (msg) ->
    console.log require('util').inspect msg.message

  robot.hear /tell me your name/i, (msg) ->
    msg.reply 'My name is Admiral Kunkka!'

  robot.respond /talk to me$/i, ( msg ) ->
    # Simply reply
    msg.reply "Hello #{msg.envelope.user.name}. Your private JID is #{msg.envelope.user.privateChatJID}"

  robot.respond /glory/i, ( msg ) ->
    msg.reply "Слава роботам! Убить всех человеков!"

  robot.respond /talk to me in private$/i, ( msg ) ->
    msg.envelope.user.type = 'direct'
    msg.send "Hey #{msg.envelope.user.name}! You told me in room #{msg.envelope.user.room} to talk to you."

  robot.respond /show me your brain/i, (msg) ->
    util = require 'util'
    msg.reply util.inspect robot.brain.data, depth: null

  robot.hear /make a test/i, (msg) ->
    msg.reply 'Testing reply()'
    msg.send 'Testing send()'

  robot.respond /teach him manners/i, (msg) ->
    msg.reply 'Саня, я робот вообще-то.'

  robot.respond /anime/i, (msg) ->
    msg.reply """
# Patching KDE2 under FreeBSD
cd /usr/ports && make index; pkgdb -F
cd /usr/ports/x11/xorg && make all install && make clean
cd /usr/ports/x11/kde2/
patch -i issue133.patch
make && make install && make clean
portsnap fetch
portsnap extract
portsnap fetch update
xorgcfg
cp ~/xorg.conf.new /usr/X11R6/etc/X11/xorg.conf
touch ~/.xinitrc && echo -ne 'exec startkde' > ~/.xinitrc
reboot
startx
"""

  robot.respond /(ci|travis) status (for|of) (\S+)/i, (msg) ->
    ref = msg.match[3]
    GitHubApi = require 'github'
    github = new GitHubApi {
      version: '3.0.0'
    }
    github.statuses.getCombined {
      user: 'uonline'
      repo: 'uonline'
      sha: ref
    }, (error, result) ->
      if error?
        cson = require 'cson'
        #msg.reply "GitHub API error:\n#{cson.createCSONString(error)}"
        #console.log require('util').inspect error
        if error.message?
          error.message = JSON.parse(error.message)
        msg.reply "⚠️ GitHub API error:\n#{cson.createCSONString(error)}"
      else
        superstate = (state) ->
          switch state
            when 'success' then '✅ success'
            when 'pending' then '🕑 pending'
            when 'failure' then '❌ failure'
            else state
        result.state = superstate(result.state)
        ci = "CI status for #{ref}: #{result.state}"
        details = ""
        for i in result.statuses
          details += "\n[#{superstate(i.state)}] #{i.context}: #{i.description}"
        msg.reply "#{ci}#{details}"

  robot.respond /deploy (\S+) to dev/i, (msg) ->
    ref = msg.match[1]
    msg.reply "Okay, deploying #{ref} to dev.\nChecking CI status for #{ref}..."
    GitHubApi = require 'github'
    github = new GitHubApi {
      version: '3.0.0'
    }
    github.statuses.getCombined {
      user: 'uonline'
      repo: 'uonline'
      sha: ref
    }, (error, result) ->
      if error?
        msg.reply "GitHub API error:\n#{error}"
      else
        if result.state is 'success'
          msg.reply "CI is fine (#{result.statuses.length} checks), starting deploy.\nLol, sorry, not implemented."
        else
          ci = "CI is not fine, interrupting.\nOverall status: #{result.state}"
          details = ""
          for i in result.statuses
            details += "\n[#{i.state}] #{i.context}: #{i.description}"
          msg.reply "#{ci}#{details}"

  # robot.hear /badger/i, (msg) ->
  #   msg.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (msg) ->
  #   doorType = msg.match[1]
  #   if doorType is "pod bay"
  #     msg.reply "I'm afraid I can't let you do that."
  #   else
  #     msg.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (msg) ->
  #   msg.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (msg) ->
  #   msg.send msg.random lulz
  #
  # robot.topic (msg) ->
  #   msg.send "#{msg.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (msg) ->
  #   msg.send msg.random enterReplies
  # robot.leave (msg) ->
  #   msg.send msg.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (msg) ->
  #   unless answer?
  #     msg.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   msg.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (msg) ->
  #   setTimeout () ->
  #     msg.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (msg) ->
  #   if annoyIntervalId
  #     msg.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return

  #   msg.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     msg.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000

  # robot.respond /unannoy me/, (msg) ->
  #   if annoyIntervalId
  #     msg.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     msg.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, msg) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if msg?
  #     msg.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (msg) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     msg.reply "I'm too fizzy.."
  #
  #   else
  #     msg.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (msg) ->
  #   robot.brain.set 'totalSodas', 0
  #   robot.respond 'zzzzz'
