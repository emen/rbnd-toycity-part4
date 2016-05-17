class Module
  def create_finder_methods(*attributes)
    attributes.each do |attribute|
      class_eval %{
        def self.find_by_#{attribute}(value)
          all.find { |obj| obj.#{attribute} == value }
        end
      }
    end
  end
end
