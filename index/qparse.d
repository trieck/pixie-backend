module qparse;

import io.reader;
import io.pbread;

/**
* Simple abstract "Quick & Dirty" SAX-like XML parser
* <p/>
* This class is useful for keeping track
* of the current position in the input stream when
* processing a node in the xml tree.
*/
abstract class QParser
{
public:
    void parse(Reader reader) {
        _reader = new PushbackReader(reader);
        parse();
    }

    abstract void value(string value);
    abstract void startElement(string name, string tag);
    abstract void endElement();

    string startTag() {
        auto tag = "";

        int c;
        while ((c = read()) != -1) {
            tag ~= cast(char) c;
            if (c == '>')
                break;
        }

        return tag;
    }

    string endTag() {
        if ((_type & EMPTYTAGS) != 0) {
            _type = UNDEFTAG;
            return "";
        }

        auto tag = "";

        int c;
        while ((c = read()) != -1) {
            tag ~= cast(char)c;
            if (c == '>')
                break;            
        }

        _type = UNDEFTAG;

        return tag;
    }

protected:
    @property size_t position;   // position in input stream
private:    
    void parse() {
        int c;
        char[] buffer;
        string tag, name;

        while ((c = read()) != -1) {
            buffer = lookahead(3);
            unget(c);

            if (c != '<') { // not a tag
                value(getValue());
                continue;
            }

            switch (buffer[0]) {
                case '/':   // end tag
                    endTag();
                    endElement();
                    break;
                case '!':   // xml comment
                    if (buffer[1] == '-' && buffer[2] == '-') {
                        getComment();
                        _type = UNDEFTAG;
                    }
                    // fallthrough
                default:
                    tag = startTag();
                    _type = tagType(tag);
                    name = tagName(tag);
                    startElement(name, tag);
                    if (_type == EMPTYTAG)
                        endElement();
                    break;
            }
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

    string getValue() {
        auto value = "";

        int c;
        while ((c = read()) != -1) {
            if (c == '<') { // tag
                unget(c);
                break;
            }
            value ~= cast(char)c;
        }

        return value;
    }

    /**
     * Determine the type of a tag
     *
     * @param tag the tag to determine
     * @return the tag type
     */
    int tagType(string tag) {
        
        for (int i = 0; i < tag.length; i++) {
            switch (tag[i]) {
                case '<':
                    if (i < tag.length - 1 && tag[i + 1] == '!')
                        return DECLTAG;
                    if (i < tag.length - 1 && tag[i + 1] == '?')
                        return PROCTAG;
                    if (i < tag.length - 1 && tag[i + 1] == '/')
                        return ENDTAG;
                    break;
                case '>':
                    if (i > 0 && tag[i - 1] == '/')
                        return EMPTYTAG;
                    return BEGINTAG;
                default:
                    break;
            }
        }

        return UNDEFTAG;
    }

    string tagName(string tag) {
        auto name = "";

        foreach (c; tag) {
            switch (c) {
                case '\t':
                case '\n':
                case '\r':
                case ' ':
                case '>':
                case '/':
                    return name;
                case '<':
                case '!':
                case '?':
                    continue;
                default:
                    name ~= c;
            }
        }

        return name;
    }

    string getComment() {

        auto comment = "";

        int c;
        char[] buffer;

        while ((c = read()) != -1) {
            buffer = lookahead(2);
            if (c == '-' && buffer[0] == '-' && buffer[1] == '>') {
                comment ~= cast(char)c;    // -->
                comment ~= cast(char)read();
                comment ~= cast(char)read();
                break;
            }
            comment ~= cast(char)c;
        }

        return comment;
    }

    enum { 
        UNDEFTAG = 0x0000,  /* undefined tag */
        BEGINTAG = 0x0001,  /* begin tag */
        ENDTAG = 0x0002,    /* end tag */
        EMPTYTAG = 0x0004,  /* empty tag */
        PROCTAG = 0x0008,   /* processing instruction tag */
        DECLTAG = 0x0010,   /* declaration tag */
        EMPTYTAGS = (EMPTYTAG | PROCTAG | DECLTAG)
    }

    PushbackReader _reader; // push back reader
    int _type;              // tag type
}
