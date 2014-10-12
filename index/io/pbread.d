module io.pbread;

import io.bufread;

class PushbackReader : BufferedReader
{
public:
    this(string filename) {
        super(filename);
        _pos = BUFFER_SIZE;
    }

    /**
    * Read a single character
    * @return the character read, or -1 if the end of stream has been reached
    */
    override int read() {
        if (_pos == BUFFER_SIZE) {
            return super.read();
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
        for (int i = start + (length-1); i >= start; --i) {
            unread(buffer[i]);
        }
    }

private:
    enum { BUFFER_SIZE = 100 };     // pushback buffer size
    char _buffer[BUFFER_SIZE];      // pushback buffer
    size_t _pos;                    // current position in buffer
}