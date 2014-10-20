module io.strread;

import io.reader;

class StringReader : Reader
{
public:
    this(string str) {
        _str = str;
        _pos = 0;
    }

    override int read() {
        if (_pos == _str.length)
            return -1;

        return _str[_pos++];
    }
private:
    string _str;
    size_t _pos;
}