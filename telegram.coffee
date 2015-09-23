{Robot, Adapter, TextMessage, User} = require 'hubot'
request = require 'request'

class Telegram extends Adapter

  constructor: ->
    super
    @robot.logger.info "Telegram Adapter loaded"

    @token = process.env['TELEGRAM_TOKEN']
    @webHook = process.env['TELEGRAM_WEBHOOK']
    @api_url = "https://api.telegram.org/bot#{@token}"
    @timeout = process.env['TELEGRAM_INTERVAL'] or 60000
    @offset = 0

    # Get the Bot Id and name...not used by now
    request "#{@api_url}/getMe", (err, res, body) =>
      @id = JSON.parse(body).result.id if res.statusCode == 200

  send: (envelope, strings...) ->

    data =
      url: "#{@api_url}/sendMessage"
      form:
        chat_id: envelope.room
        text: strings.join()
        disable_web_page_preview: true

    request.post data, (err, res, body) =>
      @robot.logger.info res.statusCode

  reply: (envelope, strings...) ->

    data =
      url: "#{@api_url}/sendMessage"
      form:
        chat_id: envelope.room
        text: strings.join()

    request.post data, (err, res, body) =>
      @robot.logger.info res.statusCode

  receiveMsg: (msg) ->

    user = @robot.brain.userForId msg.message.from.id, name: msg.message.from.username, room: msg.message.chat.id
    text = msg.message.text

    # Only if it's a text message, not join or leaving events
    if text
      # Strip any commands and mentions
      if text[0] is '/' or text[0] is '@'
        text = text.slice(text.indexOf(' ')+1)
      ## If is a direct message to the bot, prepend the name
      ##text = @robot.name + ' ' + msg.message.text if msg.message.chat.id > 0
      text = @robot.name + ' ' + text
      message = new TextMessage user, text, msg.message_id
      @receive message
      @offset = msg.update_id

  getLastOffset: ->
    # Increment the last offset
    parseInt(@offset) + 1

  run: ->
    self = @
    @robot.logger.info "Run"

    unless @token
      @emit 'error', new Error `'The environment variable \`\033[31mTELEGRAM_TOKEN\033[39m\` is required.'`

    if @webHook
      # Call `setWebHook` to dynamically set the URL
      data =
        url: "#{@api_url}/setWebHook"
        form:
          url: @webHook

      request.post data, (err, res, body) =>
        @robot.logger.info res.statusCode

      @robot.router.post "/telegram/receive", (req, res) =>
        console.log req.body
        for msg in req.body.result
          @robot.logger.info "WebHook"
          @receiveMsg msg
    else
      longPoll = ->
        url = "#{self.api_url}/getUpdates?offset=#{self.getLastOffset()}&timeout=#{@timeout/1000|0}"
        self.robot.http(url).get() (err, res, body) ->
          process.nextTick -> longPoll()
          if err
            it_is_timeout = err.description is 'Error: Conflict: terminated by other long poll or webhook'
            unless it_is_timeout
              self.emit 'error', new Error err
          else
            try
              updates = JSON.parse body
            catch ex
              console.log("#{ex.message}\nWhile parsing:\n#{body}")
              return
            unless updates.ok
              console.log("#{updates.description} (#{updates.error_code})")
              return
            for msg in updates.result
              self.receiveMsg msg
      longPoll()

    @emit "connected"

exports.use = (robot) ->
  new Telegram robot
