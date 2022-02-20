module ardilla.responses;

private {
	import std.algorithm : canFind;
	import std.file: dirEntries, isFile, SpanMode;
	import std.path : baseName;
	import std.string: detab, replace, split, startsWith;
	import std.stdio : File;
	
	import ardilla.gopher;
}

class GopherResponse
{
	/// create server response from given arguments
	static ubyte[] create(GOPHER_CONTENT content, string[] requestArguments...)
	{
		ubyte[] response;
	
		response ~= cast(ubyte) content;
		
		foreach (r; requestArguments[0..$-1])
		{
			response ~= cast(ubyte[]) r;
			response ~= GOPHER_DELIMETER.TAB;
		}
		
		response ~= requestArguments[$-1];
		response ~= GOPHER_REQUEST_TERMINATOR;
		
		return response;
	}
	
	/// create server response for wrong requests
	static ubyte[] createError(string message)
	{
		return create(GOPHER_CONTENT.ERROR, message, "", "error.host", "1");
	}
	
	/// create information server response
	static ubyte[] createInfo(string message)
	{
		return create(GOPHER_CONTENT.INFORMATION, message, "", "error.host", "1");
	}
	
	/// create server response from file
	static ubyte[] fromFile(string path)
	{
		static import std.file;
		return cast(ubyte[]) std.file.read(path);
	}
	
	/// create server response from file system tree
	static ubyte[] fromFs(string path, string server, string port)
	{
		ubyte[] gopherMap;
	
		foreach (entry; dirEntries(path, SpanMode.shallow))
		{
			auto name = entry.name;
			
			if (entry.isDir)
			{
				gopherMap ~= create(GOPHER_CONTENT.DIRECTORY, name, name, server, port);
			}
			else
			{
				auto type = createGopherContentType(entry);
				gopherMap ~= create(type, baseName(name), name, server, port);
			}
		}
		
		return gopherMap;
	}

	/// create server response from gophermap-file
	static ubyte[] fromMap(string path)
	{
		ubyte[] gopherMap;
		File file;
		file.open(path);

		import std.stdio;
		
		foreach (e; file.byLine)
		{
			auto fields = e
							.replace("\n", "")
							.replace("\r\n", "")
							.split("\t");


			if (fields.length != 0)
			{
				auto marker = fields[0][0];
				
				if (marker.isGopherContentType)
				{
					auto type = cast(GOPHER_CONTENT) marker;
					auto description = cast(string) fields[0][1..$];
					
					gopherMap ~= create(type, description ~ cast(string[]) fields[1..$]);
				}
				else
				{
					 gopherMap ~= createInfo(cast(string) e);
				}
			}
		}
		
		return gopherMap;
	}

	/// create response from search
	static ubyte[] fromQuery(string query, string path, string server, string port)
	{
		ubyte[] response;


		if (query.length == 0)
		{
			response = createInfo(`Sorry, no valid keywords in your query`);
		}
		else
		{
			foreach (u; dirEntries(path, SpanMode.depth))
			{
				auto name = u.name;

				if (baseName(name).startsWith(query))
				{
					if (u.isDir)
					{
						response ~= create(GOPHER_CONTENT.DIRECTORY, baseName(name), name, server, port); 
					}
					else
					{
						auto type = createGopherContentType(u);
						response ~= create(type, baseName(name), name, server, port);
					}
				}

				if (u.isFile && (query.length >= 3))
				{
					if (createGopherContentType(name) == GOPHER_CONTENT.TEXT_FILE)
					{
						File file;
						file.open(name);

						foreach (e; file.byLine)
						{
							if (e.canFind(query))
							{
								response ~= createInfo(cast(string) e.detab);
								response ~= create(GOPHER_CONTENT.TEXT_FILE, baseName(name), name, server, port);
								break;
							}
						}

						scope(exit) {
							file.close;
						}
					}
				}
			}
		}

		return response;
	}
}
