if Meteor.isClient
    Router.route '/cars', (->
        @layout 'layout'
        @render 'cars'
        ), name:'cars'
    Router.route '/car/:doc_id/edit', (->
        @layout 'layout'
        @render 'car_edit'
        ), name:'car_edit'
    Router.route '/car/:doc_id', (->
        @layout 'layout'
        @render 'car_view'
        ), name:'car_view'
    Router.route '/car/:doc_id/view', (->
        @layout 'layout'
        @render 'car_view'
        ), name:'car_view_long'
    
    Template.registerHelper 'claimer', () ->
        Meteor.users.findOne @claimed_user_id
    Template.registerHelper 'completer', () ->
        Meteor.users.findOne @completed_by_user_id
    
    Template.car_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.car_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->


    Template.car_view.events
        'click .add_car_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    car_ids:[@_id]
            Router.go "/recipe/#{new_id}/edit"

    
    
    Template.car_edit.events
        'click .delete_car': ->
            Swal.fire({
                title: "delete car?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'car removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/car"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish car?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_car', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'car published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish car?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_car', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'car unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
            
if Meteor.isClient
    Template.cars.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'car_sort_key', 'datetime_available'
        Session.setDefault 'car_sort_label', 'available'
        Session.setDefault 'car_limit', 42
        Session.setDefault 'view_open', true

        @autorun => @subscribe 'car_facets',
            picked_tags.array()
            picked_sections.array()
            Session.get('view_vegan')
            Session.get('view_gf')
            
            Session.get('car_query')
            Session.get('car_limit')
            Session.get('car_sort_key')
            Session.get('car_sort_direction')

        @autorun => @subscribe 'car_results',
            picked_tags.array()
            picked_sections.array()
        @autorun => @subscribe 'car_count',
            picked_tags.array()
            picked_sections.array()
            Session.get('car_query')
            Session.get('view_vegan')
            Session.get('view_gf')
            
            Session.get('car_limit')
            Session.get('car_sort_key')
            Session.get('car_sort_direction')
            


    Template.cars.events
        'click .add_car': ->
            new_id =
                Docs.insert
                    model:'car'
            Router.go("/car/#{new_id}/edit")


        'click .toggle_vegan': -> Session.set('view_vegan', !Session.get('view_vegan'))
        'click .toggle_gf': -> Session.set('view_gf', !Session.get('view_gf'))
        'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'keyup #car_search': _.throttle((e,t)->
            query = $('#car_search').val()
            Session.set('car_query', query)
            # console.log Session.get('car_query')
            if e.key == "Escape"
                Session.set('car_query', null)
                
            if e.which is 13
                search = $('#car_search').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#car_search').val('')
                    Session.set('car_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_car_count': ->
            Meteor.call 'calc_car_count', ->

        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = picked_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             picked_tags.pop()
        #             Meteor.call 'search_reddit', picked_tags.array(), ->
        # , 1000)

        'click .reconnect': ->
            Meteor.reconnect()


        'click .set_sort_direction': ->
            if Session.get('car_sort_direction') is -1
                Session.set('car_sort_direction', 1)
            else
                Session.set('car_sort_direction', -1)


    Template.cars.helpers
        quickbuying_car: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('car_sort_direction')) is 1

        toggle_gf_class: -> if Session.get('view_gf') then 'blue' else ''
        toggle_vegan_class: -> if Session.get('view_vegan') then 'blue' else ''
        toggle_open_class: -> if Session.get('view_open') then 'blue' else ''
        connection: ->
            console.log Meteor.status()
            Meteor.status()
        connected: ->
            Meteor.status().connected
        invert_class: ->
            if Meteor.user()
                if Meteor.user().dark_mode
                    'invert'
                    
        car_count: -> Counts.get('car_counter')
     
        tags: ->
            # if Session.get('car_query') and Session.get('car_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            car_count = Docs.find().count()
            # console.log 'car count', car_count
            if car_count < 3
                Results.find({model:'tag', count: $lt: car_count})
            else
                Results.find({model:'tag'})

        ingredients: ->
            # if Session.get('car_query') and Session.get('car_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            car_count = Docs.find(model:'car').count()
            # console.log 'car count', car_count
            if car_count < 3
                Results.find({model:'ingredient', count: $lt: car_count})
            else
                Results.find({model:'ingredient'})

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_tags: -> picked_tags.array()
        picked_sections: -> picked_sections.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        car_query: -> Session.get('car_query')

        one_car: ->
            Docs.find(model:'car').count() is 1
        two_cars: ->
            Docs.find(model:'car').count() is 2
        three_cars: ->
            Docs.find(model:'car').count() is 3
        car_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'car'
            },
                sort: "#{Session.get('car_sort_key')}":parseInt(Session.get('car_sort_direction'))
                limit:Session.get('car_limit')

        subs_ready: ->
            Template.instance().subscriptionsReady()
        users: ->
            # if picked_tags.array().length > 0
            Meteor.users.find {
            },
                sort: count:-1
                # limit:1


        sections: ->
            # if picked_tags.array().length > 0
            Results.find {
                model:'section'
            },
                sort: count:-1
                # limit:1

        car_limit: -> Session.get('car_limit')

        current_car_sort_label: -> Session.get('car_sort_label')





if Meteor.isServer
    Meteor.publish 'car_results', (
        )->
        # console.log picked_tags
        # if doc_limit
        #     limit = doc_limit
        # else
        limit = 42
        # if doc_sort_key
        #     sort_key = doc_sort_key
        # if doc_sort_direction
        #     sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'car', app:'bcc'}
        # if picked_tags.length > 0
        #     match.ingredients = $all: picked_tags
        #     # sort = 'price_per_serving'
        # if picked_sections.length > 0
        #     match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
        # match.published = true
            # match.source = $ne:'wikipedia'
        # if view_vegan
        #     match.vegan = true
        # if view_gf
        #     match.gluten_free = true
        # if car_query and car_query.length > 1
        #     console.log 'searching car_query', car_query
        #     match.title = {$regex:"#{car_query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}

        # match.tags = $all: picked_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        # console.log 'car match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: 42
            
            
    Meteor.publish 'car_count', (
        picked_tags
        picked_sections
        car_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_tags
        self = @
        match = {model:'car', app:'bcc'}
        if picked_tags.length > 0
            match.ingredients = $all: picked_tags
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if car_query and car_query.length > 1
            console.log 'searching car_query', car_query
            match.title = {$regex:"#{car_query}", $options: 'i'}
        Counts.publish this, 'car_counter', Docs.find(match)
        return undefined

    Meteor.publish 'car_facets', (
        picked_tags
        picked_sections
        car_query
        view_vegan
        view_gf
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        console.log 'picked ingredients', picked_tags

        self = @
        match = {app:'bcc'}
        match.model = 'car'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if picked_tags.length > 0 then match.ingredients = $all: picked_tags
        if picked_sections.length > 0 then match.menu_section = $all: picked_sections
            # match.$regex:"#{car_query}", $options: 'i'}
        if car_query and car_query.length > 1
            console.log 'searching car_query', car_query
            match.title = {$regex:"#{car_query}", $options: 'i'}
            # match.tags_string = {$regex:"#{query}", $options: 'i'}
        #
        #     Terms.find {
        #         title: {$regex:"#{query}", $options: 'i'}
        #     },
        #         sort:
        #             count: -1
        #         limit: 42
            # tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: "tags": 1 }
            #     { $unwind: "$tags" }
            #     { $group: _id: "$tags", count: $sum: 1 }
            #     { $match: _id: $nin: picked_tags }
            #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 42 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]

        # else
        # unless query and query.length > 2
        # if picked_tags.length > 0 then match.tags = $all: picked_tags
        # # match.tags = $all: picked_tags
        # # console.log 'match for tags', match
        section_cloud = Docs.aggregate [
            { $match: match }
            { $project: "menu_section": 1 }
            { $group: _id: "$menu_section", count: $sum: 1 }
            { $match: _id: $nin: picked_sections }
            # { $match: _id: {$regex:"#{car_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
        
        section_cloud.forEach (section, i) =>
            # console.log 'queried section ', section
            # console.log 'key', key
            self.added 'results', Random.id(),
                title: section.name
                count: section.count
                model:'section'
                # category:key
                # index: i


        ingredient_cloud = Docs.aggregate [
            { $match: match }
            { $project: "ingredients": 1 }
            { $unwind: "$ingredients" }
            { $match: _id: $nin: picked_tags }
            { $group: _id: "$ingredients", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        ingredient_cloud.forEach (ingredient, i) =>
            # console.log 'ingredient result ', ingredient
            self.added 'results', Random.id(),
                title: ingredient.title
                count: ingredient.count
                model:'ingredient'
                # category:key
                # index: i


        self.ready()


