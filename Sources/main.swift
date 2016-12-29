
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache

// Create HTTP server.
let server = HTTPServer()

// Set the webroot directory so static files such as the logo, can be served
server.documentRoot = "./webroot"

var routes = Routes()

var dbHandler = DB()

// Adding a route to handle the root list
routes.add(method: .get, uri: "/", handler: {
	request, response in
	response.setHeader(.contentType, value: "text/html")
	mustacheRequest(
		request: request,
		response: response,
		handler: ListHandler(),
		templatePath: request.documentRoot + "/index.mustache"
	)
	response.completed()
	}
)


func decode(postBody: String?) -> [String: Any]? {
  do {
      guard let decoded = try postBody?.jsonDecode() as? [String:Any] else {
          return [:]
      }
      print(decoded)
      return decoded
  } catch {
      return [:]
  }
}

// post message
routes.add(method: .post, uri: "/addMessage", handler: {
	request, response in
	// let decodedString = decode(postBody: request.postBodyString)
	print(request.postBodyString!.removingPercentEncoding!)
	dbHandler.addData(postData: request.postBodyString!.removingPercentEncoding!)
	response.status = .movedPermanently
	response.setHeader(.location, value: "http://localhost:8181/")

	response.completed()
})


// Serve a story
// routes.add(method: .get, uris: ["/story","/story/{titleSanitized}"], handler: {
// 	request, response in

// 	let titleSanitized = request.urlVariables["titlesanitized"] ?? ""

// 	// Setting the response content type explicitly to text/html
// 	response.setHeader(.contentType, value: "text/html")

// 	if titleSanitized.characters.count > 0 {
// 		// Setting the body response to the generated list via Mustache
// 		mustacheRequest(
// 			request: request,
// 			response: response,
// 			handler: StoryHandler(),
// 			templatePath: request.documentRoot + "/story.mustache"
// 		)
// 	} else {
// 		// Setting the body response to the generated list via Mustache
// 		emptyStory(request.documentRoot, request: request, response: response)
// 	}

// 	// Signalling that the request is completed
// 	response.completed()
// 	}
// )


// Add the routes to the server.
server.addRoutes(routes)

// Set a listen port of 8181
server.serverPort = 8181

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}





