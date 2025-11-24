const functions = require("firebase-functions");
const admin = require("firebase-admin");
// To avoid deployment errors, do not call admin.initializeApp() in your code
if (admin.apps.length === 0) {
  admin.initializeApp();
}

exports.deleteChatWithMessages = functions
  .region("asia-northeast3") // 프로젝트 리전이 다르면 수정 필요 (예: us-central1)
  .https.onCall(async (data, context) => {
    // 1. 로그인 체크
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다.",
      );
    }

    const chatDocPath = data.chatDocPath; // 예: "storychats/DOCUMENT_ID"

    if (!chatDocPath) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "삭제할 채팅방 경로가 없습니다.",
      );
    }

    const db = admin.firestore();
    const chatRef = db.doc(chatDocPath);

    // 2. 권한 확인 (본인이 만든 채팅방인지)
    const chatDoc = await chatRef.get();
    if (!chatDoc.exists) {
      return { success: false, message: "이미 삭제된 채팅방입니다." };
    }

    // user_ref 필드가 있다면 검증
    const chatData = chatDoc.data();
    if (chatData.user_ref && chatData.user_ref.id !== context.auth.uid) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "본인의 채팅방만 삭제할 수 있습니다.",
      );
    }

    // 3. 하위 메시지 삭제 (Subcollection: story_messages)
    // 주의: 실제 DB의 서브컬렉션 ID가 'story_messages'인지 'storymessages'인지 확인 후 수정하세요.
    // 코드 상에는 StorymessagesRecord 라고 되어 있어 'storymessages'일 가능성이 높습니다.
    const subCollectionName = "storymessages";

    const messagesSnapshot = await chatRef.collection(subCollectionName).get();

    // Batch 작업 시작 (한 번에 여러 개 삭제)
    const batch = db.batch();

    // 하위 메시지들을 삭제 목록에 추가
    messagesSnapshot.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // 채팅방 본체 삭제 추가
    batch.delete(chatRef);

    // 4. 실행 (Commit)
    await batch.commit();

    return {
      success: true,
      message: "채팅방과 대화 내용이 모두 삭제되었습니다.",
    };
  });
