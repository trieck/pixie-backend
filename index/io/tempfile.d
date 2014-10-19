module io.tempfile;

import std.stdio : File;
import std.random;
import std.file;
import std.path;

static File[] tmpfiles;

static ~this() {
    foreach(file; tmpfiles) {
        file.close();
        if (exists(file.name())) {
            remove(file.name());
        }
    }
}

class Tempfile
{
public:
    static synchronized File create(string prefix, string suffix) {
        File file;

        string name;
        do {
            name = generate(prefix, suffix);
        } while (exists(name));
            
        file.open(name, "wb+");

        tmpfiles ~= file;

        return file;
    }
private:
    static string generate(string prefix, string suffix) {
        // Generate a uniformly-distributed integer in the range [0, ulong.max - 1]
        auto r = uniform(0, ulong.max-1);

        auto dir = tempDir();

        auto path = format("%s%s%s-%s.%s", dir, dirSeparator, prefix, r, suffix);

        path = buildNormalizedPath(path);

        return path;
    }
}