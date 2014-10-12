module config;

import std.json;
import std.file;
import std.conv;
import std.stdio;
import std.c.process;

class Config 
{
public:
    this() {
        auto content = to!string(read("content.json"));
        _json = parseJSON(content).object;
    }

    string getProperty(string k) {
        return _json[k].str;
    }

    long getIntProperty(string k) {
        return _json[k].integer;
    }
private:
    JSONValue _json;
}