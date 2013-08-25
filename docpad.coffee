# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig = {

  # =================================
  # Template Data
  # These are variables that will be accessible via our templates
  # To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

  templateData:

    # Specify some site properties
    site:
      # The production url of our website
      url: "www.firfi.com"

      # Here are some old site urls that you would like to redirect from
      oldUrls: [
        'firfi.herokuapp.com'
        'firfi.com'
        'http://firfi.com'
      ]

      # The default title of our website
      title: "Firfi Inc."

      # The website description (for SEO)
      description: """
        Firfi personal page. Fullstack web development, ponies, unicorns, pegasi.
        """

      # The website keywords (for SEO) separated by commas
      keywords: """
        """

      # The website author's name
      author: "Igor Loskutoff"

      # The website author's email
      email: "igor.loskutoff@gmail.com"

      # Styles
      styles: [
        "/built.min.css"
        "/vendor/font-awesome/css/font-awesome.css" # don't minify awesome
      ]

      # Scripts
      scripts: [
        "//cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min.js"
        "//cdnjs.cloudflare.com/ajax/libs/modernizr/2.6.2/modernizr.min.js"
        "/built.min.js"
      ]

      services:
        googleAnalytics: 'UA-43477700-1'



  # -----------------------------
    # Helper Functions

    # Get the prepared site/document title
    # Often we would like to specify particular formatting to our page's title
    # we can apply that formatting here
    getPreparedTitle: ->
      # if we have a document title, then we should use that and suffix the site's title onto it
      if @document.title
        "#{@document.title} | #{@site.title}"
      # if our document does not have it's own title, then we should just use the site's title
      else
        @site.title

    # Get the prepared site/document description
    getPreparedDescription: ->
      # if we have a document description, then we should use that, otherwise use the site's description
      @document.description or @site.description

    # Get the prepared site/document keywords
    getPreparedKeywords: ->
      # Merge the document keywords with the site keywords
      @site.keywords.concat(@document.keywords or []).join(', ')


  # =================================
  # Collections
  # These are special collections that our website makes available to us

  collections:
    pages: (database) ->
      database.findAllLive({pageOrder: $exists: true}, [pageOrder:1,title:1])

    posts: (database) ->
      database.findAllLive({tags:$has:'post'}, [date:-1])


  # =================================
  # Plugins

  plugins:
    thumbnails:
      presets:
        'default':
          w: 300
          h: 300
          q: 90
      imageMagick: true
    downloader:
      downloads: [

      ]
    sitemap:
      cachetime: 600000
      changefreq: 'monthly'
      priority: 0.5
      sitemap: false



  # =================================
  # DocPad Events

  # Here we can define handlers for events that DocPad fires
  # You can find a full listing of events on the DocPad Wiki
  events:

    # Server Extend
    # Used to add our own custom routes to the server before the docpad routes are added
    serverExtend: (opts) ->
      # Extract the server from the options
      {server} = opts
      docpad = @docpad

      # As we are now running in an event,
      # ensure we are using the latest copy of the docpad configuraiton
      # and fetch our urls from it
      latestConfig = docpad.getConfig()
      oldUrls = latestConfig.templateData.site.oldUrls or []
      newUrl = latestConfig.templateData.site.url

      # Redirect any requests accessing one of our sites oldUrls to the new site url
      server.use (req,res,next) ->
        if req.headers.host in oldUrls
          res.redirect(newUrl+req.url, 301)
        else
          next()

    writeAfter: (opts,next) ->
      # Prepare
      safeps = require('safeps')
      pathUtil = require('path')
      docpad = @docpad
      rootPath = docpad.config.rootPath
      gruntPath = pathUtil.join(rootPath, 'node_modules', '.bin', 'grunt')

      # Perform the grunt `min` task
      # https://github.com/gruntjs/grunt/blob/0.3-stable/docs/task_min.md
      command = [gruntPath, 'uglify']

      # Execute
      safeps.spawn(command, {cwd:rootPath,output:true}, next)

      command = [gruntPath, 'cssmin']
      safeps.spawn(command, {cwd:rootPath,output:true}, next)

      # Chain
      @

  watchOptions: preferredMethods: ['watchFile','watch']
}


# Export our DocPad Configuration
module.exports = docpadConfig

