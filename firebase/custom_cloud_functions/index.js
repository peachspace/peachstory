const admin = require("firebase-admin/app");
admin.initializeApp();

const deleteCommentAndReplies = require("./delete_comment_and_replies.js");
exports.deleteCommentAndReplies =
  deleteCommentAndReplies.deleteCommentAndReplies;
const deleteChatWithMessages = require("./delete_chat_with_messages.js");
exports.deleteChatWithMessages = deleteChatWithMessages.deleteChatWithMessages;
const deleteStoryWithData = require("./delete_story_with_data.js");
exports.deleteStoryWithData = deleteStoryWithData.deleteStoryWithData;
const callAiProxy = require("./call_ai_proxy.js");
exports.callAiProxy = callAiProxy.callAiProxy;
const indexStory = require("./index_story.js");
exports.indexStory = indexStory.indexStory;
const searchAll = require("./search_all.js");
exports.searchAll = searchAll.searchAll;
const generateReplicateImage = require("./generate_replicate_image.js");
exports.generateReplicateImage = generateReplicateImage.generateReplicateImage;
const callAiSummary = require("./call_ai_summary.js");
exports.callAiSummary = callAiSummary.callAiSummary;
