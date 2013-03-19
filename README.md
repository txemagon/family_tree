# FamilyTree

This gem creates a family tree using a specia syntax notation called _net syntax_.

## Installation

Add this line to your application's Gemfile:

    gem 'family_tree'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install family_tree

## Usage

Type:

    $ family_tree [options] file

Type --help for a complete list of options.

The default output format for the diagram is graphviz (dot).

You can use filters to specify the file.

    $ cat file | family_tree

redirections:

    $ family_tree < file

or here documents:

    $ family_tree <<HEREDOC
    ...
    HEREDOC

or even here strings:

    $ family_tree <<< "(Txema, Pepa)"

## Syntax

Several examples of the net syntax can be found under the examples directory.

In _family1.txt_ we found:

    # (): Family units - Male, Female, [children]
    # {}: Parents. Me { My Father, My Mother, [My siblings]}
    # $ : In-law
    # * : Main character.
    # · : Abortion
    # ! : sudden or out of the ordinary deaths
    
    (Txema, Laura, [(Pedro, $Valentina), ($Ramon {Remigio{[X][Y]}, Eusebia, [Fede, Alex]}, Juana)])

In the header we see comments specifying the notation meaning.
We can see that _Txema_ and _Laura_ are a family with children \[ \] _Pedro_ and _Juana_.
_Pedro_ has married to _Valentina_ $ stands for in-law, so she isn't the daughter of _Laura_ and _Txema_  
$_Ramon_'s parents \{ \} are _Remigio_ and _Eusebia_ and _Fede_ and Alex are _Remigio_'s brothers.
_X_ and _Y_ are _Ramon_'s grandparents.

In this other example we can see a divorce:

    (Txema, (Marga, [Jorge, Irene]), Pepa)

_Txema_ was married to _Marga_ and now has a relationship with _Pepa_.


    (Txema, (Marga, [Jorge, Irene]), (Pepa))

Now we see the marriage to _Pepa_ came to its end.

And below _Txema_ divorced _Marga_ and has a relation with _Pepa_, but _Marga_ the same _Marga_ is having a relationship with _JoseMaría_, so then we should write down:


    (Txema, (Marga@1, [Jorge, Irene]), Pepa)
    (JoseMaria, Marga@1)

With the _at_ sign we convert _Marga_ into a symbol, rather than into a String. Then, there is only one _Marga_ referenced as _Marga@1_ all over the tree. Other _Marga_s would take differrent index number if present.


This is a very compact notation to express in a very agile way a whole family tree, and to serialize it and transmit it through the net with a low bandwith cost. Furthermore, is a neutral notation in between some other application layers and languages: SQL, linked lists in memory, etc.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
