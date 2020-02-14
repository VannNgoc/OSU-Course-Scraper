=begin
  Checks for valid commands inputted by the user
  @author: Vannaroth Ngoc
=end
class CommandParser
  #hash of valid action and their descriptions.
  @@VALID_ACTIONS = {
    "get course" => "Grabs info about desired courses ex: get course->CSE3901 CSE3902 CSE3903",
    "get syllabus" => "Downloads the syllabus associated with specified class ex: get syllabus->CSE3901 CSE3902 CSE3903",
    "search" => "Will look at each keyword and prints list of classes with that one specified keyword ex: search->graphics java",
    "get section" => "Grabs all the sections for the specified courses ex: get section->CSE3901 CSE3902 CSE3903",
    "quit" => "quits the program ex: quit",
  }

  #A getter for @@VALID_ACTION
  def self.VALID_ACTIONS
    return @@VALID_ACTIONS
  end

  #Checks whether a string is a valid command. A valid command is three portions with no spaces between; an action, '->', and argument ex.) search->design
  #@param:
  #command = the command string inputted by the user
  #@Returns: a boolean whether it is a valid command
  def self.valid?(command)
    valid_command = false
    command_seperated = command.partition(/->/)
    arrow_present = (command_seperated[1] == "->")
    if (command.to_s.downcase == "quit") || (command.to_s.downcase == "help")
      valid_command = true
      #Nested if-else statements first checks if there is an arrow THEN valid action THEN valid arguments
      #if any of them are not valid it will stop checking the rest of the requirements and will return false
    elsif !arrow_present
      puts "\033[91mERROR: There is no '->' in the command!\033[00m"
    else
      action_valid = @@VALID_ACTIONS.has_key?(command_seperated[0].downcase)
      if !action_valid
        puts("\033[91mERROR: #{command_seperated[0]} is not a valid command!\033[00m")
      else
        argument_valid = CommandParser.argument?(command_seperated[0], command_seperated[2].split(" "))
        if argument_valid
          valid_command = true #successfully passed all requirements
        end
      end
    end
    return valid_command
  end

  #checks to see whether the arguments are valid for the given action call
  #@requires: action is a valid action
  #@params:
  #action = a valid action
  #argument = an array of the inputted arguments
  #@return: a boolean whether the argument is valid
  def self.argument?(action, argument)
    valid_argument = false
    counter = 0
    #search is the only only one to take a differnt input format
    if action == "search"
      valid_argument = true #default true because search will just print "No available classes" with the keywords that don't exist in any classes.
    else
      for arg in argument
        if arg.match(/(C|c)(S|s)(E|e)[0-9]+/).to_s.length == arg.length #if the match function return a string of the same size it means they are the same string
          counter += 1
        else
          puts("\033[91mERROR: #{arg} is not a valid argument for '#{action}'!\033[00m")
        end
      end
      valid_argument = counter == argument.size
    end
    return valid_argument
  end

  #retrieves argument portion of a valid command
  #@requires: command is a VALID command... action->argument
  #@param:
  #command  = a string in format of action->argument
  #@return: argument portion of the command as an array
  def self.argument(command)
    return command.partition(/->/)[2].split(" ")
  end

  #retrieves action portion of a valid command
  #@requires: command is a valid command... action->argument
  #@param:
  #command  = a string in format of action->argument
  #@return: action portion of the command as all lower case
  def self.action(command)
    return command.partition(/->/)[0].downcase
  end
end
