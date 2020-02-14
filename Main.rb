require "mechanize"
require "nokogiri"
require "pdf-reader"
require "terminal-table"
require_relative "./partials/CourseInfo.rb"
require_relative "./partials/classSearch.rb"
require_relative "./partials/CommandParser.rb"
require_relative "./partials/ScrapeSpringCSE.rb"

=begin
  Program scrapes course info from various OSU CSE websites depending on a command by the user
  @author: Enrique Rosen
        additions from Vannaroth Ngoc, Simon Chen, Ben Brucoli
=end
class Main
  puts "Lab 3: Web Scraper"
  puts "type 'help' for valid commands"
  #recieves user input and checks for validity, if not valid repeats prompt
  print "\nEnter Command: "
  input = gets.chomp
  while (!CommandParser.valid?(input))
    print "Enter Command: "
    input = gets.chomp
  end

  action = CommandParser.action(input)
  arguments = CommandParser.argument(input)
  while action != "quit"
    #executes command based on user input
    case action
    when "search"
      classSearch(arguments)
    when "get course"
      CourseInfo.course_scrape(arguments)
    when "get section"
      ScrapeSpringCSE.get_section(arguments)
    when "get syllabus"
      print "\nFull pathway to download syllabus: "
      pathway = gets.chomp
      while (pathway == "")
        puts "\033[91mERROR: empty string is not a valid pathway!\033[00m"
        print "\nERROR: empty string is not a valid pathway!"
        print "\nFull pathway to download syllabus: "
        pathway = gets.chomp
      end
      CourseInfo.get_syllabus(arguments, pathway)
    when "help"
      CommandParser.VALID_ACTIONS.each { |action, description| puts "\e[36m#{action}: \e[0m#{description}" }
    end

    #recieves user input and checks for validity, if not valid repeats prompt
    puts ""
    print "Enter Command:"
    input = gets.chomp
    while (!CommandParser.valid?(input))
      print "Enter Command: "
      input = gets.chomp
    end
    action = CommandParser.action(input)
    arguments = CommandParser.argument(input)
  end

  puts "Goodbye!"
end
