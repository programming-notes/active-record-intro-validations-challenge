# Active Record Intro:  Validations

## Summary
In this challenge, we'll be working with Active Record validations.  When we defined database tables in SQL or our migrations, we might have added a constraint to a column like `NOT NULL`, meaning that a value for the column must be present.  Or, we might have specified a character limit for some fields—for example, `VARCHAR(64)`.  These are called *constraints* and they guard against bad data getting into our database.

Database constraints are a necessary part of keeping our databases clear.  However, they are not a failsafe because a database can only do limited testing against a datum. It can't do regular expression matching or association testing.  Therefore we should augment your constraints at the database layer with Active Record validations at the application layer.  In short, we should use both constraints and validations to protect our databases.

How do Active Record validations help protect our database?  When we attempt to save a new record to the database, Active Record will validate the object before attempting to save it.  If everything checks out, Active Record will run the SQL `INSERT` query.  If there's a problem any our object (e.g., it's missing a required attribute), Active Record will not run the SQL query, and we'll never even attempt to write to the database.

```ruby
class Dog < ActiveRecord::Base
  include USGeography

  has_many :ratings
  belongs_to :owner, { class_name: "Person" }

  # owner must point to a record that actually exists (Person object)
  validates :owner, { :presence => true }

  # name and license are required
  validates :name, :license, { :presence => true }

  # license must be unique for every dog
  validates :license, { :uniqueness => true }

  # license must start with two capital letters, a dash, then any characters
  validates :license, format: { with: /\A[A-Z]{2}\-/ }

  # age is not required, but if it's present, can't be less than 0
  validates :age, { :numericality => { greater_than_or_equal_to: 0 },
                    :allow_blank  => true }

  validate :license_from_valid_state

  def license_from_valid_state
    unless self.license.instance_of? String
      errors.add :license, "must be a string"
      return
    end

    abbreviation = self.license[0..1]
    unless valid_state_abbreviation? abbreviation
      errors.add :license, "must be from a valid US state"
    end
  end
end
```

*Figure 1.*  Code for `Dog` class.

In this challenge, we'll continue to work with the `Dog`, `Rating`, and `Person` classes that we've seen in the other Active Record Intro challenges.  We'll be adding validations to the classes to protect our database.  The `Dog` class that we'll be working with has had a number of validations added to it (see Figure 1).  These validations provide an example for some of the types of validations that we can write and also a look at the syntax.


### The `.validates` Method
Active Record will allow us to validate an object's attributes.  Given a dog, we can require that its `name`, `age`, etc. meet certain conditions.  These validations are defined by the `.validates` method and passing in the names of attributes as arguments.  For example, in our `Dog` class we'll see that we're validating the name, license, age, and owner.


### Validation Helpers
How do we describe what a valid attribute looks like?  Active Record provides a number of [validation helpers](http://guides.rubyonrails.org/active_record_validations.html#validation-helpers).  These are provided for common types of validations.  We can see some of these in the code for our `Dog` class.

After passing in the names of the attributes that we want to validate, we need to specify options for the validation.  For example, we specify that we only want unique values for license in the database—two dogs can't have the same license.  And we prevent `NULL` values for `name` from being saved to the database, by validating the presence of the name attribute.  These are just a couple of the validation helpers that Active Record provides.  Which other helpers are we using in our `Dog` class?


### Custom Validation Methods
In our `Dog` class, we have a method `license_from_us_state`.  This is a method written to perform a custom validation.  We want to be sure that any dog's license begins with the abbreviation of a valid US state.

Just as we had to set up our `Dog` class to perform validations on attributes, we have to also set up performing custom validations.  Instead of the `.validates` method, we'll use the `.validate` method and pass in the name of the custom validation method:  `:license_from_valid_state`.


### Errors
Active Record uses errors to determine whether or not an object is valid.  For each validation check, if the validation fails, a new error is added to the object's errors collection.  After validations are run, if an object has no errors, then it's valid.  If it has an error, the object is invalid.

That is why our custom validation method calls `errors.add` under certain conditions.  That's our way of specifying that this custom validation has failed.  When we call `#add` on an object's errors, we pass in the name of the attribute that is invalid and a message describe the failure (e.g., `errors.add :license, "must be from a valid US state"`).

We are going to work in the console to see how these validations work.  As always, you're encouraged to read the [RailsGuides](http://guides.rubyonrails.org/active_record_validations.html) for a more comprehensive explanation.


## Releases
### Pre-release: Setup
```
$ bundle install
$ bundle exec rake db:create
$ bundle exec rake db:migrate
$ bundle exec rake db:seed
```
*Figure 2*.  Setting up and seeding the database.

Before we begin, we need to create, migrate, and seed our database.  We'll seed our database with records for all three models:  `Dog`, `Rating`, and `Person`.  All the files necessary for this are provided:  the migrations and the seeds file.  We simply need to run the Rake tasks (see Figure 2).

We're going to work with our `Dog` class from within the Rake console.  Let's begin by opening the console.  Once it's open, we can begin interacting with our models.  As we work through each release, we should execute the provided example code ourselves and look at the return values.


### Release 0: Exploring Validations and Errors

Use the provided Rake task to open the console:  `bundle exec rake console`.

From within the console run ...

-  `new_dog = Dog.new`

  This creates an instance of `Dog`.  All of its attributes are set to `nil`.

-  `new_dog.valid?`

  Calling `#valid?` on `new_dog` will perfom all the validations and then return `true` if all the validations pass or `false` if the object has any errors.  In this case we get `false`.

-  `new_dog.errors`

  This returns the errors that have been given to our `new_dog` object.

-  `new_dog.errors.count`

  This will tell us how many errors our `new_dog` object has:  5.

-  `new_dog.errors.messages`

  This returns a hash containing keys for any attribute that failed a validation.  The value of each key describes the nature of the failure—some are more descriptive than others.

  We can see that the `name` and `owner_id` attributes of `new_dog` each failed one validation.  `license` failed three.

-  `new_dog.errors.full_messages`

  If we prefer an array of error messages written as strings, we can call for the full messages.  This can be handy when we want to explain to users why something failed (e.g., the user couldn't register for a website because username has already been taken).

-  `new_dog.save`

  If we try to save `new_dog`, we see that `#save` returns false.  Because of the errors on `new_dog`, Active Record doesn't even try to insert the record.

- `new_dog.name = "Toot"`

  Previously, we saw the full error message that `"Name can't be blank"`.  So, we're assigning it a value.

-  `new_dog.valid?`

  We've only fixed one of `new_dogs` validation problems, so the object is still invalid.

- `new_dog.errors.count`

  Now, however, the object only has four errors, not the five that it had previously.

Continue updating the attributes of `new_dog` until `new_dog.save` returns `true`.  Then exit the console.

### Release 2: Write Validations for `Rating` and `Person`

Tests have been written to describe the validations that we want for our models.  Take a look at the tests for the `Dog` class's validations in the file `source/spec/models/dog_spec.rb`.  The code provided in the `Dog` class passes these tests.

Tests describing the validations we want for the `Rating` and `Person` classes have also been written.  You should not need to write any custom validation methods; the validation helpers provide the functionality required. Exact examples have not been provided in the `Dog` class for how to pass all of these tests.  You will need to explore the RailsGuides or try a Google search.  Write the validations needed to pass the provided tests before submitting this challenge.
