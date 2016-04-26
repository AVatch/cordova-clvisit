var exec = require('cordova/exec')

var Visit = {
    initialize: function(config, success, failure){
        // initialize CLVisit and request for permissions
        // if necessary     
    },
    startMonitoring: function(config, success, failure){
        // start monitoring for visits
         exec(success, failure, "Visit", "startMonitoring");
    },
    stopMonitoring: function(config, success, failure){
        // stop monitoring for visits
    },
    isMonitoring: function(success, failure){
        // check whether or not the application is monitoring   
    },
    
    
    loadCachedVisits: function( ){
        // NOT IMPLEMENTED    
    },
    removeCachedVisits: function( ){
        // NOT IMPLEMENTED
    }
};

module.exports = Visit;
