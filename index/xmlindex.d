module xmlindex;

import std.file;
import std.json;
import std.algorithm;
import std.string;
import io.fileread;
import repos;
import index;
import qparse;

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

    override void value(string value) {
        value = strip(value);

        if (value.length == 0)
            return; // whitespace

        auto field = elements[$-1];
    }

    override void startElement(string name, string tag) {
       elements ~= name;
        if (name == "record") {
            _offset = max(0, position - tag.length);
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
    size_t _offset;     // offset into current file
    string[] elements;  // stack of elements seen
}