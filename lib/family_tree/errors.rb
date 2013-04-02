module FamilyTree

  module Errors

    class NetError < StandardError
    end

    class LexerError < NetError
    end

    class MatchError < LexerError
    end

    class UnterminatedString < LexerError
    end

    class TokenError < NetError
    end

    class PaserError < NetError
    end

  end

end
