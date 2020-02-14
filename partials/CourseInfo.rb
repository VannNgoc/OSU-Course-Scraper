require "mechanize"
require "pdf-reader"
require "fileutils"

#Helper method to scrap_pdf, converts syllabus pdf to .txt file (DOES NOT DELETE syllabus text file after completion)
#params:
#syllabus_pathway = pathways to syllabus pdf
#return: pathway of text file version of Syllabus
#@author: Vannaroth Ngoc
def pdf_to_text(syllabus_pathway)
  text_name = File.basename(syllabus_pathway, ".pdf") + ".txt"
  text_pathway = "./.temp/#{text_name}" #note temp directory is hidden
  created_already = File.file?(text_pathway)
  if !created_already
    FileUtils.touch "#{text_pathway}"
    text_file = File.open(text_pathway, "w")
    reader = PDF::Reader.new(syllabus_pathway)
    reader.pages.each do |page|
      text_file.write(page.text)
    end
    text_file.close()
  end
  return text_pathway
end

=begin
  CourseInfo is repsonsible for scraping info from http://coe-portal.cse.ohio-state.edu/pdf-exports/CSE/
  @author: Ben Brucoli & Vannaroth Ngoc
=end
class CourseInfo
  #Takes a downloaded syllabus and parses course information and prints it.
  #params:
  #pdf_location = a location of a syllabus pdf on the PC
  #@author: Vannaroth Ngoc
  def self.scrap_pdf(pdf_location)
    attributes = ["course description", "course offerings", "out-of-class", "student ranks"]
    text_location = pdf_to_text(pdf_location)
    file_reader = File.open(text_location)
    until file_reader.eof?
      line = file_reader.gets()
      #course description on multiple lines so special case otherwise just print
      if line.downcase.include?(attributes[0])
        print "\033[95m#{line}\033[00m"
        line = file_reader.gets()
        while line != "\n"
          puts line
          line = file_reader.gets()
        end
      else
        for attr in attributes
          if line.downcase.include?(attr)
            substring_attr = line.match(/.*:/) #formatting reasons -> grabs attribute
            substring_info = line.match(/:.*/).to_s.delete(":") #formatting reasons -> grabs info
            puts "\033[95m#{substring_attr}\033[00m#{substring_info}"
          end
        end
      end
    end
    file_reader.close()
  end

  #Takes in an ARRAY of course numbers and downloads the associated syllabus in the .temp directory (DOES NOT DELETE DOWNLOADED syllabus after completion)
  #params:
  #course_number = an array of only the number portion of valid classnames ex.) CSE3901
  #save_directory = A complete pathway to a specified directory, default is a hidden temp directory
  #return:
  #An array with all the pathways to the newly downloaded syllabi
  #@author: Vannaroth Ngoc
  def self.get_syllabus(course_number, save_directory = "./.temp")
    agent = Mechanize.new
    agent.pluggable_parser.default = Mechanize::Download
    file_pathways = Array.new
    begin
      #handles cases if the syllabus is already downloaded
      for course in course_number
        course.downcase!
        if course.include?("cse")
          course.delete!("cse") #properly formats input for url
        end
        url = "http://coe-portal.cse.ohio-state.edu/pdf-exports/CSE/CSE-#{course}.pdf"
        file_save_location = File.join(save_directory, "Syllabus_CSE#{course}.pdf")
        file_pathways.push(file_save_location)
        if !File.file?(file_save_location)
          agent.get(url).save(file_save_location) #note may download to hidden .temp directory
          #success message if a file pathway was provided by the user
          if save_directory != "./.temp"
            puts "\033[92mCSE#{course} syllabus successfully downloaded to #{save_directory}\033[00m"
          end
        end
      end
      return file_pathways
    rescue
      puts("\033[91mERROR: Cannot download pdf with invalid course name CSE#{course}, subsequent courses will not be downloaded\033[00m")
    end
  end

  #Takes a course number and puts out Course, Hours, Requisites, and Exclusions
  #params:
  #course_num: this is the course number the user has inputed for search and is a string
  #@author: Ben Brucoli --> Received help from Vannaroth Ngoc and Simon Chen
  def self.course_scrape(course_num)
    mechanize = Mechanize.new
    page = mechanize.get("http://coe-portal.cse.ohio-state.edu/pdf-exports/CSE/")

    #refer to the div tag and table tag then group tr tag and then td tag to get all conents of the table
    table = page.css("div table tr td")

    for course in course_num
      course.downcase!
      if course.include?("cse")
        course.delete!("cse") #properly formats input for url
      end
      table_length = table.length
      count = 0
      for cell in table
        if count > 0 # This allows allows the next 5 elements in the css table to be printed
          if count == 3 # specifically for class hours
            puts "\033[95mHours:\033[00m " + cell.content.strip!
          end
          if count == 2 # Specifcally for Requisites
            puts "\033[95mRequisites:\033[00m " + cell.content.strip!
          end
          if count == 1 # specifically for Exclusions
            puts "\033[95mExclusions:\033[00m " + cell.content.strip!
          end
          count = count - 1
        end
        if cell.content == course
          puts "\n\n\e[36mCSE#{cell.content.to_s.delete('\n')}\e[0m"
          puts "_________________________"
          count = 5
        end
      end
      syllabus_pathway = CourseInfo.get_syllabus([course]) #method needs an array
      CourseInfo.scrap_pdf(syllabus_pathway[0])
    end
  end
end
