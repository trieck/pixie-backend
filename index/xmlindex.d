module xmlindex;

import std.file;
import std.json;
import std.algorithm;
import std.string;
import io.fileread;
import io.strread;
import repos;
import index;
import qparse;
import lexer;
import anchor;
import indexfields;

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
        text = strip(text);

        if (text.length == 0)
            return; // whitespace

        auto field = _elements[$-1];

        Lexer lexer = new Lexer(new StringReader(text));
        ulong anchor;

        string term, tok;
        for (ushort i = 0; ((tok = lexer.getToken()).length) != 0; ++i) {
            term = format("%s:%s", field, tok);
            anchor = Anchor.makeAnchorID(_filenum, _offset, i);
            _index.insert(term, anchor);
        }
    }

    override void startElement(string name, string tag) {
        _elements ~= name;
        if (name == "record") {
            _offset = cast(uint) max(0, position - tag.length);
        }
    }

    override void endElement() {
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

        string field = _elements[$-1];

        return _fields.isTopLevel(field);
    }

    Repository _repos;      // repository instance
    Index _index;           // index instance
    ushort _filenum;        // current file number while indexing
    uint _offset;           // offset into current file
    string[] _elements;     // stack of elements seen
    IndexFields _fields;    // set of top-level fields for indexing
}