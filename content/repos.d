module repos;

import config;

class Repository
{
public:
    static Repository instance() {
        if (_instance is null) {
            _instance = new Repository;
        }

        return _instance;
    }
private:
    this() {
        _config = new Config;
    }

    static Repository _instance;
    Config _config;
}