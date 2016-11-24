Hyalite
====

[![Build Status](https://travis-ci.org/youchan/hyalite.svg?branch=master)](https://travis-ci.org/youchan/hyalite)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/youchan/hyalite?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)


This is ruby virtual DOM implementation using opal. It is inspired by react.js.

Example
----

```ruby
require 'hyalite'
require 'browser/interval'

class ExampleView
  include Hyalite::Component

  state :count, 0

  def component_did_mount
    every(5) do
      @state.count += 1
    end
  end

  def render
    div({class: 'example'},
      h2(nil, @props[:title]),
      h3(nil, "count = #{@state.count}")
    )
  end
end

$document.ready do
  Hyalite.render(Hyalite.create_element(ExampleView, {title: "Hyalite counter example"}), $document['.container'])
end
```

How to execute this example is the following.

```
> cd example
> rackup
```

Open url `http://localhost:9292`.
