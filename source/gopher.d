module ardilla.gopher;

private {
	import std.path : extension;
	import std.string : toLower;
	import std.traits : EnumMembers;
}

/// Request terminators and other delimeters in protocol
enum GOPHER_DELIMETER
{
	CR   = 0x0d,
	LF   = 0x0a,
	TAB  = 0x09
}

/// Content types
enum GOPHER_CONTENT : ubyte
{
	// canonical types
	TEXT_FILE         =  '0',
	DIRECTORY         =  '1' ,
	CCSO_SERVER       =  '2',
	ERROR             =  '3',
	BINHEX_FILE       =  '4',
	DOS_FILE          =  '5',
	UUE_FILE	      =  '6',
	SEARCH            =  '7',
	TELNET            =  '8',
	BINARY_FILE       =  '9',
	DUPLICATE_SERVER  =  '+', 
	GIF_FILE	      =  'g',
	IMAGE_FILE        =  'I',
	TELNET_3270       =  'T',
	
	// gopher+
	BITMAP_IMAGE      =  ':',
	MOVIE_FILE        =  ';',
	SOUND			  =  '<',
	
	// non-canonical types
	DOC_FILE          =  'd',
	HTML_FILE         =  'h',
	INFORMATION       =  'i',
	SOUND_FILE        =  's'
}

/// Standard request terminator
enum ubyte[] GOPHER_REQUEST_TERMINATOR = [
	GOPHER_DELIMETER.CR,
	GOPHER_DELIMETER.LF
];

/// check if symbol of content type is castable to enum GOPHER_CONTENT
auto isGopherContentType(ubyte symbol)
{
	enum ubyte[] allContentTypes = cast(ubyte[]) [EnumMembers!GOPHER_CONTENT];
	
	bool isSupportedType = false;
	
	foreach (type; allContentTypes)
	{
		if (symbol == type)
		{
			isSupportedType = true;
			break;
		}
	}
	
	return isSupportedType;
}

/// create content type for path
auto createGopherContentType(string path)
{
	GOPHER_CONTENT type;
	auto extension = path.extension.toLower;
	
	switch (extension)
	{
		case ".c", ".d", ".di", ".h", ".txt", ".sh":
			type = GOPHER_CONTENT.TEXT_FILE;
			break;
		case ".uue":
			type = GOPHER_CONTENT.UUE_FILE;
			break;
		case ".bmp", ".jpg", ".jpeg", ".pgm", ".png", ".ppm", ".tiff":
			type = GOPHER_CONTENT.IMAGE_FILE;
			break;
		case ".gif":
			type = GOPHER_CONTENT.GIF_FILE;
			break;
		case ".gz", ".rar", ".tar.gz", ".zip":
			type = GOPHER_CONTENT.DOS_FILE;
			break;
		case ".html", ".htm":
			type = GOPHER_CONTENT.HTML_FILE;
			break;
		default:
			type = GOPHER_CONTENT.BINARY_FILE;
			break;
	}
	
	return type;
}
