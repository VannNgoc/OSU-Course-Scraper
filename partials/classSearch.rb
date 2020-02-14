require "mechanize"

#Function helps with looking up courses containing key words
#@author: Enrique Rosen
def classSearch(class_name)
  mechanize = Mechanize.new
  for course in class_name
    name = course
    page = mechanize.get("https://cse.osu.edu/courses?subject=all&campus=all&level=all&course_name=#{name}&acad_career=all")

    list = page.search("tr")
    list.shift
    puts "\n\e[36mAvailable Classes With Keyword: #{name}\e[0m"
    puts "________________________________"
    puts ""
    list2 = Array.new
    list.each { |x| list2.push(x.search("td")[0].text + ": " + x.search("a").text) }
    puts list2.empty? ? "No Available Classes" : list2.uniq
  end
  puts "\nfor more information go to: https://cse.osu.edu/courses\n"
end
