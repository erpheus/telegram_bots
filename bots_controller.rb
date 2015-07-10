require 'daemons'
require 'json'

BOTS_DIR = 'bots'
CONFIG_DIR = 'config'

active_bots = File.open("#{CONFIG_DIR}/active_bots.conf", "r")
bot_tokens = JSON.parse(File.read("#{CONFIG_DIR}/bot_tokens.json"))

current_dir = `pwd`.chomp

active_bots.each_line do |bot|

	Daemons.run("#{BOTS_DIR}/#{bot}.rb",{
		:ARGV => [ARGV[0],'--',bot_tokens[bot],current_dir]
		})

end
