const functions = require("firebase-functions");
const axios = require("axios");

exports.createKomojuPayment = functions
  .region("asia-northeast3")
  .runWith({
    memory: "128MB",
    secrets: ["KOMOJU_SECRET_KEY"], // 사용할 Secret 이름을 여기에 등록합니다.
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const userUid = context.auth.uid;
    const amount = data.amount || 1000;

    // 이제 process.env로 안전하게 키를 불러올 수 있습니다.
    const secretKey = process.env.KOMOJU_SECRET_KEY;

    const options = {
      method: "POST",
      url: "https://komoju.com/api/v1/sessions",
      headers: {
        Authorization: `Basic ${Buffer.from(secretKey + ":").toString("base64")}`,
        "Content-Type": "application/json",
      },
      data: {
        amount: amount,
        currency: "KRW",
        return_url: `https://realpeach-4x3pmi.flutterflow.app/paysuccess`,
        cancel_url: `https://realpeach-4x3pmi.flutterflow.app/payfail`,
        metadata: {
          userUid: userUid,
          amount: amount,
        },
      },
    };

    try {
      const response = await axios.request(options);
      return {
        checkoutUrl: response.data.redirect_url,
        sessionId: response.data.id,
      };
    } catch (error) {
      console.error("KOMOJU session creation failed:", error);
      throw new functions.https.HttpsError("internal", "Payment setup failed.");
    }
  });
