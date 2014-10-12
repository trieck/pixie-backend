module lexer;

import core.stdc.ctype;
import io.reader;
import io.tokenizer;

class Lexer : Tokenizer 
{
public:
    this(Reader reader) {
        super(reader);
    }

    /* get next token from reader */
    override string getToken() {
        auto output = "";

        clear();    // clear the token buffer

        int c;
        while ((c = read()) != -1) {
            if ((c == '_' || c == '\'') && output.length > 0) {
                output ~= cast(char)c;
            } else if (isalnum(c)) {
                output ~= cast(char)tolower(c);
            } else if (output.length > 0) {
                unread(1);
                break;
            }
        }

        return output;
    }
}