const functions = require("firebase-functions");
const admin = require("firebase-admin");

exports.deleteCommentAndReplies = functions.https.onCall(
  async (data, context) => {
    if (!context.auth)
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    const { commentId, collectionName } = data;

    const db = admin.firestore();
    const batch = db.batch();
    const parentRef = db.collection(collectionName).doc(commentId);

    const doc = await parentRef.get();
    if (!doc.exists || doc.data().user_ref.id !== context.auth.uid) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Not your comment",
      );
    }

    // 대댓글 삭제
    const replies = await db
      .collection(collectionName)
      .where("parent_comment_ref", "==", parentRef)
      .get();
    replies.forEach((d) => batch.delete(d.ref));
    batch.delete(parentRef);

    await batch.commit();
    return { success: true };
  },
);
