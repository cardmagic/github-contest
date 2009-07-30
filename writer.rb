module Writer
  def write_results(file_path, answers)
    File.open(file_path, 'w') do |file|
      answers.each do |line|
        file.puts line
      end
    end
  end
  
  module_function :write_results
end