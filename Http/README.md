# Http Library

----------

## Obs: these libs are just templates. They use other programs like curl and socat. Below are the reasons.

I don't know how to make a http server reliably in pure Lua. 

If I used Lua's C API, I could use sys/socket.h and netinet/in.h, but I want to make the libs in pure Lua. Lua doesn't provide a way to use TCP/TLS sockets. And I don't think it should. The purpose of the language is to be both as simple and as functional as possible. Things like http should use the powerful C api. What I am doing is just testing the boundaries of Lua. 

I did use a subprocess to call for a program like curl, for a http client, or httpie, for a http server, but it's just a way to make the lib somewhat functional. It's far from ideal.
