Git = require './lib/git'
GitLab = require './lib/gitlab'
GitHub = require './lib/github'

option '-i', '--gitlab_id [ID]', 'GitLab project id'
option '-l', '--gitlab_name [NAME]', 'GitLab repo name'
option '-n', '--limit [NAME]', 'Number of GitLab projects to import (max is 100)'
option '-h', '--github_name [NAME]', 'GitHub repo name'
option '-a', '--archive_gitlab', 'Must archive the GitLab repository (default false)'

task 'list:gitlab:repos', 'list existing projects', () ->
  GitLab.getAllProjects()
    .then (projects) ->
      console.log projects

task 'migrate:manyRepos', 'list existing projects', (options) ->
  Git.migrateManyRepos(options)

task 'migrate:repo', 'migrate repository', (options) ->
  Git.migrateRepo(options)
