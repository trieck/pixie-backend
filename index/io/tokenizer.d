module io.tokenizer;

import std.algorithm;
import io.reader;
import io.pbread;

/** 
 * Lookahead tokenizer
 */
abstract class Tokenizer 
{
public:
    this(Reader r) {
        _reader = new PushbackReader(r);
        _buffer = "";
    }

    /**
     * Lookahead to the next token
     * @return the peeked token
     */
    final string lookahead() {
        auto tok = getToken();
        unread();   // unread the token buffer
        return tok;
    }

    /* get the next token from the reader */
    abstract string getToken();

protected:
    /**
     * Unread the entire token buffer
     */
    final void unread() {
        unread(_buffer.length);
    }

    /**
     * Unread characters from the token buffer
     * @param n, the number of characters to unread
     * @return the number of characters unread
     */
    final size_t unread(size_t n){
        auto m = min(_buffer.length, n);

        char c;
        for (size_t i = 0; i < m; ++i) {
            c = _buffer[m - i - 1];
            _reader.unread(c);
            _buffer.length--;
        }

        return m;
    }

    /* clear the token buffer */
    final void clear() {
        _buffer.length = 0;
    }

    /* read next character from reader into token buffer */
    final int read()  {
        int c = _reader.read();
        if (c != -1) {
            _buffer ~= cast(char)c;
        }

        return c;
    }
private:
    PushbackReader _reader;
    string _buffer;
}