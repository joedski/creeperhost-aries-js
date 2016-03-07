###
A sort of straight port of the Aries PHP class.
###

https = require 'https'

# The CH Aries API uses PHP's urlencode function, so I'm going to assume their backend expucts its exact behavior.
urlencode = require '../phpjs/urlencode'

###
The cURL request had the following options:
- CURLOPT_URL = (the url)
- CURLOPT_SSL_VERIFYPEER = false
- CURLOPT_SSL_VERIFYHOST = false
- CURLOPT_POST = 1+
- CURLOPT_RETURNTRANSFER = true
    - This is not nodey, so we ignore this in favor of asyncish ways.  Listen for the 'response' event on the ClientRequest this method call returns.
- CURLOPT_POSTFIELDS = fieldsString
###

module.exports = class Aries
	@ERROR_HTTP: 'ERROR_HTTP'
	@ERROR_API: 'ERROR_API'

	key: null
	secret: null

	# Convenience wrapper to convert non-OK HTTP statuses to errors.
	@wrapCommonErrors: ( callback ) ->
		( error, responseData, response, rawResponseData ) ->
			if error?
				callback error
			else if not (200 <= (Number response.statusCode) < 400)
				error = new Error( "Received non-OK statusCode #{ response.statusCode }" )
				error.apiErrorType = Aries.ERROR_HTTP
				error.apiResponse = response
				error.apiResponseStatusCode = Number response.statusCode

				callback error, responseData, response, rawResponseData
			else if responseData.status != 'success'
				error = new Error( "API call to '#{ response.ariesMeta.service }/#{ response.ariesMeta.command }' returned non-success status: #{ responseData.message }" )
				error.apiErrorType = Aries.ERROR_API
				error.apiResponseData = responseData
				error.apiResponseStatus = responseData.status
				error.apiResponseMessage = responseData.message
				error.apiResponseCode = responseData.code

				callback error, responseData, response, rawResponseData
			else
				callback null, responseData, response, rawResponseData


	constructor: ( @key, @secret ) ->
		# Nothing else, really...

	# PHP arrays most closely resemble JS objects.
	exec: ( service, command, data = {}, callback = null ) ->
		if typeof data is 'function'
			callback = data
			data = {}

		callback = callback or ->;
		postData = @getPostData data
		url = @getPostRequestOptions service, command, postData

		request = https.request urlOpts
		request.write postData
		request.end()

		request.on 'error', ( error ) ->
			callback error

		request.on 'response', do =>
			rawResponseData = ''
			( response ) =>
				response.ariesMeta =
					service: service
					command: command
					data: data
					key: @key
					secret: @secret
				response.setEncoding 'utf8'
				response.on 'data', ( data ) -> rawResponseData += data
				response.on 'end', ->
					responseData = if rawResponseData? then (try JSON.parse rawResponseData catch e then null) else null
					callback null, responseData, response, rawResponseData

	getPostData: ( data ) ->
		fields =
			key: @key
			secret: @secret

		if data? then fields.data = JSON.stringify data

		# TODO: There's probably a better way to do this, but for now I'm explicitly following the exact same method as their PHP implementation.
		("#{ name }=#{ urlencode value }" for name, value of fields).join '&'

	getPostRequestOptions: ( service, command, postData ) ->
		method: 'POST'
		hostname: "api.creeperhost.net"
		path: '/' + [ service, command ].join( '/' )
		headers:
			'Content-Type': 'application/x-www-form-urlencoded'
			'Content-Length': Buffer.byteLength postData, 'utf8'
		rejectUnauthorized: false # covers CURLOPT_SSL_VERIFYPEER and CURLOPT_SSL_VERIFYHOST.
