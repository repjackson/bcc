Meteor.publish 'order_count', (
    )->
    @unblock()
    self = @
    match = {model:'order', app:'bcc'}
    Counts.publish this, 'order_count', Docs.find(match)
    return undefined
Meteor.publish 'ingredient_count', (
    )->
    @unblock()
    self = @
    match = {model:'ingredient', app:'bcc'}
    Counts.publish this, 'ingredient_count', Docs.find(match)
    return undefined
Meteor.publish 'product_count', (
    )->
    @unblock()
    self = @
    match = {model:'product', app:'bcc'}
    Counts.publish this, 'product_count', Docs.find(match)
    return undefined
Meteor.publish 'source_count', (
    )->
    @unblock()
    self = @
    match = {model:'source', app:'bcc'}
    Counts.publish this, 'source_count', Docs.find(match)
    return undefined
Meteor.publish 'subscription_count', (
    )->
    @unblock()
    self = @
    match = {model:'product_subscription', app:'bcc'}
    Counts.publish this, 'subscription_count', Docs.find(match)
    return undefined
    
    
Meteor.publish 'giftcard_count', (
    )->
    @unblock()
    self = @
    match = {model:'giftcard', app:'bcc'}
    Counts.publish this, 'giftcard_count', Docs.find(match)
    return undefined
