# Little Shop | Final Project | Backend Starter Repo

* Ruby/Rails version
We are working with:
    Ruby 3.2.2
    Rails 7.1.5.1

* System dependencies
In order for the project to function properly you will need:
    Ruby 3.2.2
    Rails 7.1.5.1
    Bundler version 2.5.23
    PostgreSQL
    Gems:
        SimpleCov (for code coverage reporting)
        Rspec-Rails (for testing)
        Pry (for debugging)
        Debug (advanced debugging tool)

* Configuration
Run these terminal commands in this order:
    bundle install
    bundle update
    bundle exec rspec
    rails server

* Database creation
Run this command in the terminal:
    rails db:{drop,create,migrate,seed}

* Database initialization
PostgreSQL
rails db:{create,migrate,seed}
To verify the database is working properly, you can run:
    bundle exec rspec
        If the tests all pass, then you know the database is working properly.

* How to run the test suite
To run the test suite:  
    Input 'bundle exec rspec' into the terminal.

To run the tests in postman:
    Run 'rails s' in the terminal.
    Navigate to postman, look through the drop downs and select the endpoint you want to run.
    Click send, then click 'Body', and select Test Results.