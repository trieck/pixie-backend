module io.tempfile;

import std.stdio : File;
import std.random;
import std.file;
import std.path;

class Tempfile
{
public:
    static File create(string prefix, string suffix) {
        File file;

        string name;
        do {
            name = generate(prefix, suffix);
        } while (exists(name));
            

        file.open(name, "wb+");

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