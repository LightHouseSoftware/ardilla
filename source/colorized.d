module ardilla.colorized;

private {
	import std.stdio : writeln;
	import std.string : format;
}

void error(string message) 
{
	format("\u001b[31m\u001b[49m\u001b[1mError:\u001b[0m\u001b[97m\u001b[49m\u001b[1m %s \u001b[0m", message).writeln;
}

void info(string message) 
{
	format("\u001b[32m\u001b[49m\u001b[1mInfo:\u001b[0m\u001b[97m\u001b[49m\u001b[1m %s \u001b[0m", message).writeln;
}

void log(string message) 
{
	format("\u001b[34m\u001b[49m\u001b[1mLog:\u001b[0m\u001b[97m\u001b[49m\u001b[1m %s \u001b[0m", message).writeln;
}

void warning(string message) 
{
	format("\u001b[33m\u001b[49m\u001b[1mWarning:\u001b[0m\u001b[97m\u001b[49m\u001b[1m %s \u001b[0m", message).writeln;
}
