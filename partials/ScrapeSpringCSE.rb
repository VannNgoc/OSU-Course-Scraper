require "mechanize"
require_relative "Section"
require "terminal-table"
=begin
  This class basicaally to use the get_section function to scrape course
  information with the course name passed into the function.
  @author: Simon Chen
          With the help from Vannaroth Ngoc.
=end
class ScrapeSpringCSE

  # params:
  # arguments = an array of course sections
  # Change the parameter into another format and search the course information
  # on the CSE schedule website. Then generate the class number, component,
  # location, times, instructor, session, topic.
  def self.get_section(arguments)
    #reformating of parameters.
    formated_args = []
    for arg in arguments
      formated_args << arg.downcase().delete("se")
    end

    #use the Mechanize gem
    mechanize = Mechanize.new
    page = mechanize.get("https://web.cse.ohio-state.edu/oportal/schedule_display")

    #refer to the div tag and table tag then group tag.
    for arg in formated_args
      table = page.css("##{arg} div table .group0, ##{arg} div table .group1")
      section_arr = []
      table_length = table.length
      0.upto(table_length - 1) do |i|
        cells = table[i].css("td")
        para_arr = []

        #pass the contents into the array
        for cell in cells
          if cell.content == " "
            para_arr << " N/A "
          else
            para_arr << cell.content
          end
        end
        #use another class to hold the values.
        single_section = Section.new(para_arr[0], para_arr[1], para_arr[2], para_arr[3], para_arr[4], para_arr[5], para_arr[6])
        section_arr << single_section
      end

      rows = []
      0.upto(table_length - 1) do |i|
        #puts the output in a table.
        rows << [section_arr[i].class_num.to_s, section_arr[i].class_num.to_s, section_arr[i].location.to_s,
                 section_arr[i].times.to_s, section_arr[i].instructor.to_s, section_arr[i].session.to_s, section_arr[i].topic.to_s]
      end
      output = Terminal::Table.new :rows => rows
      output = Terminal::Table.new :headings => ["Class Number", "Component", "Location",
                                                 "Times", "Instructor", "Session", "Topic"], :rows => rows
      puts output
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    end
  end
end
