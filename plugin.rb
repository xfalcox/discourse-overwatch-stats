# name: discourse-overwatch-stats
# about: Bring Overwatch stats from your Discourse Users
# version: 0.0.1
# authors: Rafael dos Santos Silva <xfalcox@gmail.com>
# url: https://github.com/xfalcox/discourse-overwatch-stats

enabled_site_setting :discourse_overwatch_stats_enabled

DiscoursePluginRegistry.serialized_current_user_fields << "overwatch_level"
DiscoursePluginRegistry.serialized_current_user_fields << "overwatch_most_played_hero"
DiscoursePluginRegistry.serialized_current_user_fields << "overwatch_comprank"

after_initialize do

  load File.expand_path("../app/jobs/scheduled/sync_overwatch_stats.rb", __FILE__)
  load File.expand_path("../lib/overwatch_stats_service.rb", __FILE__)

  User.register_custom_field_type('overwatch_level', :integer)
  User.register_custom_field_type('overwatch_most_played_hero', :string)
  User.register_custom_field_type('overwatch_comprank', :integer)

  if SiteSetting.discourse_overwatch_stats_enabled then
    add_to_serializer(:post, :overwatch_level, false) { object.user.custom_fields['overwatch_level'] }
    add_to_serializer(:post, :overwatch_most_played_hero, false) { object.user.custom_fields['overwatch_most_played_hero'] }
    add_to_serializer(:post, :overwatch_comprank, false) { object.user.custom_fields['overwatch_comprank'] }
  end

end

