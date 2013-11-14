# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :minitest do
  watch(%r{^test/.*_test\.rb})
  watch(%r{^lib/(.*/)?([^/]+)\.rb}) { 'test' }
end
