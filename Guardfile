# A sample Guardfile
# More info at https://github.com/guard/guard#readme

notification :growl

guard 'rspec', notification: true do
  watch(%r{^lib/(.+)\.rb$})  { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/(.+)\.rb$}) { |m| "spec/#{m[1]}.rb" }
end
