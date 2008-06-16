# DefaultRouting
module ActionController

  module Resources

    def map_resource(entities, options = {}, &block)
      resource = Resource.new(entities, options)

      with_options :controller => resource.controller do |map|
        map_collection_actions(map, resource)
        map_default_collection_actions(map, resource)
        map_new_actions(map, resource)
        map_member_actions(map, resource)

        map_associations(resource, options)

        if block_given?
          nested_options = {:path_prefix => resource.nesting_path_prefix, :name_prefix => resource.nesting_name_prefix, :namespace => options[:namespace]}
          nested_options[:default] = options[:show] if options[:show]
          with_options(nested_options, &block)
        end
    
        map_low_priority_actions(map, resource)
      end
    end

    def map_member_actions(map, resource)
      resource.member_methods.each do |method, actions|
        actions.each do |action|
          action_options = action_options_for(action, resource, method)

          action_path = resource.options[:path_names][action] if resource.options[:path_names].is_a?(Hash)
          action_path ||= Base.resources_path_names[action] || action

          map.named_route("#{action}_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}#{resource.action_separator}#{action_path}", action_options)
          map.named_route("formatted_#{action}_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}#{resource.action_separator}#{action_path}.:format",action_options)
        end
      end

      map_member_get(map,resource) unless resource.options[:show]

      update_action_options = action_options_for("update", resource)
      map.connect(resource.member_path, update_action_options)
      map.connect("#{resource.member_path}.:format", update_action_options)

      destroy_action_options = action_options_for("destroy", resource)
      map.connect(resource.member_path, destroy_action_options)
      map.connect("#{resource.member_path}.:format", destroy_action_options)
    end

    def map_low_priority_actions(map, resource)
      map_member_get(map,resource) if resource.options[:show]
    end

    def map_member_get(map, resource)
      show_action_options = action_options_for("show", resource)
      map.named_route("#{resource.name_prefix}#{resource.singular}", resource.member_path, show_action_options)
      map.named_route("formatted_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}.:format", show_action_options)
    end

  end
end