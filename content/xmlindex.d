module xmlindex;

import std.file;
import std.json;
import repos;
import index;
import qparse;

class XMLIndexer : QParser
{
public:
    this() {
        _repos = Repository.instance();
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

private:
    void loadfiles(string[] files) {
        foreach (file; files) {
            ;
        }
    }

    string[] expand(string dir) {
        string[] files = [];

        auto entries = dirEntries(dir, "*.xml", SpanMode.shallow);
        foreach (entry; entries) {
            files ~= entry.name;
        }

        return files;
    }

    Repository _repos;   // repository instance
    Index _index;        // index instance
    ushort _filenum;     // current file number while indexing
    uint _offset;        // offset into current file
}