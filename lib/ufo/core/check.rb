module Ufo::Core::Check
  def check_task_definition!(task_definition)
    task_definition_path = "#{Ufo.root}/ufo/output/#{task_definition}.json"
    unless File.exist?(task_definition_path)
      puts "ERROR: Unable to find the task definition at #{task_definition_path}.".colorize(:red)
      puts "Are you sure you have defined it in ufo/template_definitions.rb?".colorize(:red)
      exit
    end
  end
end
