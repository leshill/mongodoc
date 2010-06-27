# vim:set filetype=ruby:
def run(cmd)
  puts cmd
  system cmd
end

def spec(file)
  if File.exists?(file)
    run("rspec #{file}")
  else
    puts("Spec: #{file} does not exist.")
  end
end

def feature(file)
  if File.exists?(file)
    run("cucumber #{file}")
  else
    puts("Feature: #{file} does not exist.")
  end
end

watch("spec/.*_spec\.rb") do |match|
  puts(match[0])
  spec(match[0])
end

watch("features/.*\.feature") do |match|
  puts(match[0])
  feature(match[0])
end

