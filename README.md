Ruby Cyclomatic Complexity Plugin
=================================

`rubycomplexity.vim` plugin computes how complex your methods are using Flog magic and
neatly displays it to you in the signs column next to your code.

![Screen shot](http://github.com/skammer/vim-css-color/raw/master/Screen%20shot%202010-11-29%20at%2013.23.46.png)

Requirements
------------

* ruby
* flog rubygem
* vim 7.2+, compiled with:
  * +ruby
  * +signs

Configuration
-------------

`g:rubycomplexity_enable_at_startup`

Turn automatic plugin loading on and off. Set it to `0` if you do not want to
`call ShowComplexity()` on every read or write of \*.rb file

Colors:

`g:rubycomplexity_color_low`

Sets color for low compelxity signs. Default value is `"#004400"`.

`g:rubycomplexity_color_medium`

Sets color for medium complexity signs. Default value is `"#bbbb00"`.

`g:rubycomplexity_color_high`

Sets color for high complexity signs. Default value is `"#ff2222"`.

Ranges:

`g:rubycomplexity_medium_limit`

Sets medium complexity limit. Default value is `7`.

`g:rubycomplexity_high_limit`

Sets high complexity limit. Default value is `14`.


`0------7------14-------max`
`       |       \`
`       |        -g:rubycomplexity_high_limit`
`       \`
`        -g:rubycomplexity_medium_limit`

Known bugs
----------

* flog fails on blocks and multiline string
* signs do not update properly in some cases

Links
-----

@garybernhardt's '[pycomplexity.vim](http://bitbucket.org/garybernhardt/pycomplexity).

@topfunky's [rubycomplexity.el](https://github.com/topfunky/emacs-starter-kit/tree/master/vendor/ruby-complexity/)

