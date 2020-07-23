require('dotenv').load()
require 'shelljs/global'
_ = require 'underscore'
GitLab = require './gitlab'
GitHub = require './github'

Git = module.exports =
  migrateManyRepos: (options) ->
    { limit } = options

    return GitLab.getAllProjects(limit)
      .then (projects) ->
        promise = Promise.resolve();
        console.log "Start importing #{projects.length} projects"

        for project in projects
          do (project) ->
            promise = promise.then () -> Git.migrateRepo project

  migrateRepo: (options) ->
    { gitlab_name, github_name, gitlab_id, archive_gitlab } = options
    { GITLAB_GIT_URL, GITHUB_ORG } = process.env

    repo = "#{_.last(gitlab_name.split('/'))}.git"
    gitlabRemote = "#{GITLAB_GIT_URL}:#{gitlab_name}.git"
    githubRemote = "git@github.com:#{GITHUB_ORG}/#{github_name}.git"
    console.log "\n\nMigrating #{gitlab_name} (id: #{gitlab_id})"

    rm "-rf", repo
    status = exec "git clone --mirror #{gitlabRemote}"

    if status.code != 0
      console.error status
      throw new Error "Une erreur est survenue #{status.code}"

    cd repo
    status = exec "git remote add github #{githubRemote}"

    if status.code != 0
      console.error status
      throw new Error "Une erreur est survenue #{status.code}"

    return GitHub.createRepo(github_name)
      .then ->
        status = exec "git push github --mirror"
        if status.code != 0
          throw new Error "Une erreur est survenue #{status.code}"
        rm "-rf", repo
        if archive_gitlab and gitlab_id
          return GitLab.archiveProject gitlab_id
      .catch (err) -> console.log err.error
