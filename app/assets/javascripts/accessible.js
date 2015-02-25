// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

function getURLParameter(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null
}
var tokenString = "token="+getURLParameter("token");

var verifyApp = angular.module("VerifyApp", []);

verifyApp.controller("Verify", ['$http', function($http){
	var ver = this;
	ver.verify = function(pw){
		$http.post("/verify", {password: pw}).success(function(resp){
			ver.status = resp.status;
			console.log(resp);
			if(resp.status == 0)
				window.location.href = resp.route;
			else
				ver.error = resp.error
		});
	}


}]);


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
		$http.get("/cdc/api/get-range?start="+start+"&end="+end+"&token="+getURLParameter("token")).success(function(resp){
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
		$http.get("/cdc/api/search?search="+term+"&token="+getURLParameter("token")).success(function(resp){
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
			$http.get("/cdc/api/topic?id="+topic.id+"&token="+getURLParameter("token")).success(function(resp){
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
		return $http.get("/fairfax/publications");
	}
	pubs.getDeadline = function(pub){
		return $http.get("/fairfax/deadlines/publication?pub="+pub);
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
