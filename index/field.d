module field;

class Field {
public:
    this(string name) {
        _name = name.dup();
        wordCount = 0;
    }

    @property string name() const {
        return _name;
    }

    @property ushort wordCount; // current word count

private:
    string _name;       // field name
}