module util.hash64;

class Hash64
{
public:
    /**
    * 64-bit Fowler/Noll/Vo hash
    */
    static long hash(byte[] key) {

        size_t i;
        long hash;

        for (hash = 0, i = 0; i < key.length; i++) {
            hash *= 1099511628211L;
            hash ^= key[i];
        }

        return hash;
    }
}
