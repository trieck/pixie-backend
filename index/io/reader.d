module io.reader;

abstract class Reader 
{
public:
    this() {
        _input = null;
    }

    this(Reader input) {
        _input = input;
    }

    int read() { 
        if (_input is null)
            return -1;

        return _input.read(); 
    }

protected:
    Reader _input;
}
