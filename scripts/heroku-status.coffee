# Description:
#   Show current Heroku status and issues
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot heroku status - Returns the current Heroku status for app operations and tools
#   hubot heroku status issues <limit> - Returns a list of recent <limit> issues (default limit is 5)
#   hubot heroku status issue <id> - Returns a single issue by ID number
#
# Author:
#   juno

module.exports = (robot) ->
  robot.respond /heroku status$/i, (msg) ->
    status msg

  robot.respond /heroku status issues\s?(\d*)/i, (msg) ->
    limit = msg.match[1] or 5
    statusIssues msg, limit

  robot.respond /heroku status issue (\d+)/i, (msg) ->
    id = msg.match[1]
    statusIssue msg, id


printIssues = (issues) ->
  issues.map((x) -> "* #{x.title}: #{x.full_url}").join "\n"

highlight = (status) ->
  if status is 'green' then status else status.toUpperCase()

status = (msg) ->
  msg.http("https://status.heroku.com/api/v3/current-status")
    .get() (err, res, body) ->
      try
        json = JSON.parse(body)
        msg.send "Heroku status:\n" +
                 "Production:  #{highlight json['status']['Production']}\n" +
                 "Development: #{highlight json['status']['Development']}\n" +
                 "#{printIssues(json.issues)}"
      catch error
        msg.send "Uh oh, I had trouble figuring out what the Heroku cloud is up to."

statusIssues = (msg, limit) ->
  limit = msg.match[1] or 5
  msg.http("https://status.heroku.com/api/v3/issues?limit=#{limit}")
    .get() (err, res, body) ->
      try
        json = JSON.parse(body)
        buildIssue = (issue) ->
          s = "[##{issue['id']}] #{issue['title']} "
          s += if issue['resolved'] then "(resolved)" else "(unresolved)"
        msg.send (buildIssue issue for issue in json).join("\n")
      catch error
        msg.send "Uh oh, I had trouble figuring out what the Heroku cloud is up to."

statusIssue = (msg, id) ->
  msg.http("https://status.heroku.com/api/v3/issues/#{id}")
    .get() (err, res, body) ->
      try
        json = JSON.parse(body)
        msg.send "Title:     #{json['title']}\n" +
                 "Resolved: #{json['resolved']}\n" +
                 "Created:  #{json['created_at']}\n" +
                 "Updated:  #{json['updated_at']}\n" +
                 "URL:      https://status.heroku.com/incidents/#{id}\n"
      catch error
        msg.send "Uh oh, I had trouble figuring out what the Heroku cloud is up to."
