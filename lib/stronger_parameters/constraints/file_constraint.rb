require 'stronger_parameters/constraints'

module StrongerParameters
  class FileConstraint < Constraint
    VALID_FILE_TYPES = [
      File,
      StringIO,
      Rack::Test::UploadedFile,
      ActionDispatch::Http::UploadedFile
    ]

    def value(v)
      if VALID_FILE_TYPES.any? { |valid_file_type| v.is_a?(valid_file_type) }
        return v
      end

      InvalidValue.new(v, "must be an file object")
    end
  end
end
