require 'daemons'
require 'json'

active_bots = File.open("active_bots.conf", "r")
bot_tokens = JSON.parse(File.read("bot_tokens.json"))


active_bots.each_line do |bot|

	Daemons.run(bot,{
		:ARGV => [ARGV[0],'--',bot_tokens[bot]]
		})

end
