const admin = require("firebase-admin/app");
admin.initializeApp();

const deleteCommentAndReplies = require("./delete_comment_and_replies.js");
exports.deleteCommentAndReplies =
  deleteCommentAndReplies.deleteCommentAndReplies;
const createKomojuPayment = require("./create_komoju_payment.js");
exports.createKomojuPayment = createKomojuPayment.createKomojuPayment;
const verifyKomojuPayment = require("./verify_komoju_payment.js");
exports.verifyKomojuPayment = verifyKomojuPayment.verifyKomojuPayment;
const deleteChatWithMessages = require("./delete_chat_with_messages.js");
exports.deleteChatWithMessages = deleteChatWithMessages.deleteChatWithMessages;
const deleteStoryWithData = require("./delete_story_with_data.js");
exports.deleteStoryWithData = deleteStoryWithData.deleteStoryWithData;
