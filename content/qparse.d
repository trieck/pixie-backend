module qparse;

import pbread;

abstract class QParser
{
public:
    void parse(string filename) {
        _reader = new PushbackReader(filename);
        parse();
    }

protected:
    @property size_t position;   // position in input stream
private:    
    void parse() {
        int c;
        while ((c = read()) != -1) {
            ;
        }
    }

    /**
     * Lookahead n characters
     * @param n, the number of characters to lookahead
     * @return char array up to n characters
     */
    char[] lookahead(int n) {
        char[] buffer = new char[n];

        // doesn't alter position

        int i, c;
        for (i = 0; i < n && (c = _reader.read()) != -1; ++i) {
            buffer[i] = cast(char) c;
        }

        // unread the characters read
        _reader.unread(buffer, 0, i);

        return buffer;
    }

    int read() {
        int c = _reader.read();
        position++;
        return c;
    }

    /**
     * Unget a character from the reader
     * @param c the character to unget
     */
    void unget(int c) {
        _reader.unread(c);
        position--;
    }

    enum { 
        UNDEFTAG = 0x0000,  /* undefined tag */
        BEGINTAG = 0x0001,  /* begin tag */
        ENDTAG = 0x0002,    /* end tag */
        EMPTYTAG = 0x0004,  /* empty tag */
        PROCTAG = 0x0008,   /* processing instruction tag */
        DECLTAG = 0x0010,   /* declaration tag */
    }

    PushbackReader _reader;     // push back reader         
}
