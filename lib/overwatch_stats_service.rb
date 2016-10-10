require 'excon'
require 'json'

module OverwatchStatsServices
  class MasterOverwatch

  	API_URL = 'https://owapi.net'

    def self.sync

      tag_field_name = User.find_by_id(1).custom_fields["user_field_#{(UserField.find_by name: 'BattleTag').id}"]

      users = User
              .custom_fields_for_ids(User.first.id..User.last.id, tag_field_name)
              .select{ |u, h| h[tag_field_name] =~ /^[a-z]+#[0-9]+$/i }
              .map{ |u| OpenStruct.new({ id: u[0], tag: u[1][tag_field_name].tr('#', '-') }) }

      conn = Excon.new(API_URL, persistent: true)

      users.each do |user|

        api_response = conn.get(path: "/api/v3/u/#{user.tag}/blob")

        data = JSON.parse(api_response.body, object_class: OpenStruct)

        model = User.find_by_id user.id

    	model.custom_fields['overwatch_level'] = data.us.stats.competitive.overall_stats.level + data.us.stats.competitive.overall_stats.prestige * 100
    	model.custom_fields['overwatch_comprank'] = data.us.stats.competitive.overall_stats.comprank
    	model.custom_fields['overwatch_most_played_hero'] = data.us.heroes.playtime.competitive.to_h.max_by{|k, v| v}.first.to_s

    	model.save!

      end


    end
  end
end


