나의 전체개발로직을 설명하자면 

storycreatepage에서 

storytap의 경우

storyName에 제목을 직접 입력 또는 여기 프롬프트를 입력후 titlegenbutton버튼을 누르면 제목이 자동생성되고,

worldSettings에 세계관을 직접 입력 또는 여기 프롬프트를 입력후 worldviewgenbutton버튼을 누르면 세계관이 자동생성되고,

placetextfield에 모든 장소를 직접 입력 또는 여기 프롬프트를 입력후 placegenbutton버튼을 누르면 모든 장소가 자동생성되는데 placegenbutton이 작동하려면 반드시 worldSettings텍스트필드가 채워져 있어야 하므로 채워져 있지 않으면 "세계관을 먼저 입력해주세요."라는 스낵바가 뜬다.

addplaceimagebutton을 누르면 placeimagelist이동하여 placeuploadbutton눌러서 이미지를 업로드하면 placestruct컴포넌트의 placeImage에 이미지가 표시되고 placetagDropDown에서 장소를 선택하면 그 업로드한 이미지에 대한 장소태그가 되는데, placeimagelist에는 수많은 이미지를 업로드할 수 있고 각각의 이미지에 장소태그를 설정할 수 있는데, 

placetagDropDown에 나열되어 있는 장소목록은 placetextfield에 예를들어

메가커피: 지안이 자주가는 카페

성광고등학교: 지안의 고등학교

이렇게 입력했다면 placetagDropDown에는 옵션으로 '메가커피', '성광고등학교'가 있을 것이다.

그런데 나는 titlegenbutton, worldviewgenbutton, placegenbutton을 삭제하고 storytapaigen을 누르면 storytapaigensheet가 열리고 거기에 ai에게 지시할 사항을 적고 aigen버튼을 누르면 storytapaigensheet닫히면서 ai가 생성하는 동안은 generatingcover가 뜨고 ai가 생성을 마치면 generatingcover가 사라지며 한번에 storyName, worldSettings, placetextfield가 채워진다.

chartap의 경우

characteraddbutton를 누르면 charsettingpage로 이동하는데, characteraddbutton이 작동하려면 반드시 worldSettings텍스트필드가 채워져 있어야 하므로 채워져 있지 않으면 "세계관을 먼저 입력해주세요."라는 스낵바가 뜬다.

profilegenbutton을 누르면 프로필이미지를 업로드할 수 있고 업로드하면 charprofileimage에 표시되고 다시 그 이미지를 클릭하면 업로드창이 뜨고 다시 업로드하면 이미지가 교체된다. 

charName에 캐릭터이름을 직접 입력 또는 여기 프롬프트를 입력후 charnamegenbutton버튼을 누르면 캐릭터이름이 자동생성되고,

charSetting에 캐릭터설정을 직접 입력 또는 여기 프롬프트를 입력후 charsettinggenbutton버튼을 누르면 캐릭터설정이 자동생성되고,

charability에 캐릭터능력을 직접 입력 또는 여기 프롬프트를 입력후 charabilitygenbutton버튼을 누르면 캐릭터능력이 자동생성되고,

charintroduce에 캐릭터소개를 직접 입력 또는 여기 프롬프트를 입력후 charintrogenbutton버튼을 누르면 캐릭터소개가 자동생성되고,

emotionaddbutton을 누르면 emotionimagelist로 이동하는데, emotionaddbutton이 작동하려면 반드시 charability텍스트필드가 채워져 있어야 하므로 채워져 있지 않으면 "캐릭터능력을 먼저 입력해주세요."라는 스낵바가 뜬다.

emotionimagelist는 위에서 설명한 placeimagelist의 로직과 같은데, 현재 나는 place태그와 emotion태그와 imageurl의 조합을 저장하는 로직으로 되어 있는데 그냥 단순하게 이미지를 업로드하면 emotion태그와 imageurl의 조합을 저장하는 로직으로 변경하고 싶다.

Abilityaddbutton도 위에서 설명한 placeimagelist의 로직과 같은데, 현재 나는 place태그와 Ability태그와 imageurl의 조합을 저장하는 로직으로 되어 있는데 그냥 단순하게 이미지를 업로드하면 Ability태그와 imageurl의 조합을 저장하는 로직으로 변경하고 싶다.

그런데 나는 charnamegenbutton, charsettinggenbutton, charabilitygenbutton, charintrogenbutton을 삭제하고 charaigen을 누르면 charaigensheet가 열리고 거기에 ai에게 지시할 사항을 적고 aigen버튼을 누르면 charaigensheet닫히면서 ai가 생성하는 동안은 generatingcover가 뜨고 ai가 생성을 마치면 generatingcover가 사라지며 한번에 charName, charSetting, charability, charintroduce가 채워진다.

charsettingpage에 입력한 뒤 charsavebutton을 눌러서 storycreatepage가면 charlist에 캐릭터의 프로필이미지/이름/소개가 표시되고 charlist의 아이템 중 하나를 클릭하여 다시 charsettingpage로 이동하면 이전에 입력했던 것들이 그대로 있고 그것을 수정하고 다시 저장하기를 누르면 수정된 것이 반영된다.

eventTab경우

event에 제목을 직접 입력 또는 여기 프롬프트를 입력후 eventgenbutton버튼을 누르면 제목이 자동생성되는데, eventgenbutton은 삭제하고 싶다. 

addeventimagebutton을 누르면 eventimagelist이동하여 eventuploadbutton눌러서 이미지를 업로드하면 eventstruct컴포넌트의 eventImage에 이미지가 표시되고 eventtagDropDown에서 이벤트를 선택하면 그 업로드한 이미지에 대한 이벤트태그가 되는데, eventimagelist에는 수많은 이미지를 업로드할 수 있고 각각의 이미지에 이벤트태그를 설정할 수 있는데, 

eventtagDropDown에 나열되어 있는 이벤트목록은 event에 예를들어

밴드연주: 공연이 시작되어 연주를 시작한다.

화산폭발: 때가되어 화산이 폭발한다.

이렇게 입력했다면 eventtagDropDown에는 옵션으로 '밴드연주', '화산폭발'가 있을 것이다.

아직 이 로직을 미완성했는데 이걸 완성시켜줘. placeimagelist와 같은 로직아니 다름없다. 

그리고 addeventimagebutton가 정상작동하려면 event가 반드시 작성되어 있어야 해서 event텍스트필드가 비어 있는데 addeventimagebutton을 누르면 "먼저 이벤트를 입력하세요."라는 스낵바가 뜬다.

event텍스트필드에 입력한 사건들은 스토리진행상 큰 사건, 혹, 하이라이트 같은 순간이므로 반드시 발생해야 하나 너무 자주 발생하면 안되고 스토리진행과의 개연성에 따라 필요시 발생시킨다. 

그리고 storycreatepage에서 직접입력하도록 했던 outline과 관련된 모든 것은 삭제하고, 나는 이것을 유저가 직접입력하게 하지 않고, ai가 자동으로 생성해서 저장하도록 하고 싶다. 이걸 구현해줘.

prologuetap의 경우

prologuetext에 프롤로그를 직접 입력 또는 여기 프롬프트를 입력후 placegenbutton버튼을 누르면 모든 장소가 자동생성되는데, placegenbutton이 작동하려면 반드시 worldSettings텍스트필드와 charlist가 채워져 있어야 하므로 채워져 있지 않으면 "세계관과 캐릭터를 먼저 설정해 주세요."라는 스낵바가 뜬다. 그런데 나는 placegenbutton을 삭제하고 prologuetapaigen을 누르면 prologueaigensheet가 열리고 거기에 ai에게 지시할 사항을 적고 aigen버튼을 누르면prologueaigensheet닫히면서 ai가 생성하는 동안은 generatingcover가 뜨고 ai가 생성을 마치면 generatingcover가 사라지며 prologuetext가 채워지도록 하고 싶다.

그리고 storytapaigen, prologuetapaigen, charaigen으로 자동생성시 호출할 ai모델은 gpt-4o-mini로 해라.

introTab의 경우 

editmainimagebutton 삭제하고, addmainimage을 눌러서 이미지를 업로드하면 mainimage에 이미지가 표시되고 mainimage를 길게 누르면 "삭제하시겟습니까?" 팝업이 뜨고 확인을 누르면 삭제되는 로직을 구현하고 싶다.

introgenbutton, storydetalilgenbutton은 삭제했다.

storycreateandeditbutton을 누르면 storymainpage로 이동하고

intromainImage에는 mainimage에 업로드헀던 이미지들이 표시되서 손가락으로 넘기면 이미지를 좌우로 넘길 수 있게 하고 싶다.

startButton버튼을 누르면 modeselectcomponent로 이동하는데 나는 modeselectcomponent를 삭제하고 모드선택은 안할거다. 즉 소설모드novelmode는 이제 사라지므로 buildStoryPrompt formatStoryTurnHeaderAndBg processAndSaveChatTurn NotifierChatList등에서 이에 대한 것도 삭제수정해줘. 따라서 startButton누르면 바로 storyusernameentercomponent가 뜨고 usernameTextField에 이야기속에서 불릴 이름을 입력하고 nameinstoryButton을 누르면 visualnovelpage로 간다. 

visualnovelpage에서는

스토리가 진행되면서 일단 1턴을 진행시 장소이미지가 화면을 꽉채우고 장소가 바뀌기 전까진 계속 그 장소이미지가 유지된다 그리고 1턴에 예를 들면 캐릭터가 대사하면 그 캐릭터의 감정이미지가 출력되어 장소이미지와 겹쳐져서 캐릭터의 배경이 장소이미지처럼 보이겟지. 감정이미지의 배경이 투명하기 때문이다. 캐릭터이미지가 보여진 상태에서 다른 캐릭터가 대사하면 그 다른 캐릭터의 이미지로 교체된다. 그리고 다음턴에서 장소가 바뀐다면 장소이미지만 출력되고 캐릭터이미지는 다 사라지지. 그리고 하단에는 내래이션이나 캐릭터 대사가 표시되는데 한문단씩 표시된다. 

예를 들면 

오늘의 날씨는 화창햇다.

지우 | 오늘 날씨 좋구나

자우는 기지개를 켯다.

갑자기 어딘가에서 알 수 없는 소리가 들려왔다. 지우는 두려움에 몸을 떨었다.

이런식으로 1턴에 출력된다면 하단에 먼저 

오늘의 날씨는 화창햇다.

가 표시되고 유저가 폰의 오른쪽 부분을 터치하면

지우 | 오늘 날씨 좋구나.

가 표시되고 유저가 폰의 오른쪽 부분을 다시 터치하면

자우는 기지개를 켯다.

가 표시되고 유저가 폰의 오른쪽 부분을 또다시 터치하면

갑자기 어딘가에서 알 수 없는 소리가 들려왔다. 지우는 두려움에 몸을 떨었다.

가 표시된다. 다시 유저가 폰의 오른쪽 부분을 또다시 터치하면

3개의 선택지와 입력창이 나타나고 선택지를 선택하거나 메세지를 전송하면 다음턴이 진행되는것이다. 

따라서

visualnovelpage에서 

placeimage는 장소이미지 즉 placeimagelist에서 업로드한 이미지가 태그에 따라 출력되는 곳이고,

charimage는 감정/능력이미지 즉 emotionimagelist/abilityimagelist에서 업로드한 이미지가 태그에 따라 출력되는 곳이고,

selectItem1, selectItem2, selectItem3에는 각각의 선택지 내용이 들어가는데 여기서 유저가 1개를 클릭하거나, usertextField에 유저가 메세지를 적고 send버튼을 누르면 그 다음 턴으로 넘어가는 것이다. 그런데 선택지나 send버튼을 눌렀을때 로그인되어 있지 않다면 loginpage바텀시트가 뜨면서 로그인을 하도록 하고, 만약 로그인되어 잇다고 해도 point가 부족하면 "포인트가 부족합니다. 충전페이지로 이동할까요?"라는 문구가 뜨고 "이동하기"를 누르면 pointchargepage로 이동하고, "취소하기"버튼을 누르면 그냥 팝업만 닫힌다.

charname에는 캐릭터의 이름이 표시되고. dialogueORnarration에는 캐릭터의 대사 또는 내래이션이 표시된다. 즉 내래이션일때는 charname가 표시되지 않고 dialogueORnarration에 내래이션만 표시되고, 캐릭터대사일때는 charname에 캐릭터이름과 dialogueORnarration에 대사내용이 표시된다. 그런데 내래이션이 표시될때는 dialogueORnarration의 텍스트컬러가 #E0E3E7이고, 캐릭터대사가 표시될 때에는 #FFFFFF이어야 한다.

backANDcontinue에 구현하려는 것은 내가 스마트폰의 오른쪽 부분을 클릭했을 때는 다음문단으로 넘어가고 왼쪽 부분을 클릭하면 이전 문단으로 돌아가는 기능이다. 즉 위의 예시에서

오늘의 날씨는 화창햇다.

가 표시되고 유저가 오른쪽 부분을 클릭하면 다음문단으로 넘어가서 

지우 | 오늘 날씨 좋구나

가 표시되고, 이 상태에서 왼쪽 부분을 클릭하면 이전문단으로 돌아가서

오늘의 날씨는 화창햇다.

가 표시된다.

그리고 appbar의 storytitle에는 스토리의 제목이 표시되고, currentplace에는 현재의 장소가 표시된다. 

sheetbutton을 누르면 settingsheet바텀시트가 열리고, 

aimodelTab에서는 ai모델을 선택할 수 있고 선택된 모델로 스토리가 진행되는데 디폴트로 선택되는 값은 Claude Haiku 4.5이며 ai모델을 선택하면 모델명이 빨간색으로 바뀌는 기능을 구현하고 싶다. 

usernoteTab에서는 usernoteTextField에 유저가 입력하면 ai는 그것을 계속 기억하는 기능이다. 

여기서 선택 또는 입력 후 시트의 바깥부분을 터치하면 시트가 닫히면서 선택 또는 입력한 값이 곧장 반영되는 것이다.

그리고 changemode를 누르면 기존의 storychatpage에서 했던 방식으로 진행할 수 있는 것이다. 여기서도 messagesendbutton눌렀을때 로그인되어 있지 않다면 loginpage바텀시트가 뜨면서 로그인을 하도록 하고, 만약 로그인되어 잇다고 해도 point가 부족하면 "포인트가 부족합니다. 충전페이지로 이동할까요?"라는 문구가 뜨고 "이동하기"를 누르면 pointchargepage로 이동하고, "취소하기"버튼을 누르면 그냥 팝업만 닫힌다.

title에는 스토리제목이 표시되고 changemode를 누르면 다시 visualmode로 돌아간다.

backicon을 누르면 chatlistpage이동한다.

homepage에서는 Carousel에는 운영자가 올리는 공지사항 같은 것들이 몇초마다 슬라이딩되면서 표시되고, 

recommendTab의 경우 

heartlistbutton에 나열된 것들은 유저가 storymainpage의 heart를 눌렀던 스토리들이다. hearttotal을 누르면 heartlistpage로 넘어가고 거기에는 유저가 heart를 누른 스토리들이 전부 나열되어 있다. heartlistbutton을 누르면 storymainpage로 넘어간다.

newlistbutton에 나열된 것들은 가장 최근에 생성된 스토리들이다. viewcountbox안의 viewIcon과 viewcount에서 viewcount는 유저들이 newlistbutton을 눌러서 storymainpage로 넘어가면 1씩 늘어난다.

rankingTab의 경우 

dailybutton이 눌려져 있는데 디폴트이고 dailybutton을 누르면 하루동안 가장많은 viewcount를 받은 순서대로 스토리가 나열되고, weeklybutton을 누르면 1주동안, monthlybutton을 누르면 1달 동안이다. ranklist를 누르면 storymainpage로 넘어가고 그 스토리의 viewcount가 1이 늘어난다.

categoryTab의 경우 

categorylist중에서 하나를 누르면 클릭한 카테고리에 포함되는 스토리가 나열된다. categoryDropDown에서 인기순을 선택하면 그 카테고리내에서 viewcount가 높은 순으로 나열되고, 최신순을 선택하면 가장 최근 생성된 순서로 나열된다. categorylist를 누르면 storymainpage로 넘어가고 그 스토리의 viewcount가 1이 늘어난다.

movetosearchpage를 누르면 searchpage로 넘어가고 거기서 searchTextField에 검색할 텍스트를 입력 후 searchbutton을 누르면 관련된 스토리 목록이 searchlist에 나열되고, searchcount에는 검색된 스토리의 숫자이고. searchDropDown에서 인기순을 선택하면 viewcount가 높은순서, 최신순을 선택하면 최근 생성된 순서에 따라 나열된다.

chatlistpage에는 유저가 visualnovelpage에 진입했던 스토리들이 나열된다. deletebutton을 누르면 "삭제하시겠습니까?"라는 문구가 뜨는 팝업창이 열리고 거기서 "삭제하기"을 누르면 해당 스토리목록이 삭제되고 "취소하기"를 누르면 그냥 돌아가는 기능을 만들어줘.

createlistpage에는 유저가 생성한 스토리들이 나열되는데, editORdeleteIcon누르면 createlisteditanddeletesheet바텀시트가 열리고, createlisteditButton를 누르면 이전에 생성한 storycreatepage로 이동하여 그곳에 이전에 입력했던 것들이 그대로 입력되어 있고 거기서 입력한 값들을 수정 후 storycreateandeditbutton누르면 수정된 것들이 반영된다. createlistdeleteButton을 누르면 삭제하시겠습니까?"라는 문구가 뜨는 팝업창이 열리고 거기서 "삭제하기"을 누르면 해당 스토리목록이 삭제되고 "취소하기"를 누르면 그냥 돌아가는 기능을 만들어줘.

mypage로 진입하려고 하는데 로그인 되어 있지 않다면 loginpage바텀시트가 뜨면서 로그인을 하도록 한다.

그리고 나는 현재 요약로직을 사용하고 있는데, 이야기의 턴이 오래되면 ai가 전부 기억하기 어렵고 컨텍스트가 너무 길어져 1턴을 진행하는데 매우 많은 api비용이 들 수 있다는데 이를 해결하는데에 rag기능을 구현하면 좋다는데, 스토리가 개연성있게 자연스럽게 진행하면서 장기기억도 훌륭하게 만들어줘. 단순한 rag기능은 별로 좋지 않고, 실무에서 가장 무난하게 성능이 확 올라가는 정석은 “Hybrid Search + Rerank + Chunk 최적화 + Query Rewrite + Answer Guardrails” 조합이라는데, 이렇게 하는게 맞다면 이렇게 구현해줘.
