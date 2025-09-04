const functions = require("firebase-functions");
const admin = require("firebase-admin");
const algoliasearch = require("algoliasearch");

// FlutterFlow 내부 환경 변수에서 Algolia 키를 가져옵니다.
const ALGOLIA_APP_ID = process.env.ALGOLIA_APP_ID;
const ALGOLIA_ADMIN_KEY = process.env.ALGOLIA_ADMIN_KEY;
const ALGOLIA_INDEX_NAME = "peach_content"; // Algolia 인덱스 이름을 정확히 입력

const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
const index = client.initIndex(ALGOLIA_INDEX_NAME);

exports.searchAll = functions
  .region("asia-northeast3")
  .runWith({
    memory: "128MB",
    secrets: ["ALGOLIA_APP_ID", "ALGOLIA_ADMIN_KEY"],
  })
  .https.onCall(async (data, context) => {
    const client = algoliasearch(
      process.env.ALGOLIA_APP_ID,
      process.env.ALGOLIA_ADMIN_KEY,
    );
    const index = client.initIndex("peach_content");

    const query = data.query || "";
    // 1. FlutterFlow에서 보낸 sortOption 파라미터를 받습니다.
    const sortOption = data.sortOption || "인기순"; // 기본값은 '인기순'

    // 2. Algolia 검색 옵션을 설정합니다.
    const searchOptions = {
      // Algolia에서는 replica index를 사용해 정렬합니다.
      // 예: 'peach_content_newest' (최신순 인덱스), 'peach_content_popular' (인기순 인덱스)
      // 이 부분은 Algolia 대시보드 설정에 따라 달라집니다.
      // 여기서는 간단하게 기본 인덱스를 사용하겠습니다.
    };

    try {
      const searchResult = await index.search(query, searchOptions);

      // 3. 받은 결과를 앱으로 보내기 전에 서버에서 직접 정렬합니다.
      let hits = searchResult.hits;
      if (sortOption === "최신순") {
        hits.sort(
          (a, b) => (b.created_timestamp || 0) - (a.created_timestamp || 0),
        );
      } else {
        // 인기순
        hits.sort((a, b) => (b.heart_count || 0) - (a.heart_count || 0));
      }

      return { results: hits };
    } catch (error) {
      console.error("Algolia search error:", error);
      throw new functions.https.HttpsError("internal", "Search failed.", error);
    }
  });
