const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

// 중복 초기화 방지
if (admin.apps.length === 0) {
  admin.initializeApp();
}

exports.callAiProxy = functions
  .runWith({
    // ✅ [여기가 핵심] 시크릿 매니저에서 가져올 키 목록을 명시합니다.
    secrets: [
      "ANTHROPIC_API_KEY",
      "GROQ_API_KEY",
      "GOOGLE_API_KEY",
      "OPENAI_API_KEY",
      "UPSTAGE_API_KEY", // 새로 추가된 친구
    ],
    timeoutSeconds: 300,
  })
  .https.onCall(async (data, context) => {
    // 1. 인증 체크
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    // 2. 입력 데이터 처리 (안전한 문법 || 사용)
    const modelName = data.modelName;
    const systemPrompt = data.systemPrompt || "";
    const messages = data.messages || [];

    console.log("▶ Request Received:", { modelName });

    if (!modelName) {
      throw new functions.https.HttpsError("invalid-argument", "No modelName");
    }

    // 3. Provider 결정 로직
    let provider = "anthropic";
    if (modelName.includes("solar")) provider = "upstage";
    else if (modelName.startsWith("openai/"))
      provider = "groq"; // ✅ 추가
    else if (modelName.includes("gpt-oss"))
      provider = "groq"; // ✅ 추가
    else if (modelName.startsWith("gpt")) provider = "openai";
    else if (modelName.startsWith("gemini")) provider = "google";
    else if (modelName.startsWith("claude")) provider = "anthropic";

    let uri, headers, body;

    // 4. API 호출 설정 (process.env로 시크릿 값 사용)
    switch (provider) {
      case "upstage":
        // [수정 완료] Solar 엔드포인트
        uri = "https://api.upstage.ai/v1/chat/completions";
        headers = {
          // runWith에 secrets를 넣으면 process.env로 읽을 수 있습니다.
          Authorization: `Bearer ${process.env.UPSTAGE_API_KEY}`,
          Accept: "application/json",
        };
        body = {
          model: modelName, // solar-pro 등
          messages: [{ role: "system", content: systemPrompt }, ...messages],
          stream: false,
          max_tokens: 1500,
          temperature: 0.8,
        };
        break;

      case "groq":
        uri = "https://api.groq.com/openai/v1/chat/completions";
        headers = { Authorization: `Bearer ${process.env.GROQ_API_KEY}` };
        body = {
          model: modelName,
          messages: [{ role: "system", content: systemPrompt }, ...messages],
        };
        break;

      case "openai":
        uri = "https://api.openai.com/v1/chat/completions";
        headers = { Authorization: `Bearer ${process.env.OPENAI_API_KEY}` };
        body = {
          model: modelName,
          messages: [{ role: "system", content: systemPrompt }, ...messages],
        };
        break;

      case "google":
        uri = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent`;
        headers = { "x-goog-api-key": process.env.GOOGLE_API_KEY };
        body = {
          contents: messages.map((msg) => ({
            role: msg.role === "assistant" ? "model" : "user",
            parts: [{ text: msg.content }],
          })),
          system_instruction: { parts: [{ text: systemPrompt }] },
        };
        break;

      default: // anthropic
        uri = "https://api.anthropic.com/v1/messages";
        headers = {
          "x-api-key": process.env.ANTHROPIC_API_KEY,
          "anthropic-version": "2023-06-01",
        };
        body = {
          model: modelName,
          system: systemPrompt,
          messages: messages,
          max_tokens: 4096,
        };
        break;
    }

    // 5. 실제 요청 및 응답 처리
    try {
      const response = await axios.post(uri, body, {
        headers: { "Content-Type": "application/json", ...headers },
      });
      let aiContent = "";

      if (provider === "anthropic") aiContent = response.data.content[0].text;
      else if (provider === "google")
        aiContent = response.data.candidates[0].content.parts[0].text;
      else aiContent = response.data.choices[0].message.content;

      return { fullText: aiContent };
    } catch (error) {
      // 에러 로깅 강화
      const errorResponse = error.response || {};
      const errorData = errorResponse.data || {};

      console.error(
        `🚨 AI Error [${provider}]:`,
        JSON.stringify(
          {
            status: errorResponse.status,
            data: errorData,
            uri: uri,
          },
          null,
          2,
        ),
      );

      const errMsg =
        (errorData.error && errorData.error.message) || error.message;
      return {
        fullText: `Error (${provider} ${errorResponse.status || "Unknown"}): ${errMsg}`,
      };
    }
  });
