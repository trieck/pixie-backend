module repos;

import config;
import std.path;
import std.file;
import std.string : format;

class Repository
{
public:
    static Repository instance() {
        if (_instance is null) {
            _instance = new Repository;
        }

        return _instance;
    }

    string getPath() {
        auto repos = _config.getProperty("content.repos");
        if (repos.length == 0)
            throw new Exception("content.repos not set.");

        checkRepos(repos);

        return repos;
    }

    string mapPath(string db) {
        auto repos = getPath();

        auto path = buildNormalizedPath(repos) ~ dirSeparator ~ db;

        checkRepos(path);

        return path;
    }

    string getIndexPath(string db) {
        auto outPath = mapPath(db);

        return buildNormalizedPath(outPath) ~ dirSeparator ~ db ~ ".idx";
    }

    string getFile(string db, uint filenum) {
        auto dir = mapPath(db);

        auto output = format("%s%s%.4s.json", dir, dirSeparator, filenum + 1);

        return buildNormalizedPath(output);
    }

private:
    this() {
        _config = new Config;
    }

    void checkRepos(string dir) {
        if (!isDir(dir)) {
            auto message = format("\"%s\" is not a repository.",  buildNormalizedPath(dir));
            throw new Exception(message);
        }

    }

    static Repository _instance;
    Config _config;
}