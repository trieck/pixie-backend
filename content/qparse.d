module qparse;

import std.stdio;

abstract class QParser
{
public:
    void parse(string filename) {
        auto file = File(filename);
    }

private:
    @property ulong _position;    // position in input stream
}
