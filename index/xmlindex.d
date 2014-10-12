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

class XMLIndexer : QParser
{
public:
    this() {
        _repos = Repository.instance();
        elements = [];
    }

    void load(string db) {
        auto dir = _repos.mapPath(db);
        auto files = expand(dir);
        if (files.length == 0) {
            throw new Exception(format("no content files found in \"%s\".",
                dir));
        }
        _index = new Index;
        loadfiles(files);
    }

    override void value(string text) {
        text = strip(text);

        if (text.length == 0)
            return; // whitespace

        auto field = elements[$-1];

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
       elements ~= name;
        if (name == "record") {
            _offset = cast(uint) max(0, position - tag.length);
        }
    }

    override void endElement() {
       --elements.length;
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

    Repository _repos;  // repository instance
    Index _index;       // index instance
    ushort _filenum;    // current file number while indexing
    uint _offset;       // offset into current file
    string[] elements;  // stack of elements seen
}