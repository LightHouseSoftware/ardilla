module ardilla.mainapp;

private {
	import std.conv : to;
	import std.file : exists, isDir;
	import std.string : indexOf;
	
	import ardilla.configuration;
	import ardilla.gopher : GOPHER_REQUEST_TERMINATOR;
	import ardilla.responses;
	import ardilla.server;
	
	debug {
		import std.string : replace;
		import ardilla.colorized;
		
		auto textify(ubyte[] request)
		{
			return (cast(string) request)
							.replace("\n", "<LF>")
							.replace("\t", "<TAB>")
							.replace("\r", "<CR>");
		}
	}
}

/// Gopher server implementation
class GopherServer : GenericSimpleServer!(GOPHER_BUFFER_SIZE, GOPHER_NUMBER_OF_CONNECTIONS) 
{
	private
	{
		string _host;		
		string _path;
    }
	
	this(string host, string path) 
	{
		_host = host;
		_path = path;
	}
	
	override ubyte[] handle(ubyte[] request)
	{
		ubyte[] response = GopherResponse.createError("Invalid request");
		
		/// create response for path
		auto createResponse(string path)
		{
			ubyte[] response;
			
			auto gophermap = path ~ "/" ~ GOPHER_MAP_FILENAME;
			
			if (gophermap.exists)
			{
				response = GopherResponse.fromMap(gophermap);
			}
			else
			{
				response = GopherResponse.fromFs(path, _host, _port.to!string);
			}
			
			return response;
		}

		debug
		{
			log("[Client] " ~ textify(request));
		}

		if (request.length >= 1)
		{
			if (request == GOPHER_REQUEST_TERMINATOR) 
			{
				debug {
						log("[Client] Menu request");
				}
				
				response = createResponse(_path);
			}
			else
			{
				auto entry = cast(string) request[0..$-2];				
				auto tab = entry.indexOf("\t");
				
				if (tab != -1)
				{
					response = GopherResponse.fromQuery(entry[tab+1..$], _path, GOPHER_DOMAIN, _port.to!string);
					
					debug {
						log("[Client] Search for: " ~ entry);
					}
				}
				else
				{
					if (entry.exists)
					{
						if (entry.isDir)
						{
							debug {
								log("[Client] Directory request: " ~ entry);
							}
							
							response = createResponse(entry);
						}
						else
						{
							debug {
								log("[Client] File request: " ~ entry);
							}
							
							response = GopherResponse.fromFile(entry);
						}
					}
				}
			}
		}
		
		return response;
	}
}


void main()
{
	auto gopher = new GopherServer(GOPHER_DOMAIN, GOPHER_FOLDER);
    
    debug {
		info("[Server] IP is " ~ GOPHER_IP);
		info("[Server] PATH is " ~ GOPHER_FOLDER);
	}
	
	with (gopher)
	{
		debug {
			info("[Server] Server configured.");
		}
		
		setup4(GOPHER_IP, 70);
		
		debug {
			info("[Server] Server started.");
		}
		
		run;
	}
}
