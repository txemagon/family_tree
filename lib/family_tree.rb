require "open4"
require "colorize"
require "family_tree/version"
require "family_tree/errors"
require "family_tree/tokens"
require "family_tree/lexer"
require "family_tree/dom/person"
require "family_tree/dom/relationship/children"
require "family_tree/dom/relationship"
require "family_tree/parser/progenitors"
require "family_tree/parser"
require "family_tree/formatter"
require "family_tree/output_type"
require "family_tree/output_type/dot"
require "family_tree/driver"
require "family_tree/utils"
#require "debugger"

include FamilyTree::Errors
include FamilyTree::Tokens
include FamilyTree::DOM

module FamilyTree

end
