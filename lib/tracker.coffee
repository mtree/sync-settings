# contants
analyticsWriteKey = 'pDV1EgxAbco4gjPXpJzuOeDyYgtkrmmG'

# imports
_ = require 'underscore-plus'
{allowUnsafeEval} = require 'loophole'

# Analytics require a special import because of [Unsafe-Eval error](https://github.com/Glavin001/atom-beautify/commit/fbc58a648d3ccd845548d556f3dd1e046075bf04)
Analytics = null
allowUnsafeEval -> Analytics = require 'analytics-node'

# load package.json to include package info in analytics
pkg = require("../package.json")

class Tracker

  constructor: (@analyticsUserIdConfigKey) ->
    # Setup Analytics
    @analytics = new Analytics analyticsWriteKey

    # set a unique identifier
    if not atom.config.get @analyticsUserIdConfigKey
      uuid = require 'node-uuid'
      atom.config.set @analyticsUserIdConfigKey, uuid.v4()

    # identify the user
    atom.config.observe @analyticsUserIdConfigKey, {}, (userId) =>
      @analytics.identify
        userId: userId

  track: (message) ->
    message = event: message if _.isString(message)
    console.debug "tracking #{message.event}"
    @analytics.track _.deepExtend({
      userId: atom.config.get @analyticsUserIdConfigKey
      properties:
        version: pkg.version
        atomVersion: atom.getVersion()
        value: 1
    }, message)

  trackActivate: ->
    @track
      label: "v#{pkg.version}"
      event: 'Activate'

  trackDeactivate: ->
    @track
      label: "v#{pkg.version}"
      event: 'Deactivate'

module.exports = Tracker
