require 'default_routing'
ActionController::Resources::Resource.send(:include, DefaultRouting::DefaultResource)
