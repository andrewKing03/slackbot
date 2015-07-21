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
@log = ChatAdapter.log

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
    messages = params.split(' ')
    second_command = messages.first
    messages.shift
    case second_command
    when "client"
      #mesh-bot list sites
      #mesh-bot list sites (production,dev)
      site_name = messages.first
      deployed_client_site(site_name)
    when "version"
      "Not implemented yet, blame Jonas"
    end
    #mesh-bot deployed (sitename)
    #mesh-bot deployed version (version number)
  when "help"
    "mesh-bot help!\nAccepted commands:\n list sites [dev,production,prod] \n deployed client [sitename] \n deployed version [4.2.111]"

  else "what the fuck, you can't just yell my name in a channel and expect me to do shit for you! I am not an Usher!"
  end
end

def list_sites(type=nil)

  url = "https://#{@meshuser}:#{@meshpass}@mesh1.kailabor.com/mesh/sitelist"
  response = RestClient.get url

  site_list = []
  JSON.parse(response).each do | site |
    is_production = site["production"] 
    if type == "dev" then
     site_list << site["name"] if !is_production
   elsif type == "production" || type == "prod" then
     site_list << site["name"] if is_production
   elsif !type
     site_list << site["name"] 
   end
  end

  sites = site_list.sort.join("\n")
end

def deployed_client_site(site_name)
  url = "https://#{@meshuser}:#{@meshpass}@mesh1.kailabor.com/mesh/sites/#{site_name}/deployments"
  raw_response = RestClient.get url

raw_response = JSON.parse(raw_response)
  if !raw_response then 
    response  = "No site named #{site_name} found!"
  else  

    version = raw_response["deploy"]["kai-apps"].split("/")[4]
    jeb_name =  raw_response["deploy"]["kai-apps"].split("/").last.split("_").last

    branch = raw_response["deploy"]["kai-apps"].split("/")[3]

    full_version = version
    build_list_url = "https://#{@meshuser}:#{@meshpass}@mesh1.kailabor.com/mesh/builds/branches/#{branch}/#{version}"
    build_list = RestClient.get build_list_url
    JSON.parse(build_list).each do | key,value |
      if key.split(" ").join("-") == jeb_name then 
        full_version = value["com.acres4.Kai"]["version"]
      end
    end

     "#{site_name} has Kai client version: #{full_version}"
  end

end

# actually start the bot
bot.start!