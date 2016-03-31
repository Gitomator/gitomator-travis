require 'gitomator/service/ci/service'
require 'gitomator/util/repo/name_resolver'
require 'travis'

module Gitomator
  module Travis
    class CIProvider



      # ---------------------- Static Factory Methods --------------------------

      class << self
        private :new, :_find_repo
      end

      def self.with_travis_access_token(access_token, opts = {})
        return new(::Travis, access_token, opts)
      end

      def self.with_travis_pro_access_token(access_token, opts = {})
        return new(::Travis::Pro, access_token, opts)
      end

      # ------------------------------------------------------------------------

      def initialize(travis_module, access_token, opts)
        raise "Access_token is nil/empty" if access_token.nil? || access_token.empty?
        @travis = travis_module
        @org = opts[:org]
        @repo_name_resolver = Gitomator::Util::Repo::NameResolver.new(@org)

        @travis.access_token = access_token
      end

      def name
        :travis
      end


      def _find_repo(repo)
        @travis::Repository.find(@repo_name_resolver.full_name(repo))
      end

      def enable_ci(repo, opts={})
        repo = _find_repo(repo)
        unless repo.nil?
          repo.enable()
        end
      end

      def disable_ci(repo, opts={})
        repo = _find_repo(repo)
        unless repo.nil?
          repo.disable()
        end
      end




    end
  end
end
