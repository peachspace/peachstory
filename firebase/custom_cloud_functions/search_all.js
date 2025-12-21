const functions = require("firebase-functions");
const algoliasearch = require("algoliasearch");

exports.searchAll = functions
  .runWith({ secrets: ["ALGOLIA_APP_ID", "ALGOLIA_ADMIN_KEY"] })
  .https.onCall(async (data, context) => {
    const client = algoliasearch(
      process.env.ALGOLIA_APP_ID,
      process.env.ALGOLIA_ADMIN_KEY,
    );

    let indexName = "peach_content"; // 기본값 (인기순)
    if (data.sortOption === "최신순") indexName = "peach_content_latest";
    // 필요하다면 인기순 인덱스 이름 확인 필요 (algolia 대시보드와 일치해야 함)

    const index = client.initIndex(indexName);

    try {
      const res = await index.search(data.query || "", {
        attributesToRetrieve: [
          "type",
          "searchable_title",
          "searchable_content",
          "mainImage",
          "category",
          "genre",
          "creatorNickname",
          "documentId",
        ],
      });
      // 결과 가공
      const hits = res.hits.map((hit) => ({
        ...hit,
        documentId: hit.objectID,
      }));
      return { results: hits };
    } catch (error) {
      console.error("Search Error:", error);
      throw new functions.https.HttpsError("internal", "Search failed");
    }
  });
