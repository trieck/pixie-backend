module config;

import std.json;
import std.file;
import std.conv;
import std.stdio;
import std.c.process;

class Config {
public:
    this() {
        _content = to!string(read("content.json"));
    }

    string getProperty(string k) {
        return "";
    }

    int getIntProperty(string k) {
        return 0;
    }
private:
    string _content;
}