// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


var app = angular.module("MaintainersApp", ['ngSanitize']);

app.filter('unsafe', function($sce) { return $sce.trustAsHtml; });

app.directive("maintainer", function($http){
	return {
		restrict: "E",
		templateUrl: "/templates/maintainer.html",
		scope: {
			maintainer: "=",
			onSave: "&"
		}
	}
});

app.filter('parseUrlFilter', function () {
    var urlPattern = /(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/gi;
    return function (text, target, limit) {
    	if(limit == true){
    		if(text.indexOf("<body><!") > -1 && text.length > 200){
    			text = text.substring(0, 220);
    			angular.element(text).append("<span>...</span></body>");
    		}	
    		else if(text.indexOf("<body><!") < 0 && text.length > 30){
    			text = text.substring(0, 30)+"...";
    		}
    	}
    	if(text)
        	return text.replace(urlPattern, '<a target="' + target + '" href="$&">$&</a>');
    };
});

app.factory("maintainers", ['$http', function($http){
	var maintainers = this;

	maintainers.save = function(m){
		return $http.post("/maintainers/"+m.maintainer.id+"/update", m);
	}
	maintainers.all = function(){
		return $http.get("/maintainers/all");
	}
	maintainers.toggleResolved = function(m){
		return $http.post("/maintainers/"+m.id+"/toggle");
	}

	return maintainers;
}]);


app.controller("Maintainer", ['$timeout', 'maintainers', function($timeout, maintainers){
	var main = this;
	main.current = {},
	main.expandCurrent = false,
		main.loading = true;

	main.getAll = function(){
		maintainers.all().success(function(resp){
			console.log(resp);
			main.all = resp.m;
		});
	}

	main.setCurrent = function(m){
		main.current = m;
	}

	main.submitChanges = function(m){
		var data = { maintainer: m };
		maintainers.save(data).success(function(resp){
			console.log(resp);
			main.getAll();
		});
	}
	main.toggleResolved = function(m){
		if(m.resolved)
			m.resolved = false;
		else
			m.resolved = true;
		maintainers.toggleResolved(m).success(function(resp){
			console.log(resp);
		});

	}

	// on page load
	angular.element(document).ready(function () {
        main.getAll();
        $timeout(function(){ main.loading = true; }, 1000);
    });
	
}]);





