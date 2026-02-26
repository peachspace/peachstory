[ui-fullsync 브랜치에서만 작업]

1) 레포 루트에 REQUIREMENTS.md 생성
2) 내가 다음 메시지로 보내는 요구사항 전문을 REQUIREMENTS.md에 그대로 붙여넣어 저장
3) 저장만 하고, 코드 수정은 절대 하지 마
4) flutter analyze 실행하지 말고, 커밋/푸시만 해
   - commit message: "docs: add REQUIREMENTS"
   - push: origin/ui-fullsync 

너는 내말을 이해못하는거 같은데 storytap에서 ai자동생성시 로딩떄 1번쨰 스샷처럼 뜨잖아. 나는 이걸 2번쨰 스샷처럼 바꾸고 싶다고. 2번째 스샷은 charsettingpage에서 ai자동생성시 로딩화면이잖아. 이걸 똑같이 대체 왜 못해? 내말이 이해가 안되는건가? 만약 그렇다면 이해가 안된다고 대답해.

그리고 prologue ai자동생성하면 

장소: 심해 왕국

깊고 어두운 심해의 세계, 이곳은 신비한 생명체들이 살아 숨 쉬는 곳이다. 수천 년 전, 심해에서 태어난 이 왕국은 바다의 신비로움과 인간의 탐욕이 뒤엉킨 곳이었다. 왕국의 중심에는 반짝이는 세종과 같은 조개들이 있어, 주민들은 이 조개들로 만든 공예품과 음식을 통해 생계를 유지하곤 했다. 그러나 점차 인간의 오만함이 이곳의 평화를 위협하고 있었다.

에일라는 이 왕국에서 태어난 따뜻한 성격의 소녀였다. 낙천적이고 호기심이 넘치는 그녀는 늘 새로운 모험을 기다리며 수중 생물들과 교류했다. 그녀의 부모는 신비로운 생물로, 자신도 그들의 특별한 능력을 물려받았음을 알고 있었지만 그 사실을 숨기고 있었다. 에일라는 심해의 생명을 지키고, 인간과 신비로운 생물들이 공존할 수 있는 방법을 찾기 위해 노력하고 있었다.

어느 날, 에일라는 고래의 폐허에서 전설적인 고래의 영혼을 만나는 꿈을 꾸었다. 고래는 그녀에게 심해의 위기를 경고하고, 빛나는 반딧불이 구멍에서 마법적인 힘을 찾아야 한다고 전해주었다. 이 이야기를 듣고 에일라는 결심하게 되었다. 그녀는 자신의 운명을 찾기 위해 이 위험한 여정을 떠나기로 했다.

"다 같이 힘내보자! 실패가 두렵지 않아!" 그녀의 목소리는 깊은 바다를 가르며 울려 퍼졌다. 어둠 속에 빛나는 수많은 눈들이 그녀를 바라보았다. 이제 에일라의 이야기가 시작되려 하고 있었다.

이렇게 나오는데 너는 내 말을 전혀 이해 못해? "다 같이 힘내보자! 실패가 두렵지 않아!" << 이 부분은 캐릭터가 대사하고 있는거 아니야? 그럼 

에일라: 다 같이 힘내보자! 실패가 두렵지 않아! 

그녀의 목소리는 깊은 바다를 가르며 울려 퍼졌다. 어둠 속에 빛나는 수많은 눈들이 그녀를 바라보았다. 이제 에일라의 이야기가 시작되려 하고 있었다.

이렇게 나와야 하는거 아닌가?

그리고 3번쨰 스샷을 보면 선택지가 매번 똑같은데 왜 매번 똑같은가? 선택지는 스토리에 따라 ai가 다르게 제시하는거 아닌가? 그리고 선택지에는 유저가 해야 하는 행동묘사 또는 대사가 선택지로 제시되어야 한다. 행동묘사면 그냥 문장으로 하고 대사면 따옴표로 감싼다.
예를 들면

가방을 맨다.

세린의 뺨을 때린다.

"너 미친거야?" 

이런식으로 3개의 선택지가 나오는 형식이다. 물론 행동묘사만 나올 수도 대사만 나올 수 도 있다 그건 스토리진행에 따른 ai의 재량이다.

그리고 선택지의 아래에는 직접 입력하는 창인데 5번쨰 스샷과 같은 디자인으로 하고 싶다. 
즉 디폴트로 hint text는 '당신의 대사를 입력하세요.'라고 뜨고 유저는 거기 전송할 대사를 입력하는 것이다.
왼쪽 끝 아이콘을 누르면 hint text는 '당신의 행동을 입력하세요.'라고 뜨고 유저는 전송할 행동을 입력하는 것이다. 
그래서 ai는 유저의 대사나 행동을 전송받고 그에 따라 다음 턴을 이어서 진행하는 거다. 그런데 현재 입력창에 입력이 불가능하다. 왜 입력할 수가 없나? 
그리고 나는 선택지를 누르거나 메세지전송창에 입력후 전송버튼을 누르는 경우 만약 선택지중 1개를 클릭햇다면 그 선택된 아이템을 제외하고 나머지 선택지와 메세지전송창은 사라지고 선택된 아이템은 1번째 선택지가 있는 위치로 이동하는 애니메이션효과를 구현하고싶다. 즉 3개의 선택지중 1번쨰를 선택했다면 그자리에 있을것이고 나머지 선택지와 메세지전송창만 사라지고, 2번쨰를 선택하면 2번째 선택지 외에 나머지 것들이 사라진 뒤 2번째 선택지가 1번째 선택지 자리로 이동한다. 3번째를 선택해도 마찬가지의 효과이다. 메세지전송창에 입력후 전송버튼을 누르면 dialogueORnarrationchange와 send아이콘은 사라지고 입력한 값은 중앙정렬되고 나머지 선택지는 모두 사라진 뒤에 그 입력창이 1번쨰 선택지가 있던 위치로 이동하는 애니메이션이다.

그리고 선택지를 누르고 다음턴을 진행하는데 4번째 스샷처럼 여전히 선택지와 메세지전송창도 그대로 있어서 캐릭터대사 또는 내래이션 표시창과 겹쳐져 있다. 선택지를 선택하거나 메세지를 전송한 뒤에는 그것이 사라지고 이어서 내래이션과 대사창만 떠서 진행되어야 하잖아.

그리고 6번쨰 스샷처럼 appbar의 status아이콘을 새로 만드려고 한다.  status아이콘을 누르면 7번쨰 스샷처럼 상태창이 떠서 현재의 스탯과 아이템목록을 볼 수 있는 것이다. 그리고 그 스탯박스 밖을 클릭하면 스탯박스가 닫히고 원래의 화면으로 돌아가는 것이다. 
스탯창에 표시되는 것은 기존의 storycreatepage에서 tapbar를 scrollable로 하고 charTap과 eventTap사이에 stateANDitemTab을 만들고 거기서 예를 들어 
charstateanditemtextfield에는 
[지우 스탯]
호감도=40(0~100)
신뢰=30(0~100)
체력=70(0~100)
[지우 아이템]
사탕 x3

[세린 스탯]
호감도=40(0~100)
신뢰=30(0~100)
체력=70(0~100)
[세린 아이템]
사탕 x3

이렇게 입력하고
userstateanditemtextfield에는
[유저 스탯]
체력=80(0~100)
호감도=50(0~100)
스트레스=20(0~100)
돈=2000(0~999999)

[유저 아이템]
붕대 x2
에너지드링크 x1
열쇠카드 x1   

이렇게 입력하고 ruletextfield에는 
[지우]
칭찬받음 -> 호감도 +5

[세린]
모욕당함 -> 호감도 -8, 유저 스트레스 +10

[유저]
붕대 획득 -> 붕대 +1
붕대 소비 -> 붕대 -1, 체력 +8
이런식으로 입력하고 storycreateandeditbutton누르면 그것이 visualnovelpage에서 적용되는 것이다.

그리고 나는 prologulTap애 가이드에 관한 부분을 추가하려고 한다. 그래서 guidetextfield에 텍스트를 입력하고 storycreateandeditbutton를 눌러서 storymainpage가서 startButton을 누르고 storyusernameentercomponent에서 nameinstoryButton누르면 8번째 스샷과 같은 guildpage가 먼저 나오고 여기의 guildtext에 guidetextfield에 입력한 것이 표시된다. guidetextfield에 아무것도 입력하지 않으면 '입력된 가이드가 없습니다.'가 표시된다. 그리고 continuebutton을 누르면 visualnovelpage로 이동한다. guildpage는 스토리를 처음진입할 때만 표시된다.

그리고 나는 visualnovelpage에 처음 진입할때는 9번쨰 스샷과 같이 firstentercover가 뜨도록 하고 싶다 여기서 화면의 아무곳이나 클릭하면 그 커버가 사라지고 이야기가 시작된다.

그리고 나는 storycreatepage와 charsettingpage의 모든 텍스트필드의 border color를 alternate으로 border width를 0.05로, border radius를 20으로, fill color를 #2a2a2a로 바꾸고 싶다. storycreatepage와 charsettingpage의 앱바의 색은 #14181B로 바꾸고 싶다. storycreatepage의 storycreateandeditbutton의 border color를 alternate으로 border width를 0.05로 fill color를 #3b3b3b로 elevation을 5.0로 바꾸고 싶다. characteraddbutton과 메인이미지버튼도 border color를 alternate으로 border width를 0.05로 fill color를 #3b3b3b로 elevation을 5.0로 바꾸고 싶다. charsettingpage의 프로필이미지버튼과 charsavebutton의 border color를 alternate으로 border width를 0.05로 fill color를 #3b3b3b로 elevation을 5.0로 바꾸고 싶다. 
그외에 heartlistpage, homepage, searchpage, chatlistpage, createlistpage의 앱바의 색은 #14181B로 바꾸고 싶다. 
abilityimagelist, emotionimagelist, eventimagelist, placeimagelist, storymainpage의 앱바의 색은 #14181B로 바꾸고, 하단버튼들은 border color를 alternate으로 border width를 0.05로 fill color를 #3b3b3b로 elevation을 5.0로 바꾸고 싶다. 
settingsheet의 fill color는 #000000으로, opacity는 0.7로, border radius는 상단 양쪽 모서리 부분만 20으로 바꾸고 싶다.
storyusernameentercomponent의 fill color는 #000000으로, opacity는 0.7로 바꾸고 싶다. 

관련된 ui코드로는 

1. guidepage
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'guidepage_model.dart';
export 'guidepage_model.dart';

class GuidepageWidget extends StatefulWidget {
  const GuidepageWidget({super.key});

  static String routeName = 'guidepage';
  static String routePath = '/guidepage';

  @override
  State<GuidepageWidget> createState() => _GuidepageWidgetState();
}

class _GuidepageWidgetState extends State<GuidepageWidget> {
  late GuidepageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GuidepageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(25, 0, 25, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                  child: Text(
                    '플레이 가이드',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          fontSize: 18,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: FlutterFlowTheme.of(context).error,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                  child: Text(
                    '입력된 가이드가 없습니다.',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).alternate,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: FlutterFlowTheme.of(context).error,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                            child: Text(
                              '시작하기',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    fontSize: 16,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.double_arrow,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 22,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

2. visualnovelpage
(1) firstentercover
Widget buildFirstEnterCover(BuildContext context) {
  return Opacity(
    opacity: 0.7,
    child: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.keyboard_double_arrow_left,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 150,
                  ),
                  Text(
                    '화면의 왼쪽을 클릭하면 \n이전으로 돌아갑니다.',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight:
                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                            fontStyle:
                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          letterSpacing: 0.0,
                          fontWeight:
                              FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.keyboard_double_arrow_right,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 150,
                  ),
                  Text(
                    '화면의 오른쪽을 클릭하면\n다음으로 넘어갑니다.',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight:
                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                            fontStyle:
                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          letterSpacing: 0.0,
                          fontWeight:
                              FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

(2) selectANDmessage
Widget buildSelectAndMessage(BuildContext context) {
  return Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 50),
    child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 선택지 1/2/3 UI는 위에 같은 스타일 Stack 3개를 이미 쓰고 있으므로,
        // 여기서는 "입력 + 전송" 부분만 제공한다.
        Stack(
          children: [
            Opacity(
              opacity: 0.5,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(25, 0, 25, 0),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0x26000000),
                        Color(0x73000000),
                        Color(0x8C000000),
                        Color(0x8C000000),
                        Color(0x73000000),
                        Color(0x26000000)
                      ],
                      stops: [0, 0.08, 0.2, 0.8, 0.92, 1],
                      begin: AlignmentDirectional(1, 0),
                      end: AlignmentDirectional(-1, 0),
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(25, 0, 25, 0),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.change_circle,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 24,
                      ),
                      Stack(
                        children: [
                          // 행동 입력
                          SizedBox(
                            width: 250,
                            child: TextFormField(
                              controller: _model.useractiontextFieldTextController,
                              focusNode: _model.useractiontextFieldFocusNode,
                              autofocus: false,
                              enabled: true,
                              obscureText: false,
                              decoration: InputDecoration(
                                isDense: true,
                                labelStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                hintText: '당신의 행동을 입력하세요.',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              maxLines: null,
                              minLines: 1,
                              maxLength: 200,
                              maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              buildCounter: (context,
                                      {required currentLength,
                                      required isFocused,
                                      maxLength}) =>
                                  null,
                              cursorColor: FlutterFlowTheme.of(context).alternate,
                              enableInteractiveSelection: true,
                              validator: _model
                                  .useractiontextFieldTextControllerValidator
                                  .asValidator(context),
                            ),
                          ),

                          // 대사 입력 (같은 위치에 겹쳐서, 토글로 보여줄 용도)
                          SizedBox(
                            width: 250,
                            child: TextFormField(
                              controller:
                                  _model.userdialoguetextFieldTextController,
                              focusNode: _model.userdialoguetextFieldFocusNode,
                              autofocus: false,
                              enabled: true,
                              obscureText: false,
                              decoration: InputDecoration(
                                isDense: true,
                                labelStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                hintText: '당신의 대사를 입력하세요.',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              maxLines: null,
                              minLines: 1,
                              maxLength: 200,
                              maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              buildCounter: (context,
                                      {required currentLength,
                                      required isFocused,
                                      maxLength}) =>
                                  null,
                              cursorColor: FlutterFlowTheme.of(context).alternate,
                              enableInteractiveSelection: true,
                              validator: _model
                                  .userdialoguetextFieldTextControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.send,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

(3) state
Widget buildStatePanel(BuildContext context) {
  return Opacity(
    opacity: 0.7,
    child: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(25, 40, 25, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(15, 15, 15, 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: const AlignmentDirectional(-1, 0),
                child: Text(
                  '유저',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).warning,
                        fontSize: 16,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
              Divider(
                thickness: 1,
                color: FlutterFlowTheme.of(context).alternate,
              ),
              SizedBox(
                height: 160, // 필요하면 조절
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 왼쪽: 스탯 리스트
                    SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                              child: Text(
                                '스탯',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: const Color(0xFF8B97FF),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 7, 0),
                                    child: Text(
                                      '호감도',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                              fontStyle: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            letterSpacing: 0.0,
                                            fontWeight: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '50',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context).tertiary,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 오른쪽: 아이템 리스트
                    SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                              child: Text(
                                '아이템',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: const Color(0xFF0BEF44),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 7, 0),
                                    child: Text(
                                      '붕대',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                              fontStyle: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            letterSpacing: 0.0,
                                            fontWeight: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    'x2',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context).tertiary,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

(4) status
Widget buildStatusIconRow(BuildContext context) {
  return Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(25, 50, 25, 0),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          Icons.arrow_back_ios,
          color: FlutterFlowTheme.of(context).secondaryBackground,
          size: 22,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
              child: Icon(
                Icons.cached,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                size: 22,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
              child: Icon(
                Icons.auto_awesome_mosaic_rounded,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                size: 22,
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                scaffoldKey.currentState!.openEndDrawer();
              },
              child: Icon(
                Icons.menu,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                size: 25,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

3. storycreatepage
(1) stateANDitemTab
Padding(
  padding: EdgeInsetsDirectional.fromSTEB(25, 0, 25, 0),
  child: SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1, 0),
                      child: Text(
                        'ìºë¦­í° ì¤í¯/ìì´í',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              fontSize: 18,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: TextFormField(
                  controller: _model.charstateanditemtextfieldTextController,
                  focusNode: _model.charstateanditemtextfieldFocusNode,
                  onChanged: (_) => EasyDebounce.debounce(
                    '_model.charstateanditemtextfieldTextController',
                    Duration(milliseconds: 2000),
                    () async {
                      _model.event =
                          _model.charstateanditemtextfieldTextController.text;
                      safeSetState(() {});
                    },
                  ),
                  autofocus: false,
                  obscureText: false,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText:
                        '- ì¤ì í ìºë¦­í°ë¤ì ì¤í¯ ëë ìì´íì ëí ì¤ì ì ìë ¥íì¸ì.\n- ë°ëì ìëì íìì ë°ë¼ ìë ¥íì¸ì.\n\n[ìºë¦­í°ëª ì¤í¯]\nì¤í¯ëª=ê¸°ë³¸ìì¹(ë³ëë²ì)\n\n[ìºë¦­í°ëª ìì´í]\nìì´íëª xê¸°ë³¸ê°ì\n\n- ìì±ìì\n\n[ì§ì° ì¤í¯]\ní¸ê°ë=40(0~100)\nì ë¢°=30(0~100)\nì²´ë ¥=70(0~100)\n[ì§ì° ìì´í]\nì¬í x3\n\n[ì¸ë¦° ì¤í¯]\ní¸ê°ë=40(0~100)\nì ë¢°=30(0~100)\nì²´ë ¥=70(0~100)\n[ì¸ë¦° ìì´í]\nì¬í x3',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 0.05,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 0.05,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 0.05,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 0.05,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    contentPadding:
                        EdgeInsetsDirectional.fromSTEB(10, 15, 10, 15),
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight:
                              FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).alternate,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                  maxLines: null,
                  minLines: 26,
                  maxLength: 4000,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                  cursorColor: FlutterFlowTheme.of(context).alternate,
                  validator: _model.charstateanditemtextfieldTextControllerValidator
                      .asValidator(context),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1, 0),
                      child: Text(
                        'ì ì  ì¤í¯/ìì´í',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              fontSize: 18,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: TextFormField(
                  controller: _model.userstateanditemtextfieldTextController,
                  focusNode: _model.userstateanditemtextfieldFocusNode,
                  onChanged: (_) => EasyDebounce.debounce(
                    '_model.userstateanditemtextfieldTextController',
                    Duration(milliseconds: 2000),
                    () async {
                      _model.event =
                          _model.userstateanditemtextfieldTextController.text;
                      safeSetState(() {});
                    },
                  ),
                  autofocus: false,
                  obscureText: false,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText:
                        '- ì ì ì ì¤í¯ ëë ìì´íì ëí ì¤ì ì ìë ¥íì¸ì.\n- ë°ëì ìëì íìì ë°ë¼ ìë ¥íì¸ì.\n\n[ì ì  ì¤í¯]\nì¤í¯ëª=ê¸°ë³¸ìì¹(ë³ëë²ì)\n\n[ì ì  ìì´í]\nìì´íëª xê¸°ë³¸ê°ì\n\n- ìì±ìì\n\n[ì ì  ì¤í¯]\ní¸ê°ë=40(0~100)\nì ë¢°=30(0~100)\nì²´ë ¥=70(0~100)\n[ì ì  ìì´í]\nì¬í x3',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    contentPadding:
                        EdgeInsetsDirectional.fromSTEB(10, 15, 10, 15),
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight:
                              FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).alternate,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                  maxLines: null,
                  minLines: 18,
                  maxLength: 4000,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                  cursorColor: FlutterFlowTheme.of(context).alternate,
                  validator: _model.userstateanditemtextfieldTextControllerValidator
                      .asValidator(context),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1, 0),
                      child: Text(
                        'ì¤í¯/ìì´í ë³ë ê·ì¹',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              fontSize: 18,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                child: Container(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _model.ruletextfieldTextController,
                    focusNode: _model.ruletextfieldFocusNode,
                    onChanged: (_) => EasyDebounce.debounce(
                      '_model.ruletextfieldTextController',
                      Duration(milliseconds: 2000),
                      () async {
                        _model.event = _model.ruletextfieldTextController.text;
                        safeSetState(() {});
                      },
                    ),
                    autofocus: false,
                    obscureText: false,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText:
                          '- ì¤í¯ ëë ìì´íì´ ë³ëëë ì¡°ê±´ ë° ìì¹ë¥¼ ìë ¥íì¸ì.\n- ë°ëì ìëì íìì ë°ë¼ ìë ¥íì¸ì.\n\n[ìºë¦­í°ëª/ì ì ]\n\nì¡°ê±´ -> ì¤í¯ëª Â±ì¦ê°ìì¹\nìì´íëª íë/ìë¹ -> ìì´íëª +ì¦ê°ì/-ê°ìì\n\n*ì¡°ê±´ì ë¼ë²¨íìì¼ë¡ ìë ¥íì¸ì\n*ë¤ë¥¸ ìºë¦­í°ì ìì¹ì ìí¥ì ì£¼ë ê²½ì° ì¤í¯ëª ìì ë¤ë¥¸ ìºë¦­í°ëªì ìë ¥í´ì£¼ì¸ì.\n\n- ìì±ìì\n\n[ì§ì°]\nì¹­ì°¬ë°ì -> í¸ê°ë +5\n\n[ì¸ë¦°]\nëª¨ìë¹í¨ -> í¸ê°ë -8, ì ì  ì¤í¸ë ì¤ +10\n\n[ì ì ]\në¶ë íë -> ë¶ë +1\në¶ë ìë¹ -> ë¶ë -1, ì²´ë ¥ +8',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Color(0xFF2A2A2A),
                      contentPadding:
                          EdgeInsetsDirectional.fromSTEB(10, 15, 10, 15),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).alternate,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                    maxLines: null,
                    minLines: 24,
                    maxLength: 4000,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    buildCounter: (context,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    cursorColor: FlutterFlowTheme.of(context).alternate,
                    validator: _model.ruletextfieldTextControllerValidator
                        .asValidator(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),

(2) prologueTab
Stack(
  children: [
    SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(25, 30, 25, 0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                          child: Text(
                            'íë¡¤ë¡ê·¸',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontSize: 18,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                        child: Text(
                          '*',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).error,
                                fontSize: 18,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _model.prologuetextTextController,
                      focusNode: _model.prologuetextFocusNode,
                      onChanged: (_) => EasyDebounce.debounce(
                        '_model.prologuetextTextController',
                        Duration(milliseconds: 2000),
                        () async {
                          _model.prologuetext =
                              _model.prologuetextTextController.text;
                          safeSetState(() {});
                        },
                      ),
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText:
                            '- ì¤í ë¦¬ì ì²« ì¥ë©´ì ìë ¥íì¸ì.\n- ì²« ì¤ìë ë°ëì ì¥ìë¥¼ ìë ¥íì¸ì.\n- (ê°ì )ìë ë¬´ê°ì  ê¸°ì¨ ì¬í íì¤ ëë ¤ì ëë ë¶ë¸ ì¦ íëë¥¼ ìë ¥íê³  ë¤ë¥¸ ê°ì ì¼ ê²½ì° ìë ¥íì§ ë§ì¸ì.\n- ë°ëì ìëì ìì±íìì ì§ì¼ì£¼ì¸ì.\n\nì¥ì: ì¥ìëª\n\në´ëì´ì\n\nìºë¦­í°ì´ë¦(ê°ì ): ëì¬ë´ì©\n\n[ìì±ìì]\n\nì¥ì: íì­ íë«í¼\n\níë«í¼ ëìì ë°ëì´ ë°ë ¤ì, ë¹ì¨ ìë´íì ìê² ê¸ìë¤. ì ê´íì êº¼ì ¸ ìëë°ë ì«ì ê·¸ë¦¼ìê° ê¹ë¹¡ì´ë ê²ì²ë¼ ë³´ìë¤.\n\në¦¬ì(ëë ¤ì): ì¤ëëâ¦ ê·¸ ìë¦¬ ë¤ìì§?\n\nì§ìë ëëµ ëì  ìì ë±ì ë¤ì´ ì²ì¥ì ë¹ì·ë¤.\n\nê±°ë¯¸ì¤ ì¬ì´ë¡ ë§¤ë¬ë¦° ì ì ì´, ëê° ì¡ìë¹ê¸°ê¸°ë¼ë í ë¯ ì²ì²í íë¤ë ¸ë¤\n\nì§ì: ì´ê±°, ë°©ê¸ ë¨ì´ì§ ê±°ì¼. ',
                        hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).alternate,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontWeight,
                              fontStyle:
                                  FlutterFlowTheme.of(context).labelMedium.fontStyle,
                            ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x00000000),
                            width: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x00000000),
                            width: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x00000000),
                            width: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                        contentPadding:
                            EdgeInsetsDirectional.fromSTEB(10, 15, 10, 15),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).alternate,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle:
                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                      maxLines: null,
                      minLines: 29,
                      maxLength: 1000,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null,
                      cursorColor: FlutterFlowTheme.of(context).alternate,
                      validator:
                          _model.prologuetextTextControllerValidator.asValidator(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(25, 30, 25, 0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                          child: Text(
                            'ê°ì´ë',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontSize: 18,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 40),
                    child: Container(
                      width: double.infinity,
                      child: TextFormField(
                        controller: _model.guidetextfieldTextController,
                        focusNode: _model.guidetextfieldFocusNode,
                        onChanged: (_) => EasyDebounce.debounce(
                          '_model.guidetextfieldTextController',
                          Duration(milliseconds: 2000),
                          () async {
                            _model.prologuetext =
                                _model.guidetextfieldTextController.text;
                            safeSetState(() {});
                          },
                        ),
                        autofocus: false,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'ì¤í ë¦¬ì ëí ê°ì´ëë¥¼ ìë ¥íì¸ì.',
                          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).alternate,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontWeight,
                                fontStyle:
                                    FlutterFlowTheme.of(context).labelMedium.fontStyle,
                              ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Color(0xFF2A2A2A),
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(10, 15, 10, 15),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).alternate,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle:
                                  FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                            ),
                        maxLines: null,
                        minLines: 5,
                        maxLength: 1000,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        buildCounter: (context,
                                {required currentLength,
                                required isFocused,
                                maxLength}) =>
                            null,
                        cursorColor: FlutterFlowTheme.of(context).alternate,
                        validator: _model.guidetextfieldTextControllerValidator
                            .asValidator(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    Align(
      alignment: AlignmentDirectional(1, 1),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 25, 25),
        child: Icon(
          Icons.auto_fix_high,
          color: FlutterFlowTheme.of(context).primary,
          size: 24,
        ),
      ),
    ),
  ],
),
