require 'minitest/autorun'

class Sample
end

describe Sample do
  it 'is a class' do
    assert Sample.is_a? Class
  end
end


