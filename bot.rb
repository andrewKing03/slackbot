# use karl's chat-adapter library
require 'chat-adapter'
# also use the local HerokuSlackbot class defined in heroku.rb
require './heroku'
require 'rest-client'
require 'json'

# if we're on our local machine, we want to test our bot via shell, but when on
# heroku, deploy the actual slackbot.
# 
# Feel free to change the name of the bot here - this controls what name the bot
# uses when responding.
if ARGV.first == 'heroku'
  bot = HerokuSlackAdapter.new(nick: 'mesh-bot')
  @meshuser = ENV['MESH_USER']
  @meshpass = ENV['MESH_PASS']
else
  bot = ChatAdapter::Shell.new(nick: 'mesh-bot')
  @meshuser = 'a4admin'
  @meshpass = 'Overwhelmingly-Opposed-Dingo'
end




# Feel free to ignore this - makes logging easier
log = ChatAdapter.log

# Do this thing in this block each time the bot hears a message:
bot.on_message do |message, info|

  # split the message in 2 to get what was actually said.
  messages = message.split(' ')

  botname = messages.first
  messages.shift
  command = messages.first
  messages.shift
  params = messages.join(' ')


 response = case command
  when "list"
    messages = params.split(' ')
    second_command = messages.first
    messages.shift
    case second_command
    when "sites"
      #mesh-bot list sites
      #mesh-bot list sites (production,dev)
      type = messages.first
      list_sites(type)
    end
  when "deployed"
    #mesh-bot deployed (sitename)
    #mesh-bot deployed version (version number)
  else "what the fuck, you can't just yell my name in a channel and expect me to do shit for you! I am not an Usher!"
  end



   "@#{info[:user]}: #{response}"
  
end

def list_sites(type=nil)

  url = "https://#{@meshuser}:#{@meshpass}@mesh1.kailabor.com/mesh/sitelist"
  response = RestClient.get url

  site_list = []
  JSON.parse(response).each do | site |
    if type == "dev" && !site[:production] then
     site_list << site["name"] 
   elsif type == "production" && site[:production] then
     site_list << site["name"] 
   else
     site_list << site["name"] 
   end
  end

  return site_list.join(' \\\n ')
end


# actually start the bot
bot.start!