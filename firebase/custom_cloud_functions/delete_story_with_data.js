const functions = require("firebase-functions");
const admin = require("firebase-admin");
// To avoid deployment errors, do not call admin.initializeApp() in your code
if (admin.apps.length === 0) {
  admin.initializeApp();
}

exports.deleteStoryWithData = functions.https.onCall(async (data, context) => {
  // 1. 로그인 인증 확인
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "로그인이 필요한 서비스입니다.",
    );
  }

  const storyPath = data.storyPath; // 예: "stories/STORY_DOC_ID"

  // 2. 파라미터 유효성 검사
  if (!storyPath) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "삭제할 스토리의 경로(storyPath)가 전달되지 않았습니다.",
    );
  }

  const db = admin.firestore();
  const storyRef = db.doc(storyPath);

  try {
    // 3. 스토리 문서 가져오기 (권한 확인용)
    const storyDoc = await storyRef.get();

    if (!storyDoc.exists) {
      return {
        success: false,
        message: "이미 삭제되었거나 존재하지 않는 스토리입니다.",
      };
    }

    const storyData = storyDoc.data();

    // 4. 작성자 본인 확인
    // 'creator_ref' 필드가 작성자 참조라고 가정합니다. (필드명이 다르다면 수정 필요)
    if (
      storyData.creator_ref &&
      storyData.creator_ref.id !== context.auth.uid
    ) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "본인이 작성한 스토리만 삭제할 수 있습니다.",
      );
    }

    // 5. 하위 컬렉션(댓글 등) 삭제 준비
    const batch = db.batch();

    // (중요) 실제 DB의 하위 컬렉션 이름으로 변경하세요. (예: 'story_comments', 'comments' 등)
    const subCollectionName = "comments";
    const subCollectionSnapshot = await storyRef
      .collection(subCollectionName)
      .get();

    // 하위 문서들을 삭제 대기열에 추가
    subCollectionSnapshot.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // 6. 스토리 본체 삭제 대기열에 추가
    batch.delete(storyRef);

    // 7. 일괄 삭제 실행 (Commit)
    await batch.commit();

    return {
      success: true,
      message: "스토리와 관련 데이터가 모두 삭제되었습니다.",
    };
  } catch (error) {
    console.error("스토리 삭제 중 오류 발생:", error);
    throw new functions.https.HttpsError(
      "internal",
      "스토리 삭제 중 오류가 발생했습니다.",
      error,
    );
  }
});
