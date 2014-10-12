module io.bufread;

import std.stdio;
import std.c.stdio;

class BufferedReader
{
public:
    this(string filename) {
        _file = File(filename);
        _pos = 0;
    }

    /**
    * Read a single character
    * @return the character read, or -1 if the end of stream has been reached
    */
    int read() {
        if (_pos == _read || _read == 0) {
            _read = fread(_buffer.ptr, char.sizeof, BUFFER_SIZE, _file.getFP());
            if (_read == 0)
                return -1;  // EOF
            _pos = 0;
        }

        return _buffer[_pos++];
    }

private:
    enum { BUFFER_SIZE = 8192 };    // buffer size
    char _buffer[BUFFER_SIZE];      // buffer
    File _file;                     // file structure
    size_t _pos;                    // current position in buffer
    size_t _read;                   // size of last buffer read
}