const admin = require("firebase-admin/app");
admin.initializeApp();

const deleteCommentAndReplies = require("./delete_comment_and_replies.js");
exports.deleteCommentAndReplies =
  deleteCommentAndReplies.deleteCommentAndReplies;
const searchAll = require("./search_all.js");
exports.searchAll = searchAll.searchAll;
const createKomojuPayment = require("./create_komoju_payment.js");
exports.createKomojuPayment = createKomojuPayment.createKomojuPayment;
const verifyKomojuPayment = require("./verify_komoju_payment.js");
exports.verifyKomojuPayment = verifyKomojuPayment.verifyKomojuPayment;
