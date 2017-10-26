Sequel.migration do
  up do
    create_table :link_providers do
      primary_key :id
      String :link_provider_id, :null => false
      String :name, :null => false
      Boolean :shared, :null => false
      foreign_key :deployment_id, :deployments, :null => false, :on_delete => :cascade
      Boolean :consumable, :null => false
      String :content, :null => false
      String :link_provider_definition_type, :null => false
      String :link_provider_definition_name, :null => false # Original name. Only for debugging. If we don't have it. Meh~
      String :owner_object_name, :null => false
      String :owner_object_type, :null => false
      String :owner_object_info
    end

    if [:mysql, :mysql2].include? adapter_scheme
      set_column_type :link_providers, :content, 'longtext'
      set_column_type :links, :content, 'longtext'
    end

    self[:deployments].each do |deployment|
      link_spec_json = JSON.parse(deployment[:link_spec_json] || '{}')
      link_spec_json.each do |instance_group_name, provider_jobs|
        provider_jobs.each do |provider_job_name, link_names|
          link_names.each do |link_name, link_types|
            link_types.each do |link_type, content|
              self[:link_providers] << {
                name: link_name,
                link_provider_id: "#{deployment[:name]}.#{instance_group_name}.#{provider_job_name}.#{link_name}",
                deployment_id: deployment[:id],
                shared: true,
                consumable: true,
                link_provider_definition_type: link_type,
                link_provider_definition_name: link_name,
                owner_object_name: provider_job_name,
                owner_object_type: 'job',
                owner_object_info: {instance_group_name: instance_group_name}.to_json,
                content: content.to_json,
              }
            end
          end
        end
      end
    end

    create_table :link_consumers do
      primary_key :id
      String :link_consumer_id, :null => false
      foreign_key :deployment_id, :deployments, :on_delete => :cascade
      String :owner_object_name, :null => false
      String :owner_object_type, :null => false
      String :owner_object_info
    end

    self[:instances].each do |instance|
      spec_json = JSON.parse(instance[:spec_json] || '{}')
      links = spec_json['links']
      links.each do |job_name, consumed_links|
        consumed_links.each do |link_name, link_data|
          full_id = "#{spec_json['deployment']}.#{spec_json['name']}.#{job_name}.#{link_name}"
          if self[:link_consumers].where(link_consumer_id: full_id).all.count == 0
            self[:link_consumers] << {
              link_consumer_id: full_id,
              deployment_id: instance[:deployment_id],
              owner_object_name: job_name,
              owner_object_type: 'Job',
              owner_object_info: {
                instance_group_name: spec_json['name']
              }.to_json
            }
          end
        end
      end
    end

    #TODO: Migrate instance.spec_json's link spec to consumers and links table.
  end
end