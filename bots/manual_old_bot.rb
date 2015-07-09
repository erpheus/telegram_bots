require 'net/http'
require 'json'





# Takes a hash of string and file parameters and returns a string of text
# formatted to be sent as a multipart form post.
#
# Author:: Cody Brimhall <mailto:brimhall@somuchwit.com>
# Created:: 22 Feb 2008
# License:: Distributed under the terms of the WTFPL (http://www.wtfpl.net/txt/copying/)

require 'rubygems'
require 'mime/types'
require 'cgi'


module Multipart
  VERSION = "1.0.0"

  # Formats a given hash as a multipart form post
  # If a hash value responds to :string or :read messages, then it is
  # interpreted as a file and processed accordingly; otherwise, it is assumed
  # to be a string
  class Post
    # We have to pretend we're a web browser...
    USERAGENT = "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-us) AppleWebKit/523.10.6 (KHTML, like Gecko) Version/3.0.4 Safari/523.10.6"
    BOUNDARY = "0123456789ABLEWASIEREISAWELBA9876543210"
    CONTENT_TYPE = "multipart/form-data; boundary=#{ BOUNDARY }"
    HEADER = { "Content-Type" => CONTENT_TYPE, "User-Agent" => USERAGENT }

    def self.prepare_query(params)
      fp = []

      params.each do |k, v|
        # Are we trying to make a file parameter?
        if v.respond_to?(:path) and v.respond_to?(:read) then
          fp.push(FileParam.new(k, v.path, v.read))
        # We must be trying to make a regular parameter
        else
          fp.push(StringParam.new(k, v))
        end
      end

      # Assemble the request body using the special multipart format
      query = fp.collect {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("") + "--" + BOUNDARY + "--"
      return query, HEADER
    end
  end

  private

  # Formats a basic string key/value pair for inclusion with a multipart post
  class StringParam
    attr_accessor :k, :v

    def initialize(k, v)
      @k = k
      @v = v
    end

    def to_multipart
      return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"\r\n\r\n#{v}\r\n"
    end
  end

  # Formats the contents of a file or string for inclusion with a multipart
  # form post
  class FileParam
    attr_accessor :k, :filename, :content

    def initialize(k, filename, content)
      @k = k
      @filename = filename
      @content = content
    end

    def to_multipart
      # If we can tell the possible mime-type from the filename, use the
      # first in the list; otherwise, use "application/octet-stream"
      mime_type = MIME::Types.type_for(filename)[0] || MIME::Types["application/octet-stream"][0]
      return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"; filename=\"#{ filename }\"\r\n" +
             "Content-Type: #{ mime_type.simplified }\r\n\r\n#{ content }\r\n"
    end
  end
end
























def apiRequest(method, params)
	uri = URI('https://api.telegram.org/bot112292992:AAHuhaJpeiz5iTJPQSvJLT-oP5dfKPNOv1s/'+method)
	uri.query = URI.encode_www_form(params)

	res = Net::HTTP.get_response(uri)

	if not res.is_a?(Net::HTTPSuccess)
		puts "not HTTPSuccess"
		return nil
	end

	response = JSON.parse(res.body)

	if not response["ok"] == true
		puts "not ok"
		return nil
	end

	return response
end

def download_audio(text, file_id)
	`curl -o media/#{file_id}.mp3 -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30" "http://translate.google.com/translate_tts?tl=es&q=#{URI.escape(text)}"`
end

def upload_audio(chat_id, reply_id, file_id)
	puts `curl -v -F "document=@media/#{file_id}.ogg" -F chat_id=#{chat_id} -F reply_to_message_id=#{reply_id} https://api.telegram.org/bot112292992:AAHuhaJpeiz5iTJPQSvJLT-oP5dfKPNOv1s/sendDocument`
  return
	upload_uri = URI('https://api.telegram.org/bot112292992:AAHuhaJpeiz5iTJPQSvJLT-oP5dfKPNOv1s/sendDocument')
	puts "chat id: #{chat_id}       file_id: #{file_id}"
	data, headers = Multipart::Post.prepare_query("chat_id" => chat_id.to_s, "document" => File.new("media/"+file_id.to_s+".ogg", "r"))
	http = Net::HTTP.new(upload_uri.host, upload_uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	res = http.start {|con| con.post(upload_uri.path, data, headers) }
	puts res.body
	puts "-----"
end

def encode_audio(file_id)
	`ffmpeg -i media/#{file_id}.mp3 -acodec libopus -vbr on -compression_level 10 media/#{file_id}.ogg`
end

exit_requested = false
Kernel.trap( "INT" ) { exit_requested = true }

last_id = 0

while !exit_requested

	sleep 3

	
	params = {}
	if last_id != 0
		params = {:offset => last_id+1}
	end
	response = apiRequest('getUpdates',params)

	if !response
		next
	end


	updates = response["result"]

	updates.each do |update|

		last_id = update["update_id"]

		message = update["message"]

		#apiRequest('sendMessage',{:chat_id => message["chat"]["id"], :text => "hola"})

		if !message["text"]
			next
		end


		download_audio("bieeen " + message["text"].to_s.sub('@bieeen_bot', ''),message["message_id"])

		encode_audio(message["message_id"])

		upload_audio(message["chat"]["id"], message["message_id"], message["message_id"])

	end

end



