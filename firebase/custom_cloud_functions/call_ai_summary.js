const functions = require("firebase-functions");
const axios = require("axios");

exports.callAiSummary = functions
  .runWith({
    secrets: ["GROQ_API_KEY"], // Groq 키 필수
    memory: "256MB",
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    const summaryPrompt = data.summaryPrompt || "Summarize this.";

    // Groq API 호출 설정
    const uri = "https://api.groq.com/openai/v1/chat/completions";
    const headers = { Authorization: `Bearer ${process.env.GROQ_API_KEY}` };
    const body = {
      model: "meta-llama/llama-4-scout-17b-16e-instruct", // 혹은 gemma2 등 원하는 모델
      messages: [{ role: "user", content: summaryPrompt }],
      max_completion_tokens: 4096,
    };

    try {
      const response = await axios.post(uri, body, {
        headers: { "Content-Type": "application/json", ...headers },
      });
      return response.data; // 결과 반환
    } catch (error) {
      console.error("Summary Error:", error.message);
      throw new functions.https.HttpsError("internal", "Summary failed");
    }
  });
