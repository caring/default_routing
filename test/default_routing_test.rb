require 'test/unit'
require 'rubygems'
require 'action_controller'
require File.dirname(__FILE__) + "/../init"

class ChildrenController < Class.new(ActionController::Base)
  def show
  end
end

class ParentsController < Class.new(ActionController::Base)
  def index
  end
  def show
  end
end

class MockRequest < Struct.new(:path, :subdomains, :method, :remote_ip, :protocol, :path_parameters, :domain, :port, :content_type, :accepts, :request_uri)
end

class RequestRoutingTest < Test::Unit::TestCase
  attr_reader :rs
  def setup
    @rs = ::ActionController::Routing::RouteSet.new
    ActionController::Routing.use_controllers! %w(test) if ActionController::Routing.respond_to? :use_controllers!
    @rs.draw do |map|
      map.resources :parents do |parents|
        parents.resources :children, :default => true
      end
    end
    @request = MockRequest.new(
      '',
      ['www'],
      :get,
      '1.2.3.4',
      'http://',
      '',
      'thing.com',
      3432,
      'text/html',
      ['*/*'],
      '/'
    )
  end
  
  def test_normal_routes
    @request.path = '/parents/parent-id'
    assert(@rs.recognize(@request))
  end
  
  # this would pass if I could get the environment set up correctly.
  def test_child_id
    @request.path = '/parents/parent-id/child-id'
    assert(@rs.recognize(@request))
  end

  # this would pass if I could get the environment set up correctly.
  def test_generation
    assert_equal '/parents/parent-id/child-id', @rs.generate(:controller => 'children', :action => 'show', :parent_id => 'parent-id', :id => 'child-id')
  end
  
end
