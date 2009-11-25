module Selenium
  module WebDriver
    module Firefox
      class Profile

        ANONYMOUS_PROFILE_NAME = "WEBDRIVER_ANONYMOUS_PROFILE"
        EXTENSION_NAME         = "fxdriver@googlecode.com"
        EM_NAMESPACE_URI       = "http://www.mozilla.org/2004/em-rdf#"

        # TODO: hardcoded paths
        DEFAULT_EXTENSION_SOURCE = File.expand_path("#{WebDriver.root}/firefox/src/extension")

        XPTS                     = {
          "#{WebDriver.root}/firefox/prebuilt/nsINativeEvents.xpt"     => "components/nsINativeEvents.xpt",
          "#{WebDriver.root}/firefox/prebuilt/nsICommandProcessor.xpt" => "components/nsICommandProcessor.xpt",
          "#{WebDriver.root}/firefox/prebuilt/nsIResponseHandler.xpt"  => "components/nsIResponseHandler.xpt"
        }

        SHARED = {
          "#{WebDriver.root}/common/src/js/extension/dommessenger.js" => "content/dommessenger.js"
        }

        attr_reader :name, :directory
        attr_accessor :port

        class << self

          def ini
            @ini ||= ProfilesIni.new
          end

          def from_name(name)
            ini[name]
          end

        end

        def initialize(directory = nil)
          if directory
            @directory = directory
          else
            @directory = Dir.mktmpdir("webdriver-profile")
          end

          unless File.directory?(@directory)
            raise Error::WebDriverError, "Profile directory does not exist: #{@directory.inspect}"
          end

          @extension_source = DEFAULT_EXTENSION_SOURCE # make configurable?
        end

        def absolute_path
          if Platform.win?
            directory.gsub("/", "\\")
          else
            directory
          end
        end

        def update_user_prefs
          prefs = existing_user_prefs.merge DEFAULT_PREFERENCES
          prefs['webdriver.firefox_port'] = @port

          write_prefs prefs
        end

        def add_extension(force = false)
          ext_path = File.join(extensions_dir, EXTENSION_NAME)

          if File.exists?(ext_path)
            return unless force
          end

          FileUtils.rm_rf ext_path
          FileUtils.mkdir_p File.dirname(ext_path), :mode => 0700
          FileUtils.cp_r @extension_source, ext_path

          XPTS.each do |source, destination|
            FileUtils.cp source, File.join(ext_path, destination)
          end

          SHARED.each do |source, destination|
            FileUtils.cp source, File.join(ext_path, destination)
          end

          delete_extensions_cache
        end

        def create_copy
          tmp_directory = Dir.mktmpdir("webdriver-rb-profilecopy")
          FileUtils.cp_r @directory, tmp_directory

          Profile.new(tmp_directory)
        end

        def port
          @port ||= Firefox::DEFAULT_PORT
        end

        def extensions_dir
          @extensions_dir ||= File.join(directory, "extensions")
        end

        def user_prefs_path
          @user_prefs_js ||= File.join(directory, "user.js")
        end

        def delete_extensions_cache
          cache = File.join(@directory, "extensions.cache")
          FileUtils.rm_f cache if File.exist?(cache)
        end

        private

        def existing_user_prefs
          return {} unless File.exist?(user_prefs_path)

          prefs = {}

          File.read(user_prefs_path).split("\n").each do |line|
            if line =~ /user_pref\("([^"]+)"\s*,\s*(.+?)\);/
              prefs[$1.strip] = $2.strip
            end
          end

          prefs
        end

        def write_prefs(prefs)
          File.open(user_prefs_path, "w") do |file|
            prefs.each do |key, value|
              file.puts "user_pref(#{key.inspect}, #{value});"
            end
          end
        end

        DEFAULT_PREFERENCES = {
          "app.update.auto"                           => 'false',
          "app.update.enabled"                        => 'false',
          "browser.download.manager.showWhenStarting" => 'false',
          "browser.EULA.override"                     => 'true',
          "browser.EULA.3.accepted"                   => 'true',
          "browser.link.open_external"                => '2',
          "browser.link.open_newwindow"               => '2',
          "browser.safebrowsing.enabled"              => 'false',
          "browser.search.update"                     => 'false',
          "browser.sessionstore.resume_from_crash"    => 'false',
          "browser.shell.checkDefaultBrowser"         => 'false',
          "browser.startup.page"                      => '0',
          "browser.tabs.warnOnClose"                  => 'false',
          "browser.tabs.warnOnOpen"                   => 'false',
          "dom.disable_open_during_load"              => 'false',
          "extensions.update.enabled"                 => 'false',
          "extensions.update.notifyUser"              => 'false',
          "security.warn_entering_secure"             => 'false',
          "security.warn_submit_insecure"             => 'false',
          "security.warn_entering_secure.show_once"   => 'false',
          "security.warn_entering_weak"               => 'false',
          "security.warn_entering_weak.show_once"     => 'false',
          "security.warn_leaving_secure"              => 'false',
          "security.warn_leaving_secure.show_once"    => 'false',
          "security.warn_submit_insecure"             => 'false',
          "security.warn_viewing_mixed"               => 'false',
          "security.warn_viewing_mixed.show_once"     => 'false',
          "signon.rememberSignons"                    => 'false',
          "startup.homepage_welcome_url"              => '"about:blank"',
          "javascript.options.showInConsole"          => 'true',
          "browser.dom.window.dump.enabled"           => 'true'
        }

      end # Profile
    end # Firefox
  end # WebDriver
end # Selenium