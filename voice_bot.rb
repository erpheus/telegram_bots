require 'telegrammer'
require 'ogginfo'

def createdir()
  `mkdir -p /tmp/bieenbot/media`
end


def download_audio(text, file_id)
	`curl -o /tmp/bieenbot/media/#{file_id}.mp3 -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30" "http://translate.google.com/translate_tts?tl=es&q=#{URI.escape(text)}"`
end

def encode_audio(file_id)
	`ffmpeg -i /tmp/bieenbot/media/#{file_id}.mp3 -acodec libopus -b:a 16000 -vbr on -compression_level 10 -metadata encoder='' /tmp/bieenbot/media/#{file_id}.ogg`
end

def delete_temp_audio(file_id)
  `rm /tmp/bieenbot/media/#{file_id}.mp3 /tmp/bieenbot/media/#{file_id}.ogg`
end

createdir()

bot = Telegrammer::Bot.new(ARGV[0])

bot.get_updates do |message|
  #puts "In chat #{message.chat.id}, @#{message.from.username} said: #{message.text}"

  if not message.text
  	next
  end

  message_id = message.message_id

  download_audio(message.text.sub('@bieeen_bot', ''), message_id)

  encode_audio(message_id)

  unless File.exist?("/tmp/bieenbot/media/#{message_id}.ogg")
    next
  end

  audio_file = File.open("/tmp/bieenbot/media/#{message_id}.ogg")
  bot.send_audio(chat_id: message.chat.id, audio: audio_file)
  delete_temp_audio(message_id)

end