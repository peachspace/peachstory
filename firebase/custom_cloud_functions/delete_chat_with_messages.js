const functions = require("firebase-functions");
const admin = require("firebase-admin");

// 중복 초기화 방지
if (admin.apps.length === 0) {
  admin.initializeApp();
}

exports.deleteChatWithMessages =
  functions// .region('us-central1')  <-- 이 줄을 지웠습니다! (오른쪽 패널에서 설정하세요)
  .https
    .onCall(async (data, context) => {
      // 1. 로그인 체크
      if (!context.auth) {
        throw new functions.https.HttpsError(
          "unauthenticated",
          "로그인이 필요합니다.",
        );
      }

      const chatDocPath = data.chatDocPath;

      if (!chatDocPath) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "삭제할 채팅방 경로가 없습니다.",
        );
      }

      const db = admin.firestore();
      const chatRef = db.doc(chatDocPath);

      // 2. 권한 확인
      const chatDoc = await chatRef.get();
      if (!chatDoc.exists) {
        return { success: false, message: "이미 삭제된 채팅방입니다." };
      }

      const chatData = chatDoc.data();
      if (chatData.user_ref && chatData.user_ref.id !== context.auth.uid) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "본인의 채팅방만 삭제할 수 있습니다.",
        );
      }

      // 3. 하위 메시지 삭제 (서브컬렉션 이름 확인 필수!)
      // ★★★ Firestore에서 실제 컬렉션 ID가 'story_messages'인지 'storymessages'인지 꼭 확인하세요! ★★★
      const subCollectionName = "storymessages";

      const messagesSnapshot = await chatRef
        .collection(subCollectionName)
        .get();

      const batch = db.batch();

      messagesSnapshot.forEach((doc) => {
        batch.delete(doc.ref);
      });

      batch.delete(chatRef);

      await batch.commit();

      return { success: true, message: "삭제 완료" };
    });
