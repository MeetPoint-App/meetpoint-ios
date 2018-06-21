const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
exports.sendActivitySharingNotification = functions.database.ref('/AllActivities/{activityId}').onCreate(event => { 
	let eventSnapshot = event.data;

	let activityOwnerUid = eventSnapshot.child('uuid').val();
	let isPrivateActivity = eventSnapshot.child('isPrivate').val();

	console.log('Owner of activity: ' + activityOwnerUid + " Is Private Activity: " + isPrivateActivity);

	admin.database().ref('/Users/' + activityOwnerUid).once('value', snapshot => { 
		let activityOwner = snapshot.val();

		if(isPrivateActivity === true) {
			let invitedUsers = eventSnapshot.child('InvitedUsers').val();

			var promises = [];
			var tokens = [];

			let payload = {
	          notification: {
	            title: "Activity Invitation",
	            body: "'" + activityOwner.fullName + "'" + " invited you to an activity. Let's check it out.",
	            badge: '1',
	            sound: 'default'
	          },
	          data: {
	            identifier: event.params.activityId,
	            type: "activity",
	            read: '0',
	            message: " invited you to an activity.",
	            timestamp: String(Date.now() / 1000.0)
	          }
	        }

			for(uid in invitedUsers) {
				console.log('SelectedUser: ' + uid);

				promises.push(admin.database().ref('/Users/' + uid).once('value').then(snapshot => {
	        		var user = snapshot.val();

	              	console.log("Token: " + user.fcmToken + '\n');

	              	if(user.fcmToken) {
	              		tokens.push(user.fcmToken);
	              	}

	            	admin.database().ref('/Notifications/ActivityNotifications/' + user.uuid).push(payload);

	            	return
	        	}))
			}

			return Promise.all(promises).then(results => {
				return admin.messaging().sendToDevice(tokens, payload)
	        	.then(response =>{
	            	console.log("Successfully sent message:", response);
	            	return response;
	         	 })
	          	.catch(error =>{
	            	console.log("Error sending message:", error);
	          	});
			})
		} else {
			return admin.database().ref('/Follower/' + activityOwnerUid).once('value', snapshot => {
				var promises = [];
				var tokens = [];

				let payload = {
		          notification: {
		            title: "New Activity",
		            body: "'" + activityOwner.fullName + "'" + " created an activity. Let's check it out.",
		            badge: '1',
		            sound: 'default'
		          },
		          data: {
		            identifier: event.params.activityId,
		            type: "activity",
		            read: '0',
		            message: " created an activity.",
		            timestamp: String(Date.now() / 1000.0)
		          }
		        }

				snapshot.forEach(childNodes => {
		        	promises.push(admin.database().ref('/Users/' + childNodes.key).once('value').then(snapshot => {
		        		var follower = snapshot.val();

		              	console.log("Follower Token: " + follower.fcmToken + '\n');

		              	if(follower.fcmToken) {
	              			tokens.push(follower.fcmToken);
	              		}

		            	admin.database().ref('/Notifications/ActivityNotifications/' + follower.uuid).push(payload);

		            	return
		        	}))
	      		});

	      		return Promise.all(promises).then(results => {
					return admin.messaging().sendToDevice(tokens, payload)
		        	.then(response =>{
		            	console.log("Successfully sent message:", response);
		            	return response;
		         	 })
		          	.catch(error =>{
		            	console.log("Error sending message:", error);
		          	});
				})
			})
		}
	})
})
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
exports.sendFollowerNotification = functions.database.ref('/Following/{uid}/{followingId}')
  .onCreate(event => {

    let uid = event.params.uid;
    let followingId = event.params.followingId;

    console.log(uid + ' is following to ' + followingId);

    // Get fcmToken to send Push send Push Notification
    return admin.database().ref('/Users/' + followingId).once('value', snapshot => {

      let userWeAreFollowing = snapshot.val();

      return admin.database().ref('/Users/' + uid).once('value', snapshot => {

        let userDoingTheFollowing = snapshot.val();

        let payload = {
          notification: {
            title: "You have a new follower!",
            body: "'" + userDoingTheFollowing.fullName + "'" + ' is now following you.',
            badge: '1',
            sound: 'default'
          },
          data: {
            identifier: uid,
            type: "user",
            recipentId: followingId,
            read: '0',
            message: ' is now following you.',
            timestamp: String(Date.now() / 1000.0)
          }
        }

        admin.database().ref('/Notifications/UserNotifications/' + followingId + '/' + uid).set(payload);
        
        return admin.messaging().sendToDevice(userWeAreFollowing.fcmToken, payload)
        .then(response =>{
        	console.log("Successfully sent message:", response);
            
            return response;
        })
        .catch(error =>{
        	console.log("Error sending message:", error);
        });
      })
    })
  })
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
exports.sendCommentNotification = functions.database.ref('/Comment/{activityId}/{commentId}').onCreate(event => {

	let eventSnapshot = event.data;

	let commentOwnerUid = eventSnapshot.child('uuid').val();
	let activityId = event.params.activityId

	console.log('Owner of comment: ' + commentOwnerUid);

	return admin.database().ref('/AllActivities/' + activityId).once('value', snapshot => {
		let activityDetail = snapshot.val();
		let activityOwner = activityDetail.uuid;

		if(activityOwner === commentOwnerUid) {
			return
		}

		admin.database().ref('/Users/' + activityOwner).once('value', snapshot => {
			let activityOwnerDetail = snapshot.val();
			let activityOwnerFcmToken = activityOwnerDetail.fcmToken;

			return admin.database().ref('/Users/' + commentOwnerUid).once('value', snapshot => {
				let commentOwner = snapshot.val();

				let payload = {
		          notification: {
		            title: "",
		            body: "'" + commentOwner.fullName + "'" + ' commented to your activity: ' + eventSnapshot.child('commentText').val(),
		            badge: '1',
		            sound: 'default'
		          },
		          data: {
		            identifier: activityId,
		            type: "activity",
		            recipentId: activityOwner,
		            read: '0',
		            message: ' commented: ' + eventSnapshot.child('commentText').val(),
		            timestamp: String(Date.now() / 1000.0)
		          }
	        	}

	       		// admin.database().ref('/Notifications/ActivityNotifications/' + followingId + '/' + uid).set(payload);
	        
		        return admin.messaging().sendToDevice(activityOwnerFcmToken, payload)
		        .then(response =>{
		           	console.log("Successfully sent message:", response);
		            
		           	return response;
		        })
		       	.catch(error => {
		           	console.log("Error sending message:", error);
		       	});
		})
		})
	})
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
exports.sentParticipationNotification = functions.database.ref('/Participant/{activityId}/{uid}').onWrite(event => {
	var eventSnapshot = event.data;

	let type = eventSnapshot.child('type').val();
	let uid = event.params.uid;
	let activityId = event.params.activityId;
	var typeMessage = ""

	if(type === 0) {
		typeMessage = " will participate in your activity. "
	} else if(type === 1) {
		typeMessage = " is interested in your activity. "
	} else {
		return
	}

    admin.database().ref('/Users/' + uid).once('value', snapshot => {
		let participant = snapshot.val();

		return admin.database().ref('/AllActivities/' + activityId).once('value', snapshot => {
			var activity = snapshot.val();
			var activityOwnerUid = activity.uuid;


		return admin.database().ref('/Users/' + activityOwnerUid).once('value', snapshot => {
			let user = snapshot.val();

			var payload = {
			notification: {
				title: "Participant",
			    body: "'" + participant.fullName + "'" + typeMessage + "Let's check it out.",
			    badge: '1',
			    sound: 'default'
			    },
			    data: {
			    	identifier: activityId,
			        type: "activity",
			        read: '0',
			        message: typeMessage,
			        recipentId: activityOwnerUid,
			        timestamp: String(Date.now() / 1000.0)
			    }
			}

	        console.log("Token: " + user.fcmToken + '\n');

	        //admin.database().ref('/Notifications/ActivityNotifications/' + user.uuid).push(payload);
	            	
			return admin.messaging().sendToDevice(user.fcmToken, payload)
		    .then(response =>{
		   		console.log("Successfully sent message:", response);
		   		return response;
		   	})
		    .catch(error =>{
	          	console.log("Error sending message:", error);
	      	});
		})
		})
	})
})
