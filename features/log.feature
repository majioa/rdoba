Feature: Rdoba Log
   In order to check proper logging facility
   Rdoba Log should work with various settings

   Scenario: Rdoba Log default settings
      Given applied Rdoba Log module
      When we issue an output of a variable
      And look into stdout
      Then we see the variable output

   Scenario: Rdoba Debug backward compatibility with warning
      Given applied Rdoba Debug module
      When we issue an output of a variable
      And we look into stderr
      Then we see a warning
      When look into stdout
      Then we see the variable output

   Scenario: Rdoba Log :io option
      Given applied Rdoba Log module with set a file name for :io option
      When we issue an output of a variable
      And look into the file
      Then we see the variable output
      When look into stdout
      Then we see nothing

   Scenario: Rdoba Log :as option
      Given applied Rdoba Log module with set a keyword for :as option
      When we issue an output of a variable
      And look into stdout
      Then we see nothing
      When we look into stderr
      And see the no method error exception

      When we issue an output of a variable using a keyword
      And look into stdout
      Then we see the variable output

      When we issue an output of a variable using an invalid keyword
      And look into stdout
      Then we see nothing
      When we look into stderr
      Then see the name error exception

   Scenario: Rdoba Log :in option
      Given applied Rdoba Log module with set Cls keyword for :in option
      When we issue an output of a variable
      And look into stdout
      Then we see nothing
      When we look into stderr
      Then see the no method error exception

      When issue a creation of the class
      And look into stdout
      Then we see the variable output

   Scenario: Rdoba Log :functions option
      Given applied Rdoba Log module with set :extended keyword for :functions option
      When we issue an :extended output of a variable
      And look into stdout
      Then we see the variable output with the :extended notice

      When we remove :extended keyword out of :functions option
      And we issue an :extended output of a variable
      And look into stdout
      Then we see nothing

      When we issue an :enter output of a variable
      And look into stdout
      Then we see nothing
      When we add :enter keyword out of :functions option
      And we issue an :enter output of a variable
      And look into stdout
      Then we see the variable output with the :enter notice

      When we issue a :leave output of a variable
      And look into stdout
      Then we see nothing
      When we add :leave keyword out of :functions option
      And issue a :leave output of a variable
      And look into stdout
      Then we see the 'true' value output with the :leave notice

      When we issue an :info output of a variable
      And look into stdout
      Then we see nothing
      When we add :info keyword out of :functions option
      And we issue an :info output of a variable
      And look into stdout
      Then we see the variable output with the :info notice

      When we issue an :warn output of a variable
      And look into stdout
      Then we see nothing
      When we add :warn keyword out of :functions option
      And we issue an :warn output of a variable
      And look into stdout
      Then we see the variable output with the :warn notice

      When we issue a :compat output of a variable
      And look into stdout
      Then we see nothing
      When we look into stderr
      Then see the no method error exception

      When we add :compat keyword out of :functions option
      And issue a :compat output of a variable
      And look into stdout
      Then we see the variable output

      When we clear the :functions option
      And we issue an output of a variable
      And look into stdout
      Then we see nothing

   Scenario: Rdoba Log :prefix option
      Given applied Rdoba Log module with set :timestamp keyword for :prefix option
      When we issue an output of a variable
      And look into stdout
      Then we see the variable output preficed with the :timestamp

      When we apply Rdoba Log module with set :timestamp, and :pid keyword for :prefix option
      And issue an output of a variable
      And look into stdout
      Then we see the variable output preficed with the :timestamp, and :pid

      When we apply Rdoba Log module with set :timestamp, :pid, and :function_name keyword for :prefix option
      And issue an output of a variable
      And look into stdout
      Then we see the variable output preficed with the :timestamp, :pid, and :function_name

      When we apply Rdoba Log module with set :timestamp, :pid, :function_name, and :function_line keyword for :prefix option
      And issue an output of a variable
      And look into stdout
      Then we see the variable output preficed with the :timestamp, :pid, :function_name, and :function_line

      When we apply Rdoba Log module with set :timestamp, :pid, and :function_line keyword for :prefix option
      And issue an output of a variable
      And look into stdout
      Then we see the variable output preficed with the :timestamp, :pid

   Scenario: Rdoba Log parameter processing
      Given applied Rdoba Log module
      When we issue an output of a string
      And look into stdout
      Then we see the string output

      When we issue an output of a number
      And look into stdout
      Then we see the number output

      When we issue an output of an array
      And look into stdout
      Then we see the array output

   Scenario: Rdoba Exception information output
      Given applied Rdoba Log module
      When we issue an output of the thrown exception
      And look into stderr
      Then we see the exception info

      When we issue an output of the thrown exception to the stdout
      And look into stderr
      Then we see nothing
      When we look into stdout
      Then we see the exception info

      When we issue an output of the thrown standard error
      And look into stderr
      Then we see the standard error info

      When we issue an output of the thrown standard error with a notification
      And look into stderr
      Then we see the standard error info with a notification

   Scenario: Rdoba Log class implementation
      Given applied Rdoba Log module inside a class
      When we issue an output of a variable
      And look into stdout
      Then we see the variable output

      When define an output of a variable inside an initializer
      And issue a creation of the class
      And look into stdout
      Then we see the variable output

      When we define an output of a variable inside a singleton function
      And issue a call to the function
      And look into stdout
      Then we see the variable output

      When we apply Rdoba Log module with set a keyword for :as option inside a class
      And issue an output of a variable using a keyword
      And look into stdout
      Then we see the variable output

      When define an output of a variable inside an initializer using a keyword
      And issue a creation of the class
      And look into stdout
      Then we see the variable output

      When we define an output of a variable inside a singleton function using a keyword
      And issue a call to the function
      And look into stdout
      Then we see the variable output

