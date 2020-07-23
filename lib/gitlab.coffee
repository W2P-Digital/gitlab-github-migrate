require('dotenv').load()
fetch = require 'node-fetch'
request = require 'request-promise'
coffee = require 'coffee-script'
requestJSON = request.defaults(json: true)

GitLab = module.exports =
  apiCall: (method, path, params = {}) ->
    { GITLAB_URL, GITLAB_TOKEN } = process.env
    url = new URL("#{GITLAB_URL}/api/v4/#{path}")

    options = {
      method: method,
      headers: {
        'private-token': '-LXDctXSa1HAXVm54g73',
      }
    }

    if method == 'get'
      url.search = new URLSearchParams(params).toString()
    else
      options.body = JSON.stringify(params)

    fetch(url, options)
      .then (response) ->
        return response.json()

  get: (path, params = {}) ->
    return GitLab.apiCall 'get', path, params

  post: (path, params = {}) ->
    return GitLab.apiCall 'post', path, params

  archiveProject: (projectId) ->
    return GitLab.post "projects/#{projectId}/archive"
      .then (res) ->
        console.log "Project #{projectId} is archived on GitLab"

  getIssues: (projectId) ->
    GitLab.get "projects/#{projectId}/issues"

  getComments: (projectId, issueId) ->
    GitLab.get "projects/#{projectId}/issues/#{issueId}/notes"

  getMilestones: (projectId) ->
    GitLab.get "projects/#{projectId}/milestones"

  getDataToMigrateProject: (project) ->
    newRepoName = GitLab.camelize project.namespace.path

    return {
      gitlab_id: project.id,
      gitlab_name: project.path_with_namespace,
      github_name: "#{newRepoName}-#{project.path}",
      isArchived: project.archived,
    }

  camelize: (str) ->
    arr = str.split('-');
    capital = arr.map((item, index) => item.charAt(0).toUpperCase() + item.slice(1))
    capitalString = capital.join("")

    return capitalString

  getAllProjects: (limit = 2) ->
    GitLab.get('projects', {
      simple: false,
      archived: false,
      order_by: 'id',
      sort: 'asc',
      per_page: limit,
    })
      .then (projects) ->
        return projects.map (project) => GitLab.getDataToMigrateProject project
