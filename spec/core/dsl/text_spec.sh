#shellcheck shell=sh disable=SC2016

Describe '%text'
  Example 'outputs to stdout'
    func() {
      %text
      #|aaa
      #|bbb
      #|ccc
      #|
    }

    When call func
    The line 1 of entire output should eq 'aaa'
    The line 2 of entire output should eq 'bbb'
    The line 3 of entire output should eq "ccc"
    The line 4 of entire output should eq ""
    The lines of entire output should eq 4
  End

  Example 'using to set variable'
    func() {
      value=$(
        %text
        #|aaa
        #|bbb
        #|ccc
        #|
      )
    }

    When call func
    The line 1 of value "$value" should eq 'aaa'
    The line 2 of value "$value" should eq 'bbb'
    The line 3 of value "$value" should eq "ccc"
    The lines of value "$value" should eq 3
  End

  Example 'expands the variable'
    hello() {
      %text
      #|Hello $1
    }

    When call hello world
    The output should eq 'Hello world'
  End

  Example ':raw not expands the variable'
    hello() {
      %text:raw
      #|Hello $1
    }

    When call hello world
    The output should eq 'Hello $1'
  End

  Example 'outputs with filter'
    hello() {
      %text | tr 'a-z_' 'A-Z_'
      #|Hello $1
    }

    When call hello world
    The output should eq 'HELLO WORLD'
  End

  Example ':raw outputs with filter'
    hello() {
      %text:raw | tr 'a-z_' 'A-Z_'
      #|Hello $1
    }

    When call hello world
    The output should eq 'HELLO $1'
  End
End