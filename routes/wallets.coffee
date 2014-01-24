Wallet = require "../models/wallet"
JsonRenderer = require "../lib/json_renderer"

module.exports = (app)->

  app.post "/wallets", (req, res)->
    currency = req.body.currency
    if req.user
      Wallet.findOrCreateUserWalletByCurrency req.user.id, currency, (err, wallet)->
          console.error err  if err
          return JsonRenderer.error "Could not create wallet.", res  if err
          res.json JsonRenderer.wallet wallet
    else
      JsonRenderer.error "Please auth.", res

  app.get "/wallets", (req, res)->
    if req.user
      Wallet.findUserWallets req.user.id, (err, wallets)->
        console.error err  if err
        res.json JsonRenderer.wallets wallets
    else
      JsonRenderer.error "Please auth.", res
