require 'gitomator/service/ci/service'
require 'gitomator/util/repo/name_resolver'
require 'travis'

module Gitomator
  module Travis
    class CIProvider



      # ---------------------- Static Factory Methods --------------------------

      class << self
        private :new
      end


      #
      # Important: You will need to generate a Travis token (simple to do
      # with Travis' CLI - `travis login` followed by `travis token`)
      #
      # @param access_token [String] - An auth token for Travis
      # @param github_org [String] - The default GitHub organization
      #
      def self.with_travis_access_token(access_token, github_org=nil, opts = {})
        return new(
          ::Travis::Client.new({
            :uri          => ::Travis::Client::ORG_URI,
            :access_token => access_token
          }),
          {org: github_org}
        )
      end


      #
      # Important: You will need to generate a Travis Pro token (simple to do
      # with Travis' CLI - `travis login` followed by `travis token`)
      #
      # @param access_token [String] - An auth token for Travis Pro
      # @param github_org [String] - The default GitHub organization
      #
      def self.with_travis_pro_access_token(access_token, github_org=nil, opts = {})
        return new(
          ::Travis::Client.new({
            :uri          => ::Travis::Client::PRO_URI,
            :access_token => access_token
          }),
          {org: github_org}
        )
      end


      # ------------------------------------------------------------------------


      #
      # @param travis_client [Travis::Client::Session]
      # @param opts [Hash]
      # => @param :org [String] - Default GitHub organization
      #
      def initialize(travis_client, opts)
        raise "Travis client is nil" if travis_client.nil?
        @travis = travis_client
        @org = opts[:org]
        @repo_name_resolver = Gitomator::Util::Repo::NameResolver.new(@org)
      end

      def name
        :travis
      end


      def _find_repo_and_execute_block(repo)
        begin
          yield @travis.repo(@repo_name_resolver.full_name(repo))
        rescue ::Travis::Client::NotFound
          return nil
        end
      end


      def enable_ci(repo, opts={})
        _find_repo_and_execute_block(repo) {|r| r.enable}
      end

      def disable_ci(repo, opts={})
        _find_repo_and_execute_block(repo) {|r| r.disable}
      end

      def ci_enabled?(repo)
        _find_repo_and_execute_block(repo) {|r| r.reload.active? }
      end



      #
      # @param blocking [Boolean]
      #
      def sync(blocking=false, opts={})
        @travis.user.sync()
        while blocking && syncing?
          sleep(1)
        end
      end


      #
      # @return Boolean - Indicates whether a sync' is currently in progress.
      #
      def syncing?(opts={})
        @travis.user.reload.syncing?
      end





    end
  end
end
