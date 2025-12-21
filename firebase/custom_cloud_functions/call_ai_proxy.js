const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

exports.callAiProxyV2 = functions
  .runWith({
    secrets: [
      "ANTHROPIC_API_KEY",
      "GROQ_API_KEY",
      "GOOGLE_API_KEY",
      "OPENAI_API_KEY",
    ],
    timeoutSeconds: 300,
  })
  .https.onCall(async (data, context) => {
    if (!context.auth)
      throw new functions.https.HttpsError("unauthenticated", "Auth required");

    const { modelName, systemPrompt, messages } = data;
    if (!modelName)
      throw new functions.https.HttpsError("invalid-argument", "No modelName");

    let provider = "anthropic";
    if (modelName.includes("gemma") || modelName.includes("llama"))
      provider = "groq";
    else if (modelName.startsWith("gpt")) provider = "openai";
    else if (modelName.startsWith("gemini")) provider = "google";
    else if (modelName.startsWith("claude")) provider = "anthropic";

    let uri, headers, body;
    switch (provider) {
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
          system_instruction: { parts: [{ text: systemPrompt ?? "" }] },
        };
        break;
      default:
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
      console.error("AI Error:", error.message);
      return { fullText: "Error" };
    }
  });
