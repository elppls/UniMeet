import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimeet_test/Models/ClubModel.dart';
import 'package:unimeet_test/Models/ItemModel.dart';
import 'package:unimeet_test/Models/PostModel.dart';
import 'package:uuid/uuid.dart';
import 'package:ntp/ntp.dart';
import '../Models/UserModel.dart';
import '../UniMeetColors/UniMeetConstants.dart';
import 'package:http/http.dart' as http;

class FirebaseServices {
  //Updates the Profile picture of the user
  static void updateProfilePic(UserModel user) {
    usersRef.doc(user.id).update({'profilePicture': user.profilePicture});
  }

  //Updates the First and Last name of the user
  static void updateUserNames(UserModel user) {
    usersRef.doc(user.id).update({
      'firstname': user.firstname,
      'lastname': user.lastname,
      'nameHelper':
          '${user.firstname!.toLowerCase()} ${user.lastname!.toLowerCase()}'
    });
  }

  //Updates the bio of the user
  static void updateBio(UserModel user) {
    usersRef.doc(user.id).update({'bio': user.bio});
  }

  //Updates the Cover picture of the user
  static void updateCoverPic(UserModel user) {
    usersRef.doc(user.id).update({'coverImage': user.coverImage});
  }

//query to search for users, this is used by users to search for other users,
//also by admins to either remove/add admin/member to the club
  static Future<QuerySnapshot> searchUsers(String name, UserModel user) async {
    Future<QuerySnapshot> users = usersRef
        .where('nameHelper', isGreaterThanOrEqualTo: name)
        .where('nameHelper', isLessThanOrEqualTo: name + 'z')
        .where('nameHelper', isNotEqualTo: user.nameHelper)
        .get();
    return users;
  }

//Updates the name of the club
  static void updateClubName(ClubModel club) {
    ClubsRef.doc(club.id).update(
        {'firstname': club.name, 'nameHelper': club.name?.toLowerCase()});
  }

//Updates the bio of the club
  static void updateClubBio(ClubModel club) {
    ClubsRef.doc(club.id).update({'bio': club.bio});
  }

//this function can only used by the university to verify a club; to let users know which clubs are run by the university
//and which are run by  students or faculty
  static void verifyClub(ClubModel club) {
    ClubsRef.doc(club.id).update({'verfied': club.verfied});
  }

//Updates the club's profile picture
  static void updateClubProfilePic(ClubModel club) {
    ClubsRef.doc(club.id).update({'profilePicture': club.profilePicture});
  }

//Updates the club's cover picture
  static void updateClubCoverPic(ClubModel club) {
    ClubsRef.doc(club.id).update({'coverPicture': club.coverPicture});
  }

//sets a field in the user documents, this field called "token" is used by firebase messaging to send a notification to a user
  static void updateToken(String token, String currentUUID) {
    usersRef.doc(currentUUID).update({'token': token});
  }

//a query to search clubs by name
  static Future<QuerySnapshot> searchClubs(String name) async {
    Future<QuerySnapshot> clubs =
        ClubsRef.where('nameHelper', isGreaterThanOrEqualTo: name)
            .where('nameHelper', isLessThanOrEqualTo: name + 'z')
            .get();
    return clubs;
  }

//returns the likes on a club post
  static Future<int> postLikeCountClub(String clubID, PostModel post) async {
    QuerySnapshot likes = await ClubsRef.doc(clubID)
        .collection('posts')
        .doc(post.id)
        .collection('likes')
        .get();
    return likes.docs.length;
  }

//returns number of post requests the are pending to be posted in the club
  static Future<int> getNumOfRequests(String clubID) async {
    QuerySnapshot requestSnapshot =
        await ClubsRef.doc(clubID).collection('requests').get();
    return requestSnapshot.docs.length;
  }

  //returns number of join requests the are pending to be posted in the club
  static Future<int> getNumOfJoinRequests(String clubID) async {
    QuerySnapshot requestSnapshot =
        await ClubsRef.doc(clubID).collection('joinRequests').get();
    return requestSnapshot.docs.length;
  }

//returns true if the user has liked the post
  static Future<bool> likedPostClub(
      String currentUUID, String clubID, PostModel post) async {
    DocumentSnapshot postLikeDoc = await ClubsRef.doc(clubID)
        .collection('posts')
        .doc(post.id)
        .collection('likes')
        .doc(currentUUID)
        .get();
    return postLikeDoc.exists;
  }

//returns how many followers a user has
  static Future<int> followersCount(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('followers').get();
    return followersSnapshot.docs.length;
  }

//returns how many following a user has
  static Future<int> followingCount(String userId) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection('following').get();
    return followingSnapshot.docs.length;
  }

//allows the user to follow another user
  static void follow(String currentUser, String visitedUser) {
    followingRef
        .doc(currentUser)
        .collection('following')
        .doc(visitedUser)
        .set({});

    followersRef
        .doc(visitedUser)
        .collection('followers')
        .doc(currentUser)
        .set({});
  }

//allows the user to unfollow another user
  static void unfollow(String currentUser, String visitedUser) {
    followingRef
        .doc(currentUser)
        .collection('following')
        .doc(visitedUser)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followersRef
        .doc(visitedUser)
        .collection('followers')
        .doc(currentUser)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//retuns how many likes a post has
  static Future<int> postLikeCount(String visitedUser, PostModel post) async {
    QuerySnapshot likes = await postsRef
        .doc(visitedUser)
        .collection('userPosts')
        .doc(post.id)
        .collection('likes')
        .get();
    return likes.docs.length;
  }

//returns true if a user liked the post
  static Future<bool> likedPost(
      String currentUUID, String visitedUUID, PostModel post) async {
    DocumentSnapshot postLikeDoc = await postsRef
        .doc(visitedUUID)
        .collection('userPosts')
        .doc(post.id)
        .collection('likes')
        .doc(currentUUID)
        .get();
    return postLikeDoc.exists;
  }

//allows the user to like a post
  static Future<void> like(
      String visitedUser, String currentUser, PostModel post) async {
    postsRef
        .doc(visitedUser)
        .collection('userPosts')
        .doc(post.id)
        .collection('likes')
        .doc(currentUser)
        .set({});
  }

//allows the user to unlike a post
  static Future<void> unlike(
      String visitedUser, String currentUser, PostModel postID) async {
    postsRef
        .doc(visitedUser)
        .collection('userPosts')
        .doc(postID.id)
        .collection('likes')
        .doc(currentUser)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//uploads a post to the user profile
  static Future<void> uploadPost(PostModel post) async {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.creatorId)
        .collection('userPosts')
        .add({
      'creatorId': post.creatorId,
      'postText': post.postText,
      'fileType': post.fileType,
      'datePosted': await NTP.now(),
    });
  }

//allows the user to like a club post
  static Future<void> likeClubPost(
      String clubID, String currentUser, PostModel post) async {
    ClubsRef.doc(clubID)
        .collection('posts')
        .doc(post.id)
        .collection('likes')
        .doc(currentUser)
        .set({});
  }

//allows the admin to add a club post
  static Future<void> uploadClubPost(PostModel post, String clubID) async {
    ClubsRef.doc(clubID).collection('posts').add({
      'creatorId': post.creatorId,
      'postText': post.postText,
      'fileType': post.fileType,
      'clubId': post.clubId,
      'datePosted': await NTP.now(),
    });
  }

//allows the user to request to add a post to a club
  static Future<void> uploadClubPostRequest(
      PostModel post, String clubID) async {
    ClubsRef.doc(clubID).collection('requests').add({
      'creatorId': post.creatorId,
      'postText': post.postText,
      'fileType': post.fileType,
      'datePosted': await NTP.now(),
    });
  }

//allows a user to create a new club
  static Future<void> createClub(ClubModel club) async {
    ClubsRef.doc(club.id).set({
      'name': club.name,
      'profilePicture': club.profilePicture,
      'uniName': club.uniName,
      'private': club.private,
      'verfied': club.verfied,
      'open': club.open,
      'nameHelper': club.nameHelper,
      'specificYear': club.specificYear,
      'coverPicture': club.coverPicture,
      'uniOnly': club.uniOnly,
      'bio': club.bio
    });
  }

//allows an admin to add another admin to a club
  static Future<void> addAdmin(String adminID, ClubModel club) async {
    ClubsRef.doc(club.id).collection('admins').doc(adminID).set({});
  }

//allows an admin to remove another admin
  static Future<void> removeAdmin(String adminID, ClubModel club) async {
    ClubsRef.doc(club.id).collection('admins').doc(adminID).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//allows an admin to remove a member
  static Future<void> removeMember(String memberId, String club) async {
    ClubsRef.doc(club).collection('members').doc(memberId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//allows an admin to remove a join Request
  static Future<void> removeJoinRequest(String memberId, String club) async {
    ClubsRef.doc(club)
        .collection('joinRequests')
        .doc(memberId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//allows an admin to add a member
  static Future<void> addMember(String memberId, String club) async {
    ClubsRef.doc(club).collection('members').doc(memberId).set({});
  }

//allows a user to unlike a club post
  static Future<void> unlikeClubPost(
      String clubID, String currentUser, PostModel postID) async {
    ClubsRef.doc(clubID)
        .collection('posts')
        .doc(postID.id)
        .collection('likes')
        .doc(currentUser)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//allows a user to delete their own profile
  static Future<void> deleteProfile(String userId) async {
    usersRef.doc(userId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//allows a user to add an iten to the store
  static Future<void> addItem(ItemModel item) async {
    StoreRef.add({
      'image': item.image,
      'name': item.name,
      'price': item.price,
      'sellerId': item.sellerId,
      'sellerName': item.sellerName,
    });
  }

//query that returns all the clubs a user has joined
  static Future<List> getAllJoinedClubs(String CurrentUser) async {
    QuerySnapshot joinedClubsSnapshot =
        await ClubsJoinedRef.doc(CurrentUser).collection('clubs').get();
    List<String> clubsJoined = [];
    for (int i = 0; i < joinedClubsSnapshot.docs.length; i++) {
      clubsJoined.add(joinedClubsSnapshot.docs[i].reference.id);
    }
    return clubsJoined;
  }

//query to get all posts from a followed user's profile
  static Future<List> getAllPosts(String CurrentUser) async {
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(CurrentUser)
        .collection('userPosts')
        .orderBy('datePosted', descending: true)
        .get();
    List<PostModel> posts =
        postsSnapshot.docs.map((doc) => PostModel.fromDoc(doc)).toList();
    return posts;
  }

//query gets the last sent message between two users
  static Future<String> getLastMessage(
      String CurrentUser, String VisitedUser) async {
    QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .doc(CurrentUser)
        .collection('chats')
        .doc(VisitedUser)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(1)
        .get();
    String lastMessage = messageSnapshot.docs[0]["message"];
    return lastMessage;
  }

//query gets last message time
  static Future<Timestamp> getLastMessageTime(
      String CurrentUser, String VisitedUser) async {
    QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .doc(CurrentUser)
        .collection('chats')
        .doc(VisitedUser)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(1)
        .get();
    Timestamp lastMessage = messageSnapshot.docs[0]["time"];
    return lastMessage;
  }

//query returns all users followed by a user
  static Future<List> getAllFollowing(String CurrentUser) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(CurrentUser).collection('following').get();
    List<String> followingList = [];
    for (int i = 0; i < followingSnapshot.docs.length; i++) {
      followingList.add(followingSnapshot.docs[i].reference.id);
    }
    return followingList;
  }

//returns all the data of a user based on their id
  static Future<UserModel> getUser(String CurrentUser) async {
    DocumentSnapshot userSnapshot = await usersRef.doc(CurrentUser).get();
    UserModel user = UserModel.fromDoc(userSnapshot);
    return user;
  }

//get all posts inside a club
  static Future<List> getAllPostsClub(String clubID) async {
    QuerySnapshot postsSnapshot = await ClubsRef.doc(clubID)
        .collection('posts')
        .orderBy('datePosted', descending: true)
        .get();
    List<PostModel> posts =
        postsSnapshot.docs.map((doc) => PostModel.fromDoc(doc)).toList();
    return posts;
  }

//gets all the admins of a club
  static Future<List> getAllAdmins(String clubID) async {
    QuerySnapshot adminsSnapshot =
        await ClubsRef.doc(clubID).collection('admins').get();
    List<String> admins = [];
    for (int i = 0; i < adminsSnapshot.docs.length; i++) {
      admins.add(adminsSnapshot.docs[i].reference.id);
    }
    return admins;
  }

//gets all members of a club
  static Future<List> getAllMembers(String clubID) async {
    QuerySnapshot memberSnapshot =
        await ClubsRef.doc(clubID).collection('members').get();
    List<String> members = [];
    for (int i = 0; i < memberSnapshot.docs.length; i++) {
      members.add(memberSnapshot.docs[i].reference.id);
    }
    return members;
  }

//return all the data of a club based on the club's id
  static Future<ClubModel> getClub(String clubId) async {
    DocumentSnapshot clubSnapshot = await ClubsRef.doc(clubId).get();
    ClubModel club = ClubModel.fromDoc(clubSnapshot);
    return club;
  }

//return all the clubs created by everyone
  static Future<List> getAllClubs() async {
    QuerySnapshot clubSnapshot = await ClubsRef.get();
    List<ClubModel> clubs =
        clubSnapshot.docs.map((doc) => ClubModel.fromDoc(doc)).toList();
    return clubs;
  }

//gets all post requests
  static Future<List> getAllPostRequests(String clubId) async {
    QuerySnapshot requestsSnapshot =
        await ClubsRef.doc(clubId).collection('requests').get();
    List<PostModel> requests =
        requestsSnapshot.docs.map((doc) => PostModel.fromDoc(doc)).toList();
    return requests;
  }
  //gets all join requests

  static Future<List> getAllJoinRequests(String clubId) async {
    QuerySnapshot requestsSnapshot =
        await ClubsRef.doc(clubId).collection('joinRequests').get();
    List<String> requests = [];
    for (int i = 0; i < requestsSnapshot.docs.length; i++) {
      requests.add(requestsSnapshot.docs[i].reference.id);
    }
    return requests;
  }

//allows an admin to approve a post request, then adds the post to the club
  static Future<void> approveRequest(
      String clubID, String currentUser, PostModel post) async {
    DocumentSnapshot approved =
        await ClubsRef.doc(clubID).collection('requests').doc(post.id).get();

    final creatorId = approved.data().toString().contains('creatorId')
        ? approved.get('creatorId')
        : '';
    final datePosted = approved.data().toString().contains('datePosted')
        ? approved.get('datePosted')
        : '';
    final fileType = approved.data().toString().contains('fileType')
        ? approved.get('fileType')
        : '';
    final postText = approved.data().toString().contains('postText')
        ? approved.get('postText')
        : '';

    ClubsRef.doc(clubID).collection('posts').add({
      'creatorId': creatorId,
      'postText': postText,
      'fileType': fileType,
      'datePosted': datePosted,
    });
    approved.reference.delete();
  }

//returns the number of comments in a post
  static Future<int> commentCount(String postId) async {
    QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection('comments')
        .get();
    return commentSnapshot.docs.length;
  }

//allows user to add a comment on a post
  static Future<void> addComment(
      String postId, String commentText, String creatorId) async {
    var random = Uuid();

    FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection('comments')
        .add({
      'commentText': commentText,
      'creatorId': creatorId,
      'datePosted': await NTP.now(),
    });
  }

//allows a user to send a message to another user
  static Future<void> messageSend(
      String currentUser, String visitedUser, String message) async {
    var random = Uuid();

    FirebaseFirestore.instance
        .collection('messages')
        .doc(currentUser)
        .collection('chats')
        .doc(visitedUser)
        .collection('messages')
        .doc(random.v4())
        .set({
      'sender': currentUser,
      'receiver': visitedUser,
      'message': message,
      'time': await NTP.now(),
    });
    FirebaseFirestore.instance
        .collection('messages')
        .doc(currentUser)
        .collection('chats')
        .doc(visitedUser)
        .set({
      'exist': visitedUser,
    });
    FirebaseFirestore.instance
        .collection('messages')
        .doc(visitedUser)
        .collection('chats')
        .doc(currentUser)
        .collection('messages')
        .doc(random.v4())
        .set({
      'sender': currentUser,
      'receiver': visitedUser,
      'message': message,
      'time': await NTP.now(),
    });
    FirebaseFirestore.instance
        .collection('messages')
        .doc(visitedUser)
        .collection('chats')
        .doc(currentUser)
        .set({
      'exist': currentUser,
    });
  }

//returns if a user is joined the club by checking if they are a member or an admin
  static Future<bool> joinedClub(String currentUUID, String clubId) async {
    DocumentSnapshot joinedDoc =
        await ClubsRef.doc(clubId).collection('members').doc(currentUUID).get();
    DocumentSnapshot adminDoc =
        await ClubsRef.doc(clubId).collection('admins').doc(currentUUID).get();
    return joinedDoc.exists || adminDoc.exists;
  }

//returns if a user is joined the club by checking if they are a member or an admin
  static Future<bool> requestedToJoinClub(
      String currentUUID, String clubId) async {
    DocumentSnapshot requestedToJoin = await ClubsRef.doc(clubId)
        .collection('joinRequests')
        .doc(currentUUID)
        .get();
    return requestedToJoin.exists;
  }

//retruns if the club is verfied
  static Future<bool> verfiedClub(String clubId) async {
    DocumentSnapshot joinedDoc = await ClubsRef.doc(clubId).get();
    final creatorId = joinedDoc.data().toString().contains('verfied')
        ? joinedDoc.get('verfied')
        : '';
    return creatorId;
  }

//allows a user to join a club
  static void joinClub(String currentUser, String clubId) {
    ClubsRef.doc(clubId).collection('members').doc(currentUser).set({});
  }

  //allows a user to request to join a club
  static void requestToJoinClub(String currentUser, String clubId) {
    ClubsRef.doc(clubId)
        .collection('joinRequests')
        .doc(currentUser)
        .set({'id': currentUser});
  }

//adds club to the clubs joined by a user
  static Future<void> addClubTojoinedClubsList(
      String CurrentUUID, String clubId) async {
    ClubsJoinedRef.doc(CurrentUUID).collection('clubs').doc(clubId).set({});
  }

//allows the user to leave a club
  static void leaveClub(String currentUser, String clubId) {
    ClubsRef.doc(clubId)
        .collection('members')
        .doc(currentUser)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  //removes a request to join a club
  static void removeRequestToJoinClub(String currentUser, String clubId) {
    ClubsRef.doc(clubId)
        .collection('joinRequests')
        .doc(currentUser)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//removes a club from the clubs joined by a user
  static void removeClubFromJoinedClubList(String currentUser, String clubId) {
    ClubsJoinedRef.doc(currentUser)
        .collection('clubs')
        .doc(clubId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//allows user to delete a comment
  static Future<void> deleteComment(String commentId, String postId) async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//allows a user to delete a store item
  static Future<void> deleteStoreItem(String storeItemId) async {
    await FirebaseFirestore.instance
        .collection('storeItems')
        .doc(storeItemId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//allows a user to delete their post, removes all the likes and comments
  static Future<void> deletePost(String creatorId, String postId) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(creatorId)
        .collection('userPosts')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    var likes = FirebaseFirestore.instance
        .collection('posts')
        .doc(creatorId)
        .collection('likes');
    var likeSnapshots = await likes.get();
    for (var doc in likeSnapshots.docs) {
      await doc.reference.delete();
    }
    var comments = FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection('comments');
    var commentSnapshots = await comments.get();
    for (var doc in commentSnapshots.docs) {
      await doc.reference.delete();
    }
  }

//allows an admin or the creator of the post to delete a club post, removes all likes and comments
  static Future<void> deleteClubPost(
      String creatorId, String postId, String clubId) async {
    await FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubId)
        .collection('posts')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    var likes = FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubId)
        .collection('posts')
        .doc(postId)
        .collection('likes');
    var likeSnapshots = await likes.get();
    for (var doc in likeSnapshots.docs) {
      await doc.reference.delete();
    }
    var comments = FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection('comments');
    var commentSnapshots = await comments.get();
    for (var doc in commentSnapshots.docs) {
      await doc.reference.delete();
    }
  }

//allows an admin to delete a club
  static Future<void> deleteClub(String clubId) async {
    await FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

//sends a notifaction to desired user
  static void sendNotification(String body, String title, String token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAQ9LOx7w:APA91bGJqk211CQREDF2_ZR62bswPFGbVHu8XwSLgGdHkwySQ5EsNS-xsEl1BbHBZ6H0z2XBrVdKNGYdev2FHR6InJdJA3XZzuQLXlAQwpU0dvW9fxYYCOD3pcibv0z_fWW0Hl84-OuY',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {}
  }

//returns true if a user is following another user
  static Future<bool> following(String currentUUID, String visitedUUID) async {
    DocumentSnapshot followingDoc = await followersRef
        .doc(visitedUUID)
        .collection('followers')
        .doc(currentUUID)
        .get();
    return followingDoc.exists;
  }

//returns true if both users are following each other
  static Future<bool> bothFollowing(
      String currentUUID, String visitedUUID) async {
    DocumentSnapshot followerDoc = await followingRef
        .doc(visitedUUID)
        .collection('following')
        .doc(currentUUID)
        .get();
    DocumentSnapshot followingDoc = await followingRef
        .doc(currentUUID)
        .collection('following')
        .doc(visitedUUID)
        .get();
    bool isBothFollow = followingDoc.exists;
    isBothFollow = isBothFollow && followerDoc.exists;
    return isBothFollow;
  }
}
