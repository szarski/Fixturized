# fixturized [![Build Status](http://travis-ci.org/szarski/Fixturized.png)](http://travis-ci.org/szarski/Fixturized)

Fixturized makes your tests' data generation take less time.

Remember how fast fixtures used to work? But they were really painfull if you added one more after_save in your model - that filled some field in - and you had to update your fixture files.

FactoryGirl for instance is awesome because it gives you extreme flexibility. But it is also very slow if you save a lot of records to your db.

Fixturized is a solution in between fixtures and whatever you want, which means it will generate fixtures out of your FactoryGirl (or whatever you use) calls and refresh them if anything changes.

## installation

<pre>gem install fixturized</pre>

## usage

Let's say you want to speed up an existing test.

Test case like:

```ruby

describe User do
  before :each do
    @user = Factory :user
    @dog = Factory :dog
  end

  it "should know the dog's name" do
    @user.get_dog @dog
    @user.dog_name.should == @dog.name
  end
end

```

Becomes:

```ruby

describe User do
  before :each do
    fixturized do |o|
      o.user = Factory :user
      o.dog = Factory :dog
    end
  end

  it "should know the dog's name" do
    @user.get_dog @dog
    @user.dog_name.should == @dog.name
  end
end

```

## the way it works

When fixturized gets a block it:

  * check if fixtures exist for this block

If so:

  * clears the database
  * loads database content and variables

If not:

  * clears the database
  * runs the fixturized block
  * dumps db content
  * saves variable values

The first run will be slightly slower than usualy.

Each time the block's been changed, fixturized will generate the fixture for this particular block from stretch.

If you change your models in a way that affects their database layouts, you can just <pre>rm fixturized/*</pre> and it will create all the fixtures once again.

## drawbacks

There are two main problems with fixturized:

  * you can not stack fixturized blocks (each erases the database)
  * instead of using instance variables you need to use the Fixturized::Wrapper's methods:

  ```ruby
    @user = Factory :user
  ```

  becomes:

  ```ruby
    fixturized do |o|
      o.user = Factory :user
    end
  ```

## compatibility

Fixturized consits of several classes, each responsible for interactions with different interfaces:

  * DatabaseHandler - clears database, dumps db, loads db content, loads db records
  * FileHandler - reads and writes YAML files
  * Runner - runs the fixturized block, determines whether fixtures are up to date, hooks up the Wrapper
  * Wrapper - loads and saves all the data from the block using the rest of the modules

These classes currently support ActiveReord with an sql database and classic YAML fixtures.
To use different software you just need to replace one of the classes.

## Copyright

Copyright (c) 2010 Jacek Szarski. See LICENSE for details.
