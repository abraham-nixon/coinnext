User = require '../models/user'
JsonRenderer = require '../lib/json_renderer'
_ = require "underscore"

module.exports = (app)->
  
  app.post "/user", (req, res)->
    user = new User
      email: req.body.email
      password:  User.hashPassword req.body.password
    user.save (err)->
      return renderError err, res  if err
      res.json JsonRenderer.user user

  app.post "/login", (req, res, next)->
    login req, res, next

  app.put "/login", (req, res, next)->
    login req, res, next

  app.get "/user/:id?", (req, res)->
    return renderError null, res  if not req.user
    res.json JsonRenderer.user req.user

  app.get "/logout", (req, res)->
    req.logout()
    if req.accepts "html"
      res.redirect "/"
    else
      res.json({})

  app.get "/generate_gauth", (req, res)->
    return renderError null, res  if not req.user
    req.user.generateGAuthData ()->
      res.json JsonRenderer.user req.user

  login = (req, res, next)->
    passport.authenticate("local", (err, user, info)->
      return renderError err, res, 401  if err
      return renderError "Invalid credentials", res, 401  if not user
      req.logIn user, (err)->
        return renderError "Invalid credentials", res, 401  if err
        if user.gauth_data and not user.isValidGAuthPass req.body.gauth_pass
          req.logout()
          return renderError "Invalid Google Authenticator code", res, 401
        res.json JsonRenderer.user req.user
    )(req, res, next)

  renderError = (err, res, code = 409)->
    res.statusCode = code
    message = ""
    if _.isString err
      message = err
    else if _.isObject(err) and err.name is "ValidationError"
      for key, val of err.errors
        if val.path is "email" and val.message is "unique"
          message += "E-mail is already taken. "
        else
          message += "#{val.message} "
    res.json {error: message}
