module util.hash32;

class Hash32
{
    /**
    * 32-bit Fowler/Noll/Vo hash
    */
    public static uint hash(string key) {
        uint i;
        uint hash;

        for (hash = 0, i = 0; i < key.length; i++) {
            hash *= 16777619;
            hash ^= key[i];
        }

        return hash;
    }
}