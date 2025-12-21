const functions = require("firebase-functions");
const admin = require("firebase-admin");
const algoliasearch = require("algoliasearch");

exports.indexStory = functions
  .runWith({ secrets: ["ALGOLIA_APP_ID", "ALGOLIA_ADMIN_KEY"] })
  .firestore.document("stories/{storyId}")
  .onWrite(async (change, context) => {
    const client = algoliasearch(
      process.env.ALGOLIA_APP_ID,
      process.env.ALGOLIA_ADMIN_KEY,
    );
    const index = client.initIndex("peach_content");

    if (!change.after.exists) {
      await index.deleteObject(context.params.storyId); // 삭제 시 인덱스 제거
      return;
    }

    const data = change.after.data();
    await index.saveObject({
      objectID: context.params.storyId,
      type: "story",
      searchable_title: data.title,
      searchable_content: data.description,
      heart_count: data.heartCount || 0,
      created_timestamp: data.created_timestamp?.toMillis() || 0,
      mainImage: data.mainImage,
      category: data.category,
      hashtags: data.hashtags || [],
      creatorNickname: data.creatorNickname,
    });
  });
