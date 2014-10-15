module indexfields;

class IndexFields
{
public:
    this(string[] fields) {
        _fields = fields.dup();
    }

    bool isTopLevel(string field) {
        foreach(f; _fields) {
            if (f == field)
                return true;
        }

        return false;
    }

    public size_t size() {
        return _fields.length;
    }

private:
    string[] _fields;
}