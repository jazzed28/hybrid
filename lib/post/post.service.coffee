md5 = require 'MD5'

module.exports = angular.module('wordpress-hybrid-client.post').factory '$WPHCPost', ($log, $wpApiPosts, $wpApiComments, $q, $WPHCConfig, CacheFactory) ->
    $log.info '$WPHCPost'

    getCommentsCache = () ->
        if CacheFactory.get 'comments'
            return CacheFactory.get 'comments'
        CacheFactory 'comments', _.get $WPHCConfig, 'post.cache'

    getPostCache = () ->
        if CacheFactory.get 'post'
            return CacheFactory.get 'post'
        CacheFactory 'post', _.get $WPHCConfig, 'post.cache'

    getComments: (id) ->
        deferred = $q.defer()
        hash = md5 $WPHCConfig.api.baseUrl + id
        itemCache = getCommentsCache().get 'item-comments-' + hash
        $log.debug 'Post cache', itemCache
        if itemCache
            deferred.resolve itemCache
        else
            $wpApiComments.getList
                post: id
                status: "approved"
                type: "comment"
            .then (response) ->
                getCommentsCache().put 'item-comments-' + hash, response.data
                deferred.resolve response.data
            .catch (error) ->
                deferred.reject error
        deferred.promise

    get: (id) ->
        deferred = $q.defer()
        hash = md5 $WPHCConfig.api.baseUrl + id
        itemCache = getPostCache().get 'item-' + hash
        $log.debug 'Post cache', itemCache
        if itemCache
            deferred.resolve itemCache
        else
            $wpApiPosts.get id
            .then (response) ->
                getPostCache().put 'item-' + hash, response
                deferred.resolve response
            .catch (error) ->
                deferred.reject error
        deferred.promise
