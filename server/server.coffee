
# first, remove configuration entry in case service is already configured
Accounts.loginServiceConfiguration.remove
  service: "facebook"

Accounts.loginServiceConfiguration.insert
  service: "facebook"
  appId:  "insertHereYourID"
  secret:  "insertHereYourSecret" 

# during new account creation get user picture from facebook and save in user object
Accounts.onCreateUser (options, user) ->
  if (options.profile)
    options.profile.picture = getFbPicture( user.services.facebook.accessToken )

    # We still want the default hook's 'profile' behavior.
    user.profile = options.profile;
  return user

# get user picture from facebook api
getFbPicture = (accessToken) ->
  result = Meteor.http.get "https://graph.facebook.com/me",
    params:
      access_token: accessToken
      fields: 'picture'

  if(result.error)
    throw result.error

  return result.data.picture.data.url