const functions = require('firebase-functions');
const admin = require('firebase-admin');
// To avoid deployment errors, do not call admin.initializeApp() in your code

exports.deleteCommentAndReplies = functions.region('us-central1').
	runWith({
		memory: '128MB'
  }).https.onCall(
  (data, context) => {
		const commentId = data.commentId;
    // Write your code below!
const db = admin.firestore();

exports.deleteCommentAndReplies = functions.https.onCall(async (data, context) => {
  const commentId = data.commentId;

  if (!commentId) {
    throw new functions.https.HttpsError("invalid-argument", "commentId is required.");
  }
  
  // Firestore의 일괄 처리(batch)를 시작합니다.
  const batch = db.batch();

  // 1. 삭제할 부모 댓글의 참조를 가져옵니다.
  const parentCommentRef = db.collection("comments").doc(commentId);
  
  // 2. 부모 댓글에 달린 모든 답글들을 쿼리합니다.
  const repliesSnapshot = await db.collection("comments").where("parent_comment_ref", "==", parentCommentRef).get();

  // 3. 쿼리한 모든 답글들을 삭제 목록에 추가합니다.
  repliesSnapshot.forEach(doc => {
    batch.delete(doc.ref);
  });

  // 4. 부모 댓글 자체도 삭제 목록에 추가합니다.
  batch.delete(parentCommentRef);

  // 5. 모든 삭제 작업을 한 번에 실행합니다.
  await batch.commit();

  return { status: "success", message: "Comment and all replies deleted." };
    // Write your code above!
  }
);