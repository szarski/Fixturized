# fixturized

Foxturized makes your tests' data generation take less time.

Remember how fast fixtures worked? But they were really painfull if you added one more after_save in your model that filled some field in and you had to update your fixture files.

FactoryGirl is awesome because it gives you extreme flexibility. But it is also very slow if you save a lot of models to your db.

Fixturized is a solution in between fixtures and whatever you want, which means it will generate fixtures out of your factory_girl calls and refresh them if anything changes.

## usage

Let's say you've got a test case like:

<pre>

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

</pre>

Becomes:

<pre>

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

</pre>

## the way it wors

In the first run fixturized:

  * clears the database
  * runs the block
  * dumps db content
  * saves variable values

The first run will be even slightly slower than usualy.

The second run fixturized:

  * check that fixtures exist for this block
  * loads database content and variables

Once the block's been changed, fixturized will go back to the first run.

If you change your models in a way that affects their database layouts, you can just <pre>rm fixturized/*</pre> and fixturized will create all the fixtures from stretch.

## drawbacks

There are two main problems with Fixturized:

  * you can not stack fixturized blocks (each erases the database)
  * instead of using instance variables you need to use wrapper's methods:
  <pre>
    @user = Factory :user
  </pre>
  becomes:
  <pre>
    fixturized do |o|
      o.user = Factory :user
    end
  </pre>

## compatibility

Fixturized consits of several classes, each responsible for interactions with different interfaces:

  * DatabaseHandler - clears database, dumps db, loads db content, loads db records
  * FileHandler - reads and writes YAML files
  * Runner - runs the fixturized block, determines whether fixtures are up to date, hooks up the Wrapper
  * Wrapper - loads and saves all the data from the block using the rest of the modules

These classes currently support ActiveReord with an sql database and classic YAML fixtures.
To use different software you probably just need to replace one of the classes.

## Copyright

Copyright (c) 2010 Jacek Szarski. See LICENSE for details.
