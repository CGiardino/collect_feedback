# messages model definition
@Messages = new Meteor.Collection('messages')
Messages.allow
	'insert': (userId,doc) -> return true
Messages.allow
	'update': (userId,doc) -> return true
