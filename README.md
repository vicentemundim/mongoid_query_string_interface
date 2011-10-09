# Overview [![build status][1]][2]

[1]: https://secure.travis-ci.org/vicentemundim/mongoid_query_string_interface.png
[2]: http://travis-ci.org/#!/vicentemundim/mongoid_query_string_interface

### About Mongoid::QueryStringInterace

Gives some methods that can parse query string parameters into a set of criterias
that Mongoid can use to perform actual queries in MongoDB databases for a given
model.

### Repository

http://github.com/vicentemundim/mongoid_query_string_interface

## Installing

This is a gem, so you can install it by:

    sudo gem install mongoid_query_string_interface

Or, if you are using rails, put this in your Gemfile:

    gem 'mongoid_query_string_interface'

## Usage

To use it, just extend Mongoid::QueryStringInterface in your document model:

    class Document
      include Mongoid::Document
      extend Mongoid::QueryInterfaceString

      # ... add fields here
    end

Then, in your controllers put:

    def index
      @documents = Document.filter_by(params)
      # ... do something like render a HTML template or a XML/JSON view of documents
    end

That's it! Now you can do something like this:

    http://myhost.com/documents?tags.all=ruby|rails|mongodb&tags.nin=sql|java&updated_at.gt=2010-01-01&created_at.desc&per_page=10&page=3

This would get all documents which have the tags 'ruby', 'rails' and 'mongo',
and that don't have both 'sql' and 'java' tags, and that were updated after
2010-01-01, ordered by descending created_at. It will return 10 elements per
page, and the 3rd page of results.

You could even query for embedded documents, and use any of the Mongodb
conditional operators:

    http://myhost.com/documents?comments.author=Shrek

Which would get all documents that have been commented by 'Shrek'. Basically,
any valid path that you can use in a Mongoid::Criteria can be used here, and
you can also append any of the Mongodb conditional operators.

You can sort results by passing a order_by parameter this:

    http://myhost.com/documents?order_by=created_at.desc

or

    http://myhost.com/documents?order_by=created_at

Which is the same as:

    http://myhost.com/documents?order_by=created_at.asc

To order by more than one field:

    http://myhost.com/documents?order_by=created_at.desc|updated_at.desc

Check the specs for more use cases.

## Credits

- Vicente Mundim: vicente.mundim at gmail dot com
- Wandenberg Peixoto: wandenberg at gmail dot com
