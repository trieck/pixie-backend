module indexfields;

class IndexFields
{
public:
    this(string[] fields) {
        _fields = fields.dup();
    }

    bool isTopLevel(string field) {
        return false;
    }

    public size_t size() {
        return _fields.length;
    }

private:
    string[] _fields;
}