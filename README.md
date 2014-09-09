# Active Record Intro:  Validations

## Summary

In this challenge, we'll be working with Active Record validations.  When we defined database tables in SQL, we might have added a constraint to a column like `NOT NULL`, meaning that a value for column must be present.  Or, we might have specified a character limit some fields:  `VARCHAR(64)`.

Active Record allows us to perform similar validations within our models.  For example, when we try to save a new record to the database, Active Record will validate the object before attempting to save it.  If everything checks out, Active Record will run the SQL `INSERT` query.  If there's a problem with any of our object's attributes, Active Record will not run the SQL query.

```ruby
class Dog < ActiveRecord::Base
  include USGeography

  # name, license, and owner_id are required
  validates :name, :license, :owner_id, { :presence => true }

  # license must be unique for every dog
  validates :license, { :uniqueness => true }

  # license must start with two capital letters, a dash, then any characters
  validates :license, format: { with: /\A[A-Z]{2}\-/ }

  # age is not required, but if it's present, can't be less than 0
  validates :age, { :numericality => { greater_than_or_equal_to: 0 },
                    :allow_blank  => true }

  # custom validation for license
  validate :license_from_us_state

  def license_from_us_state
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

We will once again work with a pre-written `Dog` class.  The class is defined in the file `app/models/dog.rb`, whose code is shown in Figure 1; take a minute to look over the supplied validations.

### `validates`

Active Record will allow us to validate the value of an object's attributes.  Given an instance of `Dog`, I can require that its `name`, `age`, etc. meet certain conditions.  These validations are defined by the `validates` method and passing it the names of attributes as arguments.  For example, in our `Dog` class we'll see `validates :name, :license, :owner_id ...` and `validates :license ...` among other validations  This is saying that I want to first validate a `Dog` instances `name`, `license`, and `ownder_id` attributes in one way.  Then, I'm going to validate `license` again in another way.  

### Validation Helpers

How do we describe what a valid attribute looks like?  Active Record provides a number of [validation helpers](http://guides.rubyonrails.org/active_record_validations.html#validation-helpers).  These are provided for common types of validations.  We can see some of these in the code for our `Dog` class.

After passing in the names of the attributes that we want to validate, we need to specify options for the validation.  For example, `validates :license, { uniqueness: true }` if we only want unique values for `license` in the database or `validates :name { presence: true }` if we want to prevent `NULL` values for `name` from being saved to the database.

### Custom Validation Methods

In our `Dog` class, we have a method `license_from_us_state`.  This is a method written to perform a custom validation.  We want to be sure that any dog's license begins with the abbreviation of a valid US state.

Just as we had to set up our `Dog` class to perform validations on attributes, we have to also set up performing custom validations.  Instead of the `validates` method, we'll use the `validate` method and pass it the name of the custom validation method:  `validate :license_from_us_state`

### Errors

Active Record uses errors to determine whether or not an object is valid.  For each validation check, if the validation fails, a new error is added to the object's errors collection.  After validations are run, if an object has no errors, then its valid.  If it has an error, the object is invalid.

That is why our custom validation method calls `errors.add` under certain conditions.  That's our way of specifying that this custom validation has failed.  When we call `#add` on an object's errors, we pass in the name of the attribute that is invalid and a message describe the failure (e.g., `errors.add :license, "must be from a valid US state"`).

We are going to work in the console to see how these validations work.  As always, you're encouraged to read the [RailsGuides](http://guides.rubyonrails.org/active_record_validations.html) for a more comprehensive explanation.

## Releases

### Pre-release: Create, Migrate, and Seed the Database

1. Run Bundler to ensure that the proper gems have been installed.

2. Use the provided Rake task to create the database.

3. Use the provided Rake task to migrate the database.

4. Use the provided Rake task to seed the database.  This will seed the `dogs` table with three records.

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