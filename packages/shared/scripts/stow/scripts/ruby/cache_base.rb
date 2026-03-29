class CachedHash
  attr_accessor :file_path, :value

  def new(file_path, fallback: {})
    self.file_path = file_path

  end
end
