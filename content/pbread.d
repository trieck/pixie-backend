module pbread;

import std.stdio;
import std.c.stdio;

class PushbackReader
{
public:
    this(string filename) {
        _file = File(filename);
    }

    /**
    * Read a single character
    * @return the character read, or -1 if the end of stream has been reached
    */
    int read() {
        if (_pos == _read) {
            _read = fread(_buffer.ptr, char.sizeof, _buffer.length, _file.getFP());
            if (_read == 0)
                return -1;  // EOF
            _pos = 0;
        }

        return _buffer[_pos++];
    }

    /**
     * Pushes back a single character by copying it to the front of the
     * pushback buffer.
     */
    void unread(int c) {
        if (_pos == 0)
            throw new Exception("Pushback buffer overflow");

        _buffer[--_pos] = cast(char)c;
    }

    void unread(char[] buffer, int start, int length) {
        for (int i = start; i < length; ++i) {
            unread(buffer[i]);
        }
    }

private:
    enum { BUFFER_SIZE = 8192 };    // buffer size
    char _buffer[BUFFER_SIZE];      // pushback buffer
    File _file;                     // file structure
    size_t _pos;                    // current position in buffer
    size_t _read;                   // size of last buffer read
}