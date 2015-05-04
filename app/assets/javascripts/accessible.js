// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

function getURLParameter(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null
}
var tokenString = "token="+getURLParameter("token");

// Begin Maintainer App -----------------------------------------------------

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
	maintainers.all = function(resolved){
		return $http.get("/maintainers/all?resolved="+resolved);
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
	main.resolved = false,
		main.loading = true;

	main.getAll = function(resolved){
		maintainers.all(resolved).success(function(resp){
			main.all = resp.m;
		});
	}

	main.setCurrent = function(m){
		main.current = m;
	}

	main.submitChanges = function(m){
		var data = { maintainer: m };
		maintainers.save(data).success(function(resp){
			main.getAll();
		});
	}
	main.toggleResolved = function(m){
		if(m.resolved)
			m.resolved = false;
		else
			m.resolved = true;
		maintainers.toggleResolved(m).success(function(resp){
		//	console.log(resp);
		});

	}

	// on page load
	angular.element(document).ready(function () {
		main.resolved = getURLParameter('resolved') == 'true' ? true : false;
		if(main.resolved)
			main.getAll(true);
		else
			main.getAll(false);
        $timeout(function(){ main.loading = false; }, 1000);
    });
	
}]);

// End maintainer App -----------------------------------------------------

var app = angular.module("AToZ", ['ngSanitize']);

app.directive('href', function() {
  return {
    compile: function(element) {
      element.attr('target', '_blank');
    }
  };
});

app.controller("AZ", ['$http', '$scope', function($http, $scope){
	var az = this;
	az.welcome = "HELLO";
	az.currentlyEditing = {};
	az.currentTopic = {};	
	az.loading = az.narrowed = false;

	az.getTopics = function(start, end){
		az.loading = true;
		az.narrowed = true;
		$scope.data = null;
		$http.get("/cdc/a-to-z/get-range?start="+start+"&end="+end).success(function(resp){
			console.log(resp);
			az.topics = resp.topics
			az.loading = false;
		}).error(function(err){
			alert("Error!");
			console.log(err);
		});	
	}
	az.search = function(term){
		az.loading = true;
		az.narrowed = true;
		$scope.data = null;
		$http.get("/cdc/a-to-z/search?search="+term).success(function(resp){
			az.topics = resp.topics
			az.loading = false;
		}).error(function(err){
			alert("Error!");
			console.log(err);
		});
	}
	az.edit = function(topic){
		if(az.currentlyEditing == topic){
			az.currentlyEditing = {};
		}
		else{
			az.currentlyEditing = topic;
			$http.get("/cdc/a-to-z/topic?id="+topic.id).success(function(resp){
				console.log(resp);
				if(resp.status == 0){
					az.currentTopic = resp.topic;
				}
			}).error(function(err){
				alert("Error!");
				console.log(err);
			});
		}
		
	}
	az.saveChanges = function(change, topic){
		change.id = topic;
		$http.post("/cdc/change/a-to-z?token="+getURLParameter("token"), { a_to_z_entry: change } ).success(function(resp){
			az.currentlyEditing = {};
			$scope.change = null;
			change = null;
			console.log(resp);
		});
		
	}
	az.isBeingEdited = function(topic){
		if(topic == az.currentlyEditing)
			return true;
		else
			return false;
	}

}]);


var dlApp = angular.module("DeadlinesApp", []);

dlApp.factory("pubs", ['$http', function($http){
	var pubs = {};

	pubs.getAll = function(){
		return $http.get("/fx/publications");
	}
	pubs.getDeadline = function(pub){
		return $http.get("/fx/deadlines/publication?pub="+pub);
	}
	pubs.edit = function(deadline){
		return $http.put("/fx/deadline/save", { deadline: deadline });
	}

	return pubs;
}]);


dlApp.controller("Deadlines", ['$http', '$scope', 'pubs', function($http, $scope, pubs){
	var dl = this;
	dl.pubs = [];
	dl.beingEdited = {};

	dl.getPubs = function(){
		pubs.getAll().success(function(resp){
			console.log(resp);
			dl.pubs = resp.pubs;
		});
	}
	dl.getDeadlines = function(pub){
		dl.dlSelected = pub;
		pubs.getDeadline(pub).success(function(resp){
			console.log(resp);
			dl.allDeadlines = resp.deadlines;
			dl.filter = null;
		});
	}
	dl.clearDeadlines = function(){
		dl.allDeadlines = [];
		dl.edit = null;
	}
	dl.editDeadline = function(d){
		if(d == dl.beingEdited){
			dl.beingEdited = {};
			dl.edit = null;
		}
		else
			dl.beingEdited = d;
	}
	dl.save = function(d, edit){
		edit.id = d.id;
		pubs.edit(edit).success(function(resp){
			if(resp.status == 0)
				dl.getDeadlines(d.publication);
		});
	}

	dl.isBeingEdited = function(d){
		if(d == dl.beingEdited)
			return true;
		else
			return false;
	}

	// on page load
	dl.getPubs();

}]);



var app = angular.module("ArticleRequest", ["ngSanitize", "ngS3upload"]);

app.directive("loader", function(){
	return {
		restrict: "E",
		scope: {
			loading: "=", // boolean that determines whether to show spinner
			size: "@"
		},
		template: '<i ng-show="loading" class="fa fa-circle-o-notch fa-spin"></i>',
		link: function(scope, el, attrs){
			console.log("Loading", scope.loading);
			el.css("font-size", scope.size);
		}
	}
});

app.filter('capitalize', function() {
	return function(input, all) {
		return (!!input) ? input.replace(/([^\W_]+[^\s-]*) */g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();}) : '';
	}
});

app.config(function(ngS3Config) {
  ngS3Config.theme = 'bootstrap3';
});

app.factory("maintainers", ['$http', function($http){
	var m = this;

	m.newAdminAR = function(ar){
		ar.admin = true;
		return $http.post("/admin/article-request/new", ar);	
	}

	return m;
}]);

app.controller("AR", ["$http", "maintainers", function($http, maintainers){
	var ar = this;
	ar.requestingUser = {},
	ar.attCount = 1,
	ar.hasClient = true,
	ar.allClients = false,
	ar.sending = false,
	ar.currentClient = "";

	ar.createAdminAR = function(doc){
		ar.sending = true;
		maintainers.newAdminAR(doc).success(function(resp){
			console.log(resp);
			if(resp.status == 0){
				ar.onSuccess = resp.message;
			}
			ar.sending = false;
		}); 
	}
	ar.getUser = function(){
		$http.get(util.rails_env.current+"/users/"+window.parent._jive_current_user.ID).success(function(resp){
			ar.requestingUser = resp.user;
			if(!resp.user.client)
				ar.hasClient = false;
			else if(resp.user.client == "all")
				ar.allClients = true;
			else
				ar.currentClient = ar.requestingUser.client
		});
	}
	ar.setClient = function(client){
		ar.currentClient = client;
	}
	ar.incAtt = function(){
		ar.attCount++;
	}
	ar.numAttachments = function(first){
		if(!first && ar.attCount == 1)
			return 0;
		else if(first)
			return 1;
		else
			return ar.attCount;
	}
	ar.priWords = function(pri){
		switch(pri){
			case "1":
				return "High"
			break;
			case "2":
				return "Medium"
			break;
			case "3":
				return "Low"
			break;
		}
	}

}]);

var sub_app = angular.module("SuburbsApp", []);

sub_app.factory("suburbs", ['$http', function($http){
	var subs = this

	subs.getByLength = function(length){
		return $http.get("/fx/suburbs/condition?condition=length&length="+length)
	}

	return subs;
}]);

sub_app.controller("Subs", ['suburbs', function(suburbs){
	var subs = this;
	subs.current = {},
		subs.currentPub = {};

	subs.getByCondition = function(condition, alt){
		switch(condition){
			case 'length': 
				suburbs.getByLength(alt.toString()).success(function(resp){
					subs.matches = resp.matches;
				});
			break;
		}
	}
	subs.beingEdited = function(sub,pub){
		if(sub == subs.current && subs.currentPub == pub)
			return true;
		else
			return false;
	}
	subs.edit = function(sub, pub){
		subs.current = sub;
		subs.currentPub = pub;
	}
	subs.saveEdit = function(sub, pub){
		suburbs.save(sub,pub).success(function(resp){
			console.log(resp);
		});
	}
	// on page load
	subs.getByCondition('length', 20);

}]);






