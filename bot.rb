# use karl's chat-adapter library
require 'chat-adapter'
# also use the local HerokuSlackbot class defined in heroku.rb
require './heroku'
require 'rest-client'

# if we're on our local machine, we want to test our bot via shell, but when on
# heroku, deploy the actual slackbot.
# 
# Feel free to change the name of the bot here - this controls what name the bot
# uses when responding.
if ARGV.first == 'heroku'
  bot = HerokuSlackAdapter.new(nick: 'mesh-bot')
else
  puts "test"
  bot = ChatAdapter::Shell.new(nick: 'mesh-bot')
end

# Feel free to ignore this - makes logging easier
log = ChatAdapter.log

# Do this thing in this block each time the bot hears a message:
bot.on_message do |message, info|
  puts "test"
  # ignore all messages not directed to this bot
  unless message.start_with? 'mesh-bot'
    next # don't process the next lines in this block
  end

  # Conditionally send a direct message to the person saying whisper
  if message == 'mesh-bot whisper'
    # log some info - useful when something doesn't work as expected
    log.debug("Someone whispered! #{info}")
    # and send the actual message
    bot.direct_message(info[:user], "whisper-whisper")
  end

  # split the message in 2 to get what was actually said.
  botname = message.split(' ').first
  command = message.split(' ').shift.join(" ")

  # answer the query!
  # this bot simply echoes the message back
  "@#{info[:user]}: #{command}"
end

# actually start the bot
bot.start!