const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

exports.verifyKomojuPayment = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 함수를 호출한 사용자가 로그인했는지, 세션 ID가 있는지 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const sessionId = data.sessionId;
    if (!sessionId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Session ID is required.",
      );
    }
    const secretKey = process.env.KOMOJU_SECRET_KEY;

    try {
      // 2. KOMOJU 서버에 세션 정보를 요청하여 실제 결제 상태 확인
      const response = await axios.get(
        `https://komoju.com/api/v1/sessions/${sessionId}`,
        {
          headers: {
            Authorization: `Basic ${Buffer.from(secretKey + ":").toString("base64")}`,
          },
        },
      );

      const session = response.data;
      const userUidFromKomoju = session.metadata.userUid;

      // 3. 결제가 '완료'되었고, 결제한 사용자와 함수를 호출한 사용자가 동일한지 검증
      if (
        session.status === "completed" &&
        userUidFromKomoju === context.auth.uid
      ) {
        // 4. Firestore 트랜잭션을 사용하여 안전하게 포인트 지급 및 거래 기록 생성
        const userRef = admin
          .firestore()
          .collection("users")
          .doc(userUidFromKomoju);
        const transactionRef = admin
          .firestore()
          .collection("pointTransactions")
          .doc();

        await admin.firestore().runTransaction(async (transaction) => {
          const userDoc = await transaction.get(userRef);
          if (!userDoc.exists) {
            throw "User document not found!";
          }
          const currentPoints = userDoc.data().points || 0;
          const pointsToAdd = parseInt(session.metadata.amount, 10); //metadata에 저장된 금액

          // 포인트 업데이트
          transaction.update(userRef, { points: currentPoints + pointsToAdd });
          // 거래 기록 생성
          transaction.set(transactionRef, {
            userId: userUidFromKomoju,
            amount: pointsToAdd,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            type: "charge",
            sessionId: sessionId,
          });
        });

        return { success: true, message: "Points added successfully." };
      } else {
        // 결제가 완료되지 않았거나 사용자가 일치하지 않는 경우
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Payment not completed or user mismatch.",
        );
      }
    } catch (error) {
      console.error("KOMOJU verification failed:", error);
      throw new functions.https.HttpsError("internal", "Verification failed.");
    }
  });
