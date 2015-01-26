// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/


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
		$http.get("/cdc/api/get-topics?start="+start+"&end="+end).success(function(resp){
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
			$http.get("/cdc/api/topic?id="+topic.id).success(function(resp){
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
		$http.post("/cdc/change/a-to-z", { a_to_z_entry: change } ).success(function(resp){
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

	// on page load
//	az.getTopics();

}]);


/*	acc.verify = function(pw){
		$http.post("/cdc/verify", {password: pw}).success(function(resp){
			acc.status = resp.status;
			if(resp.status === 0)
				acc.token = resp.token;
			else
				acc.error = resp.error
		});
	}
*/