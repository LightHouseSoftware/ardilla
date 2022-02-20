module ardilla.server;

private {
	import std.algorithm : remove;
	import std.socket;
}

class GenericSimpleServer(uint BUFFER_SIZE, uint MAXIMAL_NUMBER_OF_CONNECTIONS)
{
	protected {
		ubyte[BUFFER_SIZE] _buffer;
		
		string 	   _address;
		ushort     _port;
		Socket     _listener;
		Socket[]   _readable;
		SocketSet  _sockets;
	}
	
	abstract ubyte[] handle(ubyte[] request);
	
	final void run()
	{
		while (1)
		{
			serve;
			
			scope(failure) {
				_sockets = null;
				_listener.close;
			}
		}
	}
	
	final void setup4(string address, ushort port, int backlog = 10)
	{
		_address = address;
		_port = port;
		_listener = new Socket(AddressFamily.INET, SocketType.STREAM);

		with (_listener)
		{
			bind(new InternetAddress(_address, _port));
			listen(backlog);
		}
		
		_sockets = new SocketSet(MAXIMAL_NUMBER_OF_CONNECTIONS + 1);
	}
	
	final void setup6(string address, ushort port, int backlog = 10)
	{
		_address = address;
		_port = port;
		_listener = new Socket(AddressFamily.INET6, SocketType.STREAM);

		with (_listener)
		{
			bind(new Internet6Address(_address, _port));
			listen(backlog);
		}
		
		_sockets = new SocketSet(MAXIMAL_NUMBER_OF_CONNECTIONS + 1);
	}
	
	private
	{
		final void serve()
	    {
	        _sockets.add(_listener);
	
	        foreach (socket; _readable)
	        {
	            _sockets.add(socket);
			}
	
	        Socket.select(_sockets, null, null);
	
	        for (uint i = 0; i < _readable.length; i++)
	        {
	            if (_sockets.isSet(_readable[i]))
	            {                
	                auto realBufferSize = _readable[i].receive(_buffer);
	
					if (realBufferSize != 0)
	                {
						auto data = _buffer[0..realBufferSize];
						
						_readable[i].send(
							handle(data)			
						);
	                }
					
	                _readable[i].close;
	                _readable = _readable.remove(i);
	                i--;
	            }
	        }
	
	        if (_sockets.isSet(_listener))
	        {
	            Socket currentSocket = null;
	            
	            scope (failure)
	            {
	                if (currentSocket)
	                {
	                    currentSocket.close;
					}
	            }
	            
	            currentSocket = _listener.accept;
	            
	            if (_readable.length < MAXIMAL_NUMBER_OF_CONNECTIONS)
	            {
	                _readable ~= currentSocket;
	            }
	            else
	            {
	                currentSocket.close;
	            }
	        }
	
	        _sockets.reset;
		}
	}
}
