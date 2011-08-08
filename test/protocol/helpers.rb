require 'test/unit'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "ohana/protocol"
require 'json'

module RequestTestHelpers
  module ClassMethods
	  def method meth
      define_method :test_method do
        assert_equal meth, @req.method
      end
	  end
	
	  def type type
      define_method :test_type do
        assert_instance_of type, @req
      end
	  end
	
	  def prop name, type, value=nil
      if value
		    define_method :"test_#{name}" do
		      assert_equal value, @req.send(name.to_sym)
		    end
      end
		
      if type
		    define_method :"test_#{name}" do
		      assert_instance_of type, @req.send(name.to_sym)
		    end
      end
	  end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def request= req
    @req = req
  end
end

module ResponseTestHelpers
  module ClassMethods
	  def status stat
      define_method :test_status do
        assert_equal stat, @res.status
      end
	  end
	
	  def type type
      define_method :test_type do
        assert_instance_of type, @res
      end
	  end
	
	  def prop name, type, value=nil
      if value
		    define_method :"test_#{name}" do
		      assert_equal value, @res.send(name.to_sym)
		    end
      end
		
      if type
		    define_method :"test_#{name}" do
		      assert_instance_of type, @res.send(name.to_sym)
		    end
      end
	  end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def response= res
    @res = res
  end
end
