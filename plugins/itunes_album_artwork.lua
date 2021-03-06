local itunes_album_artwork = {}
local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local functions = require('functions')
function itunes_album_artwork:init(configuration)
	itunes_album_artwork.command = 'albumart <song/album>'
	itunes_album_artwork.triggers = functions.triggers(self.info.username, configuration.command_prefix):t('albumart', true).table
	itunes_album_artwork.doc = configuration.command_prefix .. 'albumart <song> - Returns a high-quality version of the given song\'s album artwork, from iTunes.'
end
function itunes_album_artwork:action(msg, configuration)
	local input = functions.input(msg.text)
	if not input then
		functions.send_reply(msg, itunes_album_artwork.doc, true)
		return
	else
		local url = configuration.itunes_album_artwork_api .. URL.escape(input)
		local jstr, res = HTTPS.request(url)
		if res ~= 200 then
			functions.send_reply(msg, '`' .. configuration.errors.connection .. '`', true)
			return
		else
			local jdat = JSON.decode(jstr)
			if tonumber(jdat.resultCount) > 0 then
				if jdat.results[1].artworkUrl100 then
					local artworkUrl100 = jdat.results[1].artworkUrl100:gsub('/100x100bb.jpg', '/10000x10000bb.jpg')
					functions.send_action(msg.chat.id, 'upload_photo')
					functions.send_photo(msg.chat.id, functions.download_to_file(artworkUrl100))
					return
				else
					functions.send_reply(msg, '`' .. configuration.errors.results .. '`', true)
					return
				end
			else
				functions.send_reply(msg, '`' .. configuration.errors.results .. '`', true)
				return
			end
		end
	end
end
return itunes_album_artwork