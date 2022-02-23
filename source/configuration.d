module ardilla.configuration;

/*
	Server configuration
*/

// turn on using IPv6
enum bool IP_V6_MODE 					= true;
// visible domain in gopher data
enum string GOPHER_DOMAIN               = `<your domain>`;
// real gopher server ip
enum string GOPHER_IP	                = `<your IP or real domain>`;
// folder to serve via gopher
enum string GOPHER_FOLDER        	    = `<your folder>`;
// default gophermap filename
enum string GOPHER_MAP_FILENAME  		= `.gophermap`;
// default buffer size for gopher server
enum uint GOPHER_BUFFER_SIZE			= 8_192;
// maximum connections number
enum uint GOPHER_NUMBER_OF_CONNECTIONS  = 60;
