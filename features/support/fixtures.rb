require 'fileutils'
require 'pathname'
require 'securerandom'
require File.expand_path(File.join('utilities'), File.dirname(__FILE__))

module Fixtures
  class << self
    include Utilities::ScriptRunner

    def cleanup_on_exit(app)
      heroku_apps << app
    end

    def clean_up_apps
      heroku_apps.each { |app| app.heroku_destroy_app }
    end

    private def heroku_apps
      @heroku_apps ||= []
    end
  end

  class App
    include Utilities::ScriptRunner

    attr_reader :path

    def initialize(path)
      Fixtures.cleanup_on_exit(self)
      @path = path
    end

    def heroku_app?
      !!@heroku_app
    end

    def heroku_app_name
      @heroku_app_name ||= "deckhand-fixture-#{SecureRandom.hex(6)}"
    end

    def heroku_create_app
      raise "Heroku app already created" if heroku_app?

      sh("heroku create #{heroku_app_name} --region eu")
      @heroku_app = true
    end

    def heroku_set_config(config = {})
      set_config_args = config.map { |k, v| "#{k}=#{v}" }.join(' ')
      sh("heroku config:set #{set_config_args} --app #{heroku_app_name}") unless set_config_args.empty?
    end

    def heroku_add_addons(*addons)
      addons.each { |addon| sh("heroku addons:add #{addon} --app #{heroku_app_name}") }
    end

    def heroku_destroy_app
      return unless heroku_app?

      sh("heroku apps:destroy -a #{heroku_app_name} --confirm=#{heroku_app_name}")
    end

    def checkout(ref)
      sh("git checkout #{ref}")
    end

    def sh(command)
      Dir.chdir(path) { super }
    end
  end

  class FixtureManager
    attr_reader :fixtures_dir, :workspace_dir

    def initialize(fixtures_dir:, workspace_dir:)
      @fixtures_dir = Pathname.new(fixtures_dir)
      @workspace_dir = Pathname.new(workspace_dir)

      reset_workspace
    end

    def create(name)
      app_path = workspace_dir.join(name)
      extract(archive: fixtures_dir.join("#{name}.tar.gz"), destination: app_path)

      App.new(app_path)
    end

    def reset_workspace
      force_create(workspace_dir)
    end

  private

    def extract(archive:, destination:)
      force_create(destination)
      Dir.chdir(destination) { `tar -xzf #{archive}` }
    end

    def force_create(path)
      FileUtils.rm_rf(path)
      FileUtils.mkdir_p(path)
    end

  end

  def fixtures
    @fixture_manager ||= FixtureManager.new(
      fixtures_dir: File.expand_path('../../fixtures', __FILE__),
      workspace_dir: File.expand_path('../../../tmp', __FILE__)
    )
  end
end

World(Fixtures)
at_exit { Fixtures.clean_up_apps }
