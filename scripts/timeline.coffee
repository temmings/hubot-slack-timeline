# Description:
#   send all of the messages on Slack in #timeline
#
# Configuration:
#   create #timeline channel on your Slack team
#
# Notes:
#   None
#
# Author:
#   vexus2

request = require 'request'
module.exports = (robot) ->
  robot.hear /.*?/i, (msg) ->
    return if not process.env.hasOwnProperty('SLACK_API_TOKEN')

    post_channel = process.env.SLACK_POST_CHANNEL || 'timeline'

    channel = msg.envelope.room
    message = msg.message.text
    username = msg.message.user.name
    user_id = msg.message.user.id
    reloadUserImages(robot, user_id)
    user_image = robot.brain.data.userImages[user_id]
    if message.length > 0
      message = encodeURIComponent(message)
      request = msg.http("https://slack.com/api/chat.postMessage?token=#{process.env.SLACK_API_TOKEN}&channel=%23#{post_channel}&text=#{message}%20(at%20%23#{channel}%20)&username=#{username}&link_names=0&pretty=1&icon_url=#{user_image}").get()
      request (err, res, body) ->

  reloadUserImages = (robot, user_id) ->
    robot.brain.data.userImages = {} if !robot.brain.data.userImages
    robot.brain.data.userImages[user_id] = "" if !robot.brain.data.userImages[user_id]?

    return if robot.brain.data.userImages[user_id] != ""
    options =
      url: "https://slack.com/api/users.list?token=#{process.env.SLACK_API_TOKEN}&pretty=1"
      timeout: 2000
      headers: {}

    request options, (error, response, body) ->
      json = JSON.parse body
      i = 0
      len = json.members.length

      while i < len
        image = json.members[i].profile.image_48
        robot.brain.data.userImages[json.members[i].id] = image
        ++i


