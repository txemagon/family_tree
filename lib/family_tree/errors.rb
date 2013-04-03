module FamilyTree

  module Errors

    class NetError           < StandardError;  end;
    class LexerError         < NetError;       end;
    class MatchError         < LexerError;     end;
    class UnterminatedString < LexerError;     end;
    class TokenError         < NetError;       end;
    class ParserError        < NetError;       end;
    class DOMException       < NetError;       end;
    class DOMError           < DOMException;   end;
    class DOMWarning         < DOMException;   end;

  end

end
