=begin
  data structure to represent Sections
  @author: Simon Chen
=end
class Section

  # Contractor
  attr_accessor :class_num, :topic, :component, :instructor, :times, :session, :location

  def initialize(class_num, component, location, times, instructor, session, topic)
    @class_num = class_num
    @component = component
    @location = location
    @times = times
    @instructor = instructor
    @session = session
    @topic = topic
  end
end
