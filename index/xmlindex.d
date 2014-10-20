module xmlindex;

import std.file;
import std.json;
import std.algorithm;
import std.string;
import io.fileread;
import io.strread;
import content.repos;
import index;
import qparse;
import lexer;
import anchor;
import indexfields;
import field;

class XMLIndexer : QParser
{
public:
    this() {
        _repos = Repository.instance();
        _elements = [];
    }

    void load(string db, string[] fields) {
        _fields = new IndexFields(fields);    // top-level index fields

        auto dir = _repos.mapPath(db);
        auto files = expand(dir);
        if (files.length == 0) {
            throw new Exception(format("no content files found in \"%s\".",
                dir));
        }
        _index = new Index;
        loadfiles(files);
        _index.write(db, fields);
    }

    override void value(string text) {
        
        if (_fieldNum == -1 || !isTopLevel())
            return;

        text = strip(text);

        if (text.length == 0)
            return; // whitespace

        auto field = _elements[$-1];
        auto wordNum = field.wordCount;

        Lexer lexer = new Lexer(new StringReader(text));
        ulong anchor;

        string term, tok;
        while ((tok = lexer.getToken()).length != 0) {
            term = format("%s:%s", field.name(), tok);
            anchor = Anchor.makeAnchorID(_filenum, _recOffset, cast(ushort)_fieldNum, wordNum++);
            _index.insert(term, anchor);
        }

        field.wordCount = wordNum;
    }

    override void startElement(string name, string tag) {
        _elements ~= new Field(name);
        if (name == "record") {
            _recOffset = cast(uint) max(0, position - tag.length);
            _fieldNum = -1;
            assert (_recOffset < (1 << Anchor.OFFSET_BITS));
        } else if (_recOffset > 0) {
            if (isTopLevel()) {
                _fieldNum++;
                assert(_fieldNum < (1 << Anchor.FIELDNUM_BITS));
            }
        }
    }

    override void endElement() {
        auto field = _elements[$-1];
        if (field.name == "record") {
            _recOffset = 0;
            _fieldNum = -1;
        }
        --_elements.length;
    }

private:
    void loadfiles(string[] files) {
        foreach (file; files) {
            loadfile(file);
            _filenum++;
        }
    }

    void loadfile(string file) {
        this.position = 0;
        parse(new FileReader(file));
    }

    string[] expand(string dir) {
        string[] files = [];

        auto entries = dirEntries(dir, "*.xml", SpanMode.shallow);
        foreach (entry; entries) {
            files ~= entry.name;
        }

        return files;
    }

    bool isTopLevel() {
        if (_elements.length == 0)
            return false;

        Field field = _elements[$-1];

        return _fields.isTopLevel(field.name);
    }

    Repository _repos;      // repository instance
    Index _index;           // index instance
    ubyte _filenum;         // current file number while indexing
    uint _recOffset;        // record offset into current file
    int _fieldNum;          // current top-level field number
    Field[] _elements;      // stack of elements seen
    IndexFields _fields;    // set of top-level fields for indexing
}