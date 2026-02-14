import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// クイズ問題データ
const QUIZ_QUESTIONS = {
  'vocabulary': [
    {
      'question':
          'The board of directors will ____ the proposed merger at the next meeting.',
      'options': ['review', 'revise', 'reveal', 'resume'],
      'answer': 0,
      'explanation': '「検討する、再調査する」という意味のreviewが文脈に最も適しています。'
    },
    {
      'question':
          'Please ensure that all ____ for travel expenses are submitted by Friday.',
      'options': [
        'reimbursements',
        'installments',
        'subscriptions',
        'foundations'
      ],
      'answer': 0,
      'explanation':
          '「払い戻し、精算」を意味するreimbursementsが、出張経費（travel expenses）という文脈に合います。'
    },
    {
      'question':
          'The marketing team is looking for a more ____ approach to reach younger customers.',
      'options': ['reliable', 'innovative', 'vacant', 'manual'],
      'answer': 1,
      'explanation': '「革新的な」という意味のinnovativeが、新しい顧客層へのアプローチとして適切です。'
    },
    {
      'question':
          'Employees are encouraged to ____ in the upcoming professional development workshop.',
      'options': ['collaborate', 'participate', 'contribute', 'distribute'],
      'answer': 1,
      'explanation': 'participate inで「〜に参加する」という定型表現になります。'
    },
    {
      'question':
          'The new software has significantly ____ our workflow and productivity.',
      'options': ['increased', 'expanded', 'enhanced', 'prolonged'],
      'answer': 2,
      'explanation': '「（質や能力を）高める、向上させる」という意味のenhancedが、ワークフローや生産性に対して使われます。'
    },
    {
      'question':
          "The company's ____ performance has exceeded all expectations this fiscal year.",
      'options': ['financial', 'delicate', 'spacious', 'temporary'],
      'answer': 0,
      'explanation': '「財務の、金銭的な」という意味のfinancialが、業績（performance）を修飾するのに適しています。'
    },
    {
      'question':
          'Ms. Lee was ____ for her outstanding contribution to the successful project.',
      'options': ['notified', 'commended', 'persuaded', 'requested'],
      'answer': 1,
      'explanation':
          '「褒められた、表彰された」という意味のcommendedが、貢献（contribution）に対する評価として適切です。'
    },
    {
      'question':
          'The ____ of the contract will be negotiated by the legal department next week.',
      'options': ['terms', 'margins', 'versions', 'portions'],
      'answer': 0,
      'explanation': '「（契約などの）条件」を意味するtermsが契約（contract）の文脈でよく使われます。'
    },
    {
      'question':
          'Our technical support team is available ____ to assist with any urgent issues.',
      'options': ['briefly', 'cautiously', 'round-the-clock', 'strictly'],
      'answer': 2,
      'explanation': '「24時間体制で、休みなく」を意味するround-the-clockがサポートの可用性を表します。'
    },
    {
      'question':
          'The CEO decided to ____ the opening of the new branch due to budget constraints.',
      'options': ['postpone', 'predict', 'prevent', 'permit'],
      'answer': 0,
      'explanation': '「延期する」を意味するpostponeが、予算の制約による開店の遅れを説明するのに適しています。'
    },
    {
      'question':
          'All passengers are reminded to keep their personal ____ with them at all times.',
      'options': ['belongings', 'properties', 'ingredients', 'appliances'],
      'answer': 0,
      'explanation': '「持ち物、所持品」を意味するbelongingsがアナウンスなどで一般的に使われます。'
    },
    {
      'question':
          'The new security policy will ____ effect starting next Monday morning.',
      'options': ['take', 'make', 'give', 'do'],
      'answer': 0,
      'explanation': 'take effectで「（法律や規則が）効力を発する、実施される」という慣用表現です。'
    },
    {
      'question':
          'We need to find a ____ solution to this recurring technical problem.',
      'options': ['permanent', 'preliminary', 'previous', 'partial'],
      'answer': 0,
      'explanation': '「永続的な、恒久的な」という意味のpermanentが、繰り返し起こる問題への対策として適切です。'
    },
    {
      'question':
          "The annual report provides a ____ overview of the company's global operations.",
      'options': ['comprehensive', 'competitive', 'confidential', 'compatible'],
      'answer': 0,
      'explanation':
          '「包括的な、広範囲にわたる」という意味のcomprehensiveが、全体像（overview）の修飾に適しています。'
    },
    {
      'question':
          'Please ____ the attached document for more details regarding the itinerary.',
      'options': ['consult', 'conduct', 'convey', 'convert'],
      'answer': 0,
      'explanation': '「（資料などを）参照する、調べる」という意味のconsultが適切です。'
    },
    {
      'question':
          'The hiring manager is looking for a candidate with ____ experience in international sales.',
      'options': ['substantial', 'suspicious', 'subjective', 'superficial'],
      'answer': 0,
      'explanation': '「かなりの、相当な」という意味のsubstantialが、経験の豊富さを表す際に使われます。'
    },
    {
      'question':
          'The city council has ____ the proposal to build a new community center.',
      'options': ['approved', 'appealed', 'appeared', 'applied'],
      'answer': 0,
      'explanation': '「承認する、認可する」という意味のapprovedが提案（proposal）に対する動詞として適切です。'
    },
    {
      'question':
          'The workshop will help employees ____ their communication skills in professional settings.',
      'options': ['refine', 'repeat', 'restore', 'replace'],
      'answer': 0,
      'explanation': '「（技術などを）磨く、洗練させる」という意味のrefineがスキル向上に適しています。'
    },
    {
      'question':
          "Mr. Kim's ____ to the project was crucial to its successful completion.",
      'options': ['commitment', 'compliance', 'compliment', 'component'],
      'answer': 0,
      'explanation': '「献身、熱心な取り組み」を意味するcommitmentが、プロジェクトの成功要因として適切です。'
    },
    {
      'question':
          'The hotel offers a ____ shuttle service to and from the airport for all guests.',
      'options': ['complimentary', 'mandatory', 'voluntary', 'secondary'],
      'answer': 0,
      'explanation': '「無料の、優待の」という意味のcomplimentaryがサービスの文脈で頻出します。'
    },
    {
      'question':
          'The survey results indicate that customer ____ has improved significantly this year.',
      'options': ['satisfaction', 'calculation', 'preparation', 'obligation'],
      'answer': 0,
      'explanation': '「満足（度）」を意味するsatisfactionが、調査結果（survey results）の内容として適切です。'
    },
    {
      'question':
          'All employees must ____ with the new safety regulations to avoid potential fines.',
      'options': ['comply', 'rely', 'apply', 'supply'],
      'answer': 0,
      'explanation': 'comply withで「（規則や法律に）従う、遵守する」という重要なビジネス表現です。'
    },
    {
      'question':
          'The company is seeking to ____ its operations into the emerging Southeast Asian market.',
      'options': ['expand', 'exceed', 'exert', 'expel'],
      'answer': 0,
      'explanation': '「（事業などを）拡大する、広げる」を意味するexpandがビジネスの成長の文脈に適しています。'
    },
    {
      'question':
          'The ____ of the new office building is expected to be completed by December.',
      'options': ['construction', 'consumption', 'connection', 'conversation'],
      'answer': 0,
      'explanation': '「建設」を意味するconstructionが、建物（building）が完成することの説明として適切です。'
    },
    {
      'question':
          'Please ____ that all lights and electronic devices are turned off before leaving.',
      'options': ['ensure', 'endure', 'enlarge', 'enrich'],
      'answer': 0,
      'explanation': '「〜を確実にする、確認する」という意味のensureが、注意喚起の文脈で使われます。'
    },
    {
      'question':
          'The primary ____ of the meeting is to discuss the budget for the next quarter.',
      'options': ['purpose', 'portion', 'process', 'purchase'],
      'answer': 0,
      'explanation': '「目的」を意味するpurposeが、会議の議題を説明するのに適しています。'
    },
    {
      'question':
          'The maintenance team is currently ____ the faulty ventilation system.',
      'options': ['repairing', 'repeating', 'regarding', 'revealing'],
      'answer': 0,
      'explanation': '「修理する」を意味するrepairingが、故障した（faulty）システムへの対処として適切です。'
    },
    {
      'question':
          'The new social media strategy has proven to be highly ____ in increasing brand awareness.',
      'options': ['effective', 'effort', 'effect', 'efficiently'],
      'answer': 0,
      'explanation': '「効果的な」を意味する形容詞effectiveが、戦略（strategy）の評価として適しています。'
    },
    {
      'question':
          '____ her hard work and dedication, Ms. Sato was promoted to senior manager.',
      'options': ['Due to', 'Regardless of', 'Instead of', 'As for'],
      'answer': 0,
      'explanation': '「〜のために、〜が原因で」という理由を表すDue toが昇進の理由を説明するのに適しています。'
    },
    {
      'question':
          'The guest speaker gave an ____ presentation on the future of renewable energy.',
      'options': ['insightful', 'internal', 'inferior', 'initial'],
      'answer': 0,
      'explanation': '「洞察力のある、非常に有益な」という意味のinsightfulが、プレゼンテーションの評価として適切です。'
    },
  ],
  'grammar': [
    {
      'question':
          'The marketing director is ____ in the new advertising campaign proposed by the agency.',
      'options': ['interest', 'interesting', 'interested', 'interestingly'],
      'answer': 2,
      'explanation':
          'be interested in（〜に興味がある）という形になります。人が主語の場合は、過去分詞形interested（興味を持っている状態）を使います。'
    },
    {
      'question':
          '____ the inclement weather, the outdoor corporate retreat will proceed as scheduled.',
      'options': ['Despite', 'Although', 'Nevertheless', 'Even though'],
      'answer': 0,
      'explanation':
          '空所後のthe inclement weatherは名詞句なので、前置詞のDespite（〜にもかかわらず）が適切です。AlthoughとEven thoughは接続詞なので後ろにS+Vが続きます。'
    },
    {
      'question':
          'Ms. Tanaka ____ for this law firm for over ten years before she was promoted to partner.',
      'options': ['works', 'is working', 'has worked', 'had worked'],
      'answer': 3,
      'explanation': '過去のある時点（was promoted）よりも前の期間を表すため、過去完了形のhad workedが適切です。'
    },
    {
      'question':
          'The final report must ____ to the department head by the end of the business day.',
      'options': ['submit', 'be submitted', 'submitting', 'be submitting'],
      'answer': 1,
      'explanation': '主語のThe final reportは提出される側なので、受動態のbe submittedが適切です。'
    },
    {
      'question':
          'The technician ____ fixed the server issue was highly praised by the IT manager.',
      'options': ['who', 'which', 'whom', 'whose'],
      'answer': 0,
      'explanation':
          '空所の後ろに動詞fixedが続いているため、先行詞The technician（人）を修飾する主格の関係代名詞whoが必要です。'
    },
    {
      'question':
          'The CEO decided to prepare the keynote speech for the annual conference ____.',
      'options': ['he', 'his', 'him', 'himself'],
      'answer': 3,
      'explanation': '「CEO自身で」という意味にするため、再帰代名詞のhimselfを強調として使います。'
    },
    {
      'question':
          'The research team worked ____ to complete the study before the international deadline.',
      'options': ['hard', 'hardly', 'hardness', 'hardest'],
      'answer': 0,
      'explanation':
          '「一生懸命に」という意味の副詞hardが適切です。hardlyは「ほとんど〜ない」という否定の意味になってしまいます。'
    },
    {
      'question':
          'The strategic planning meeting is scheduled to take place ____ Monday morning at 9:00 A.M.',
      'options': ['in', 'at', 'on', 'by'],
      'answer': 2,
      'explanation': '曜日や特定の日付（Monday morning）の前には前置詞onを使います。'
    },
    {
      'question':
          'If I ____ you, I would double-check the financial figures before presenting them.',
      'options': ['am', 'was', 'were', 'been'],
      'answer': 2,
      'explanation':
          '仮定法過去の文（If + 主語 + 過去形, 主語 + would + 原形）です。be動詞は主語に関わらずwereを用いるのが一般的です。'
    },
    {
      'question':
          'The management team suggested ____ the merger until the next fiscal quarter.',
      'options': ['postpone', 'to postpone', 'postponing', 'postponed'],
      'answer': 2,
      'explanation': 'suggestは動名詞（-ing）を目的語に取る動詞です。to不定詞は取りません。'
    },
    {
      'question':
          'It is essential that every employee ____ the new security protocols immediately.',
      'options': ['follow', 'follows', 'followed', 'following'],
      'answer': 0,
      'explanation':
          'essential（不可欠な）などの形容詞に続くthat節内では、動詞は原形（またはshould + 原形）になります（仮定法現在）。'
    },
    {
      'question':
          "This year's quarterly profits are significantly ____ than those of the previous year.",
      'options': ['high', 'higher', 'highest', 'highly'],
      'answer': 1,
      'explanation': '比較対象を表すthanがあるため、比較級のhigherが適切です。'
    },
    {
      'question':
          'We will have the local contractor ____ the air conditioning system in the warehouse.',
      'options': ['repair', 'repairs', 'repaired', 'to repair'],
      'answer': 0,
      'explanation': 'have + 人 + 原形不定詞で「（人）に〜してもらう（使役）」という構造になります。'
    },
    {
      'question':
          'By the time the new manager arrives next week, we ____ the orientation materials.',
      'options': [
        'finish',
        'will finish',
        'will have finished',
        'have finished'
      ],
      'answer': 2,
      'explanation':
          'By the time + 現在形（未来の代用）がある場合、未来のある時点での完了を表す未来完了形（will have finished）を使います。'
    },
    {
      'question':
          'The cost of raw materials has ____ significantly over the past six months.',
      'options': ['rose', 'risen', 'raised', 'raising'],
      'answer': 1,
      'explanation': '「上がる」という自動詞riseの過去分詞形risenが適切です。raiseは「〜を上げる」という他動詞です。'
    },
    {
      'question':
          'Neither the department head ____ the staff members were informed about the office relocation.',
      'options': ['or', 'and', 'nor', 'but'],
      'answer': 2,
      'explanation': 'Neither A nor B（AもBも〜ない）という相関接続詞の定型表現です。'
    },
    {
      'question':
          'Please note that the responsibility for maintaining the office equipment is ____.',
      'options': ['your', 'you', 'yours', 'yourself'],
      'answer': 2,
      'explanation': '「あなたのもの（あなたの責任）」という意味の所有代名詞yoursが必要です。yourは後ろに名詞が必要です。'
    },
    {
      'question':
          'The new headquarters is located conveniently ____ the subway station and the bus terminal.',
      'options': ['among', 'between', 'from', 'against'],
      'answer': 1,
      'explanation':
          'between A and B（AとBの間）という表現が、2つの場所（subway stationとbus terminal）の間に位置することを示します。'
    },
    {
      'question':
          '____ by the sudden drop in stock prices, the investors called for an emergency meeting.',
      'options': ['Surprising', 'Surprise', 'Surprised', 'To surprise'],
      'answer': 2,
      'explanation': '分詞構文です。投資家が「驚かされた」という受動の意味になるため、過去分詞Surprisedで始めます。'
    },
    {
      'question':
          'It was ____ great honor to receive the Employee of the Year award last night.',
      'options': ['a', 'an', 'the', 'any'],
      'answer': 0,
      'explanation':
          'honorは数えられる名詞として扱われ、ここでは「一つの光栄なこと」として不定冠詞aを用います（greatの頭文字が子音のため）。'
    },
    {
      'question':
          'The company purchased new ____ for the laboratory to improve testing efficiency.',
      'options': ['equipments', 'equipment', 'equipping', 'equipped'],
      'answer': 1,
      'explanation': 'equipmentは不可算名詞（数えられない名詞）なので、複数形のsをつけずに用います。'
    },
    {
      'question':
          'The executive assistant is known for organizing international conferences very ____.',
      'options': ['good', 'well', 'best', 'better'],
      'answer': 1,
      'explanation': '動詞organizingを修飾するためには副詞のwellが必要です。goodは形容詞です。'
    },
    {
      'question':
          'The regional office is located in a district ____ several major tech companies are based.',
      'options': ['which', 'where', 'what', 'whose'],
      'answer': 1,
      'explanation': '先行詞a district（場所）を修飾し、後ろに完全な文が続いているため、関係副詞whereが適切です。'
    },
    {
      'question':
          'Mr. Lopez ____ to Europe three times this year to negotiate the distribution contracts.',
      'options': ['goes', 'is going', 'has been', 'was'],
      'answer': 2,
      'explanation': '「今年3回行っている（経験）」を表すため、現在完了形のhas beenが適切です。'
    },
    {
      'question':
          'The primary objective of this seminar is ____ employees on the new software features.',
      'options': ['train', 'to train', 'trained', 'trains'],
      'answer': 1,
      'explanation': '「目的は〜することです」という補語の役割を果たす不定詞to trainが適切です。'
    },
    {
      'question':
          'The public relations officer is responsible ____ handling all media inquiries.',
      'options': ['to', 'with', 'for', 'in'],
      'answer': 2,
      'explanation': 'be responsible for（〜に責任がある、〜を担当している）という重要熟語です。'
    },
    {
      'question':
          'Please remain seated ____ the flight attendant announces that it is safe to move around.',
      'options': ['during', 'until', 'while', 'since'],
      'answer': 1,
      'explanation':
          '「〜までずっと（継続）」という意味の接続詞untilが適切です。duringは前置詞なので後ろにS+Vは置けません。'
    },
    {
      'question':
          'The ultimate ____ of the project depends on the cooperation between all departments.',
      'options': ['succeed', 'success', 'successful', 'successfully'],
      'answer': 1,
      'explanation': '冠詞Theと前置詞ofの間には名詞が必要です。success（成功）が適切です。'
    },
    {
      'question':
          'Employees ____ smoke within 20 meters of the building\'s main entrance.',
      'options': ['must not', 'do not have to', 'might not', 'not'],
      'answer': 0,
      'explanation': '「〜してはいけない（禁止）」という意味のmust notがビジネスルールの文脈で適切です。'
    },
    {
      'question':
          'This is the ____ expensive marketing campaign the company has ever launched.',
      'options': ['more', 'most', 'much', 'mostly'],
      'answer': 1,
      'explanation': 'ever（これまでで）という表現があるため、最上級のthe most expensiveが適切です。'
    },
  ],
  'reading': [
    {
      'question':
          '[Email] Subject: Project Meeting. Dear Team, our meeting scheduled for Tuesday at 2 PM has been moved to Wednesday at 10 AM in Room 302. Please update your calendars. Question: When is the new meeting time?',
      'options': [
        'Tuesday at 2 PM',
        'Tuesday at 10 AM',
        'Wednesday at 2 PM',
        'Wednesday at 10 AM'
      ],
      'answer': 3,
      'explanation': '本文に「moved to Wednesday at 10 AM（水曜の午前10時に変更された）」とあります。'
    },
    {
      'question':
          '[Notice] The office will be closed on Monday, September 4, for the Labor Day holiday. Regular hours will resume on Tuesday. Question: Why will the office be closed?',
      'options': [
        'For maintenance',
        'For a public holiday',
        'For a staff retreat',
        'For a renovation'
      ],
      'answer': 1,
      'explanation': '「for the Labor Day holiday（労働者の日の祝日のため）」と閉鎖の理由が述べられています。'
    },
    {
      'question':
          '[Ad] Graphic Designer wanted. Must have 3+ years of experience and proficiency in Adobe Creative Suite. Send your portfolio to jobs@design.com. Question: What is a requirement for this position?',
      'options': [
        'A degree in marketing',
        'Fluency in Spanish',
        'Experience with Adobe software',
        'Own transportation'
      ],
      'answer': 2,
      'explanation':
          '「proficiency in Adobe Creative Suite（Adobeツールの習熟）」が要件として挙げられています。'
    },
    {
      'question':
          '[Shipping Update] Your order #4552 has been shipped and is expected to arrive within 3-5 business days. Track your package using the link below. Question: How long will the delivery take?',
      'options': ['1-2 days', '3-5 days', '7-10 days', 'Two weeks'],
      'answer': 1,
      'explanation':
          '「arrive within 3-5 business days（3〜5営業日以内に到着予定）」と記載されています。'
    },
    {
      'question':
          '[Memo] To reduce electricity costs, all employees are requested to turn off their computer monitors and office lights before leaving. Question: What is the purpose of this memo?',
      'options': [
        'To improve security',
        'To save energy',
        'To update software',
        'To clean the office'
      ],
      'answer': 1,
      'explanation':
          '「To reduce electricity costs（電気代を削減するため）」、つまり省エネ（save energy）が目的です。'
    },
    {
      'question':
          '[Product Info] The X-2000 vacuum cleaner comes with a 2-year warranty covering all parts and labor. Return it within 30 days for a full refund. Question: How long is the warranty period?',
      'options': ['30 days', '1 year', '2 years', '5 years'],
      'answer': 2,
      'explanation': '「a 2-year warranty（2年間の保証）」と明記されています。'
    },
    {
      'question':
          '[Business News] Global Tech Corp announced it will acquire StartUp Inc for \$50 million to expand its cloud computing services. Question: What is the goal of the acquisition?',
      'options': [
        'To hire more staff',
        'To lower prices',
        'To expand services',
        'To close a branch'
      ],
      'answer': 2,
      'explanation':
          '「to expand its cloud computing services（クラウドサービスを拡大するため）」と目的が書かれています。'
    },
    {
      'question':
          '[Conference Schedule] 9:00 AM: Registration; 10:00 AM: Keynote by Dr. Aris; 11:30 AM: Workshop. Question: What happens at 10:00 AM?',
      'options': [
        'Registration begins',
        'Lunch break',
        'A workshop',
        'A keynote speech'
      ],
      'answer': 3,
      'explanation': '「10:00 AM: Keynote（基調講演）」とスケジュールにあります。'
    },
    {
      'question':
          '[Store Hours] Monday-Friday: 9 AM - 9 PM. Saturday: 10 AM - 6 PM. Sunday: Closed. Question: When does the store close on Saturdays?',
      'options': ['6 PM', '9 PM', '10 AM', 'It is closed'],
      'answer': 0,
      'explanation': '「Saturday: 10 AM - 6 PM」より、閉店時間は午後6時です。'
    },
    {
      'question':
          '[Email] Hi Sarah, I\'ve attached the invoice for the last shipment. Please process the payment by Friday. Thanks, Mark. Question: What did Mark send to Sarah?',
      'options': [
        'A shipping label',
        'A payment check',
        'A billing document',
        'A product catalog'
      ],
      'answer': 2,
      'explanation':
          '「attached the invoice（請求書を添付した）」とあります。invoiceはbilling document（請求書類）の一種です。'
    },
    {
      'question':
          '[Notice] All visitors must sign in at the front desk and wear a visitor\'s badge at all times while in the building. Question: What are visitors required to do?',
      'options': [
        'Make an appointment',
        'Register at the desk',
        'Wait in the car',
        'Show a passport'
      ],
      'answer': 1,
      'explanation': '「sign in at the front desk（受付で署名する／記帳する）」という指示があります。'
    },
    {
      'question':
          '[Ad] Special Offer: Book your flight by the end of the month and get a 20% discount on all international routes. Question: How can a customer get a discount?',
      'options': [
        'By flying locally',
        'By booking early',
        'By joining a club',
        'By traveling in a group'
      ],
      'answer': 1,
      'explanation':
          '「Book... by the end of the month（今月末までに予約する）」という期限内の予約（早めの予約）が条件です。'
    },
    {
      'question':
          '[Memo] Starting next month, we will implement a new flexible work policy allowing staff to work from home two days a week. Question: What change is being announced?',
      'options': [
        'A pay raise',
        'A new office location',
        'Remote work options',
        'A longer lunch break'
      ],
      'answer': 2,
      'explanation': '「work from home（在宅勤務）」、つまりリモートワークの選択肢について述べています。'
    },
    {
      'question':
          '[Review] The food at Bistro 5 was excellent, but the service was quite slow. We waited 40 minutes for our main course. Question: What did the reviewer dislike?',
      'options': [
        'The food quality',
        'The prices',
        'The location',
        'The waiting time'
      ],
      'answer': 3,
      'explanation':
          '「service was quite slow（サービスがかなり遅かった）」と待ち時間（waiting time）に不満を示しています。'
    },
    {
      'question':
          '[Itinerary] Flight BA202 departs London at 8:00 AM and arrives in New York at 11:00 AM local time. Question: Where is the flight\'s destination?',
      'options': ['London', 'New York', 'Paris', 'Tokyo'],
      'answer': 1,
      'explanation': '「arrives in New York（ニューヨークに到着する）」とあるので、目的地はニューヨークです。'
    },
    {
      'question':
          '[Policy] Employees are entitled to 15 days of paid vacation per year after completing one year of service. Question: When can an employee take 15 days of vacation?',
      'options': [
        'Immediately',
        'After six months',
        'After one year',
        'After two years'
      ],
      'answer': 2,
      'explanation':
          '「after completing one year of service（1年間の勤務を終えた後）」と条件が示されています。'
    },
    {
      'question':
          '[Sign] Caution: Wet Floor. Please use the alternative entrance near the cafeteria. Question: Where should people enter?',
      'options': [
        'Through the main door',
        'Near the cafeteria',
        'Through the garage',
        'The back gate'
      ],
      'answer': 1,
      'explanation':
          '「use the alternative entrance near the cafeteria（カフェテリア近くの別の入口を使ってください）」と指示されています。'
    },
    {
      'question':
          '[Email] Dear Customer, your subscription to Finance Monthly will expire on Oct 31. Renew now to avoid interruption. Question: What is the purpose of the email?',
      'options': [
        'To offer a job',
        'To confirm an order',
        'To remind about a deadline',
        'To announce a sale'
      ],
      'answer': 2,
      'explanation': '購読期限（expire on Oct 31）が近づいていることを知らせ、更新を促すリマインドメールです。'
    },
    {
      'question':
          '[Press Release] Green Energy Ltd will open a new manufacturing plant in Ohio, creating 200 local jobs. Question: What will happen in Ohio?',
      'options': [
        'A factory will close',
        'A new facility will open',
        'A protest will occur',
        'A school will be built'
      ],
      'answer': 1,
      'explanation':
          '「open a new manufacturing plant（新しい製造工場を開く）」、つまり新施設（facility）の開設です。'
    },
    {
      'question':
          '[Meeting Minutes] Mr. Kim suggested upgrading the server. The board approved the motion and allocated \$10,000 for the project. Question: What did the board agree to do?',
      'options': [
        'Hire Mr. Kim',
        'Spend money on a server',
        'Cancel the project',
        'Move the office'
      ],
      'answer': 1,
      'explanation':
          'サーバーのアップグレードに1万ドルを割り当てた（allocated \$10,000）ことから、費用をかけることに合意したと分かります。'
    },
    {
      'question':
          '[Webpage] Register for our newsletter and receive a coupon for \$10 off your first purchase over \$50. Question: How much must a customer spend to use the coupon?',
      'options': ['\$10', '\$40', '\$50', '\$60'],
      'answer': 2,
      'explanation': '「purchase over \$50（50ドル以上の購入）」がクーポン使用の条件です。'
    },
    {
      'question':
          '[Letter] Dear Mr. Lee, we are pleased to inform you that your application for the loan has been approved. Question: What is the subject of this letter?',
      'options': [
        'A job offer',
        'A bank loan',
        'A tax return',
        'A rental agreement'
      ],
      'answer': 1,
      'explanation':
          '「application for the loan has been approved（ローンの申請が承認された）」とあります。'
    },
    {
      'question':
          '[Safety Rule] Protective eyewear must be worn at all times while operating the drilling machinery. Question: Who is this rule for?',
      'options': [
        'Office clerks',
        'Machine operators',
        'Delivery drivers',
        'Sales representatives'
      ],
      'answer': 1,
      'explanation':
          '「while operating the drilling machinery（掘削機を操作する間）」という記述から、機械の作業者が対象です。'
    },
    {
      'question':
          '[Ad] Fresh Organic Produce. Locally grown. Open daily from 8 AM to sunset. Located on Highway 12. Question: Where is the market located?',
      'options': [
        'In a shopping mall',
        'On Highway 12',
        'Near the airport',
        'Downtown'
      ],
      'answer': 1,
      'explanation': '「Located on Highway 12」と場所が明記されています。'
    },
    {
      'question':
          '[Notice] Due to a broken water pipe, the restrooms on the second floor are temporarily out of order. Please use those on the third floor. Question: Which facilities are unavailable?',
      'options': [
        'The elevators',
        'The cafeteria',
        'The restrooms',
        'The parking lot'
      ],
      'answer': 2,
      'explanation':
          '「restrooms... are temporarily out of order（トイレは一時的に使用不可）」とあります。'
    },
    {
      'question':
          '[Email] Thank you for your interest in the position. We would like to invite you for an interview this Thursday at 11 AM. Question: What is the sender doing?',
      'options': [
        'Asking for a refund',
        'Scheduling an interview',
        'Rejecting a candidate',
        'Providing a reference'
      ],
      'answer': 1,
      'explanation': '「invite you for an interview（面接に招待する）」と、面接の予定を立てようとしています。'
    },
    {
      'question':
          '[Memo] Staff are reminded that personal phone calls should be kept to a minimum during working hours. Question: What does the memo ask staff to do?',
      'options': [
        'Work more hours',
        'Buy new phones',
        'Limit personal calls',
        'Call more customers'
      ],
      'answer': 2,
      'explanation':
          '「personal phone calls should be kept to a minimum（私用電話は最小限に抑えるべき）」と指示しています。'
    },
    {
      'question':
          '[Contract] This agreement shall remain in effect for a period of three years from the date of signing. Question: How long is the contract valid?',
      'options': ['One year', 'Two years', 'Three years', 'Five years'],
      'answer': 2,
      'explanation': '「for a period of three years（3年間）」と有効期間が記されています。'
    },
    {
      'question':
          '[Announcement] We are happy to welcome Jane Smith as our new Marketing Director. She previously worked at Media Solutions for 10 years. Question: Where did Jane Smith work before?',
      'options': [
        'At a school',
        'At Media Solutions',
        'In the government',
        'At a bank'
      ],
      'answer': 1,
      'explanation':
          '「previously worked at Media Solutions（以前はMedia Solutionsで働いていた）」とあります。'
    },
    {
      'question':
          '[Airport Sign] Flight AF44 is delayed. New departure time: 4:30 PM. Please check the monitors for gate information. Question: What is the status of Flight AF44?',
      'options': ['Canceled', 'On time', 'Delayed', 'Landed'],
      'answer': 2,
      'explanation': '「Flight AF44 is delayed（AF44便は遅れている）」と明記されています。'
    },
  ],
};
const BADGES = [
  {'id': 1, 'name': 'First Step', 'icon': '⭐', 'need': 1},
  {'id': 2, 'name': '5 Tasks', 'icon': '⭐⭐', 'need': 5},
  {'id': 3, 'name': '10 Tasks', 'icon': '⭐⭐⭐', 'need': 10},
  {'id': 4, 'name': 'Halfway', 'icon': '⭐⭐⭐⭐', 'need': -1},
  {'id': 5, 'name': 'Complete', 'icon': '⭐⭐⭐⭐⭐', 'need': -2},
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumo TOEIC',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

// スプラッシュ画面（データ読み込み）
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkData();
  }

  Future<void> _checkData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('default_user')
          .get();
      if (!mounted) return;

      if (doc.exists && doc.data()?['hasData'] == true) {
        final data = doc.data()!;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MountainPathScreen(
              examDate: DateTime.parse(data['examDate']),
              personality: Map<String, String>.from(data['personality'] ?? {}),
              level: data['level'] ?? 'beginner',
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const LevelDiagnosisWelcome()));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LevelDiagnosisWelcome()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// レベル診断Welcome画面
class LevelDiagnosisWelcome extends StatelessWidget {
  const LevelDiagnosisWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('まず実力チェックをしよう',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 16),
                  const Text('あなたのレベルに合った学習プランを作成するため、簡単な問題を出します。全8問です。',
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LevelDiagnosisQuiz())),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58CC02),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14)),
                    child: const Text('診断を始める',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// レベル診断Quiz画面
class LevelDiagnosisQuiz extends StatefulWidget {
  const LevelDiagnosisQuiz({super.key});
  @override
  State<LevelDiagnosisQuiz> createState() => _LevelDiagnosisQuizState();
}

class _LevelDiagnosisQuizState extends State<LevelDiagnosisQuiz> {
  List<Map<String, dynamic>> questions = [];
  List<bool> answers = [];
  int currentIndex = 0;
  int? selected;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    // 各レベルから2問ずつ
    final levels = [
      {
        'name': '300',
        'questions': [
          {
            'q': 'I ___ a student.',
            'opts': ['am', 'is', 'are', 'be'],
            'ans': 0
          },
          {
            'q': 'She ___ to school every day.',
            'opts': ['go', 'goes', 'going', 'gone'],
            'ans': 1
          },
        ]
      },
      {
        'name': '600',
        'questions': [
          {
            'q': 'If I ___ rich, I would travel the world.',
            'opts': ['am', 'was', 'were', 'be'],
            'ans': 2
          },
          {
            'q': 'The meeting ___ at 3 PM yesterday.',
            'opts': ['starts', 'started', 'will start', 'has started'],
            'ans': 1
          },
        ]
      },
      {
        'name': '800',
        'questions': [
          {
            'q': 'By the time you arrive, I ___ the report.',
            'opts': ['finish', 'finished', 'will finish', 'will have finished'],
            'ans': 3
          },
          {
            'q': '___ the circumstances, we decided to proceed.',
            'opts': ['Despite', 'Although', 'However', 'Because'],
            'ans': 0
          },
        ]
      },
      {
        'name': '900',
        'questions': [
          {
            'q': 'The proposal was met with ___ from the board.',
            'opts': ['skeptical', 'skepticism', 'skeptically', 'skeptic'],
            'ans': 1
          },
          {
            'q': 'Had I known, I ___ differently.',
            'opts': ['act', 'acted', 'would act', 'would have acted'],
            'ans': 3
          },
        ]
      },
    ];
    for (var level in levels) {
      for (var q in (level['questions'] as List)) {
        questions.add({
          'question': q['q'],
          'options': q['opts'],
          'answer': q['ans'],
          'levelName': level['name']
        });
      }
    }
  }

  void handleAnswer() {
    if (selected == null) return;
    final isCorrect = selected == questions[currentIndex]['answer'];
    setState(() {
      showAnswer = true;
      answers.add(isCorrect);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          selected = null;
          showAnswer = false;
        });
      } else {
        final correctCount = answers.where((a) => a).length;
        final level = correctCount >= 7
            ? 'advanced'
            : correctCount >= 4
                ? 'intermediate'
                : 'beginner';
        final scoreLabel = correctCount >= 7
            ? '800-900点レベル'
            : correctCount >= 4
                ? '600-800点レベル'
                : '300-600点レベル';
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LevelDiagnosisResult(
                    level: level, scoreLabel: scoreLabel)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIndex];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text('実力チェック',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text('問題 ${currentIndex + 1} / ${questions.length}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54)),
                  const SizedBox(height: 12),
                  Text(q['question'],
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black87)),
                  const SizedBox(height: 16),
                  ...List.generate(q['options'].length, (idx) {
                    return GestureDetector(
                      onTap: showAnswer
                          ? null
                          : () => setState(() => selected = idx),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: selected == idx
                                  ? const Color(0xFF58CC02)
                                  : Colors.grey.shade300,
                              width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: showAnswer
                              ? (idx == q['answer']
                                  ? Colors.green.shade50
                                  : selected == idx
                                      ? Colors.red.shade50
                                      : Colors.white)
                              : selected == idx
                                  ? Colors.grey.shade100
                                  : Colors.white,
                        ),
                        child: Text(q['options'][idx],
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87)),
                      ),
                    );
                  }),
                  if (showAnswer)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: selected == q['answer']
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(selected == q['answer'] ? '正解' : '不正解',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        (selected == null || showAnswer) ? null : handleAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (selected == null || showAnswer)
                          ? Colors.grey
                          : const Color(0xFF58CC02),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('回答する',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// レベル診断Result画面
class LevelDiagnosisResult extends StatelessWidget {
  final String level;
  final String scoreLabel;
  const LevelDiagnosisResult(
      {super.key, required this.level, required this.scoreLabel});

  @override
  Widget build(BuildContext context) {
    final labels = {'beginner': '初級', 'intermediate': '中級', 'advanced': '上級'};
    final colors = {
      'beginner': Colors.blue,
      'intermediate': Colors.orange,
      'advanced': Colors.purple
    };
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('診断結果',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 16),
                  Text(scoreLabel,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colors[level])),
                  const SizedBox(height: 8),
                  Text(labels[level]!,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PersonalityTest(level: level))),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58CC02),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14)),
                    child: const Text('次へ',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 性格診断
class PersonalityTest extends StatefulWidget {
  final String level;
  const PersonalityTest({super.key, required this.level});
  @override
  State<PersonalityTest> createState() => _PersonalityTestState();
}

class _PersonalityTestState extends State<PersonalityTest> {
  int currentQuestion = 0;
  final Map<String, String> answers = {};
  final List<Map<String, dynamic>> questions = [
    {
      'q': '毎日決まった時間に勉強できる？',
      'opts': ['できる', 'できない'],
      'key': 'routine'
    },
    {
      'q': '一度に長時間集中できる？',
      'opts': ['できる', 'できない'],
      'key': 'focus'
    },
    {
      'q': 'ゲーム感覚で学ぶのが好き？',
      'opts': ['好き', '苦手'],
      'key': 'gamified'
    },
  ];

  void handleAnswer(String answer) {
    setState(() {
      answers[questions[currentQuestion]['key']] = answer;
      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ExamDateInput(personality: answers, level: widget.level)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestion];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('質問 ${currentQuestion + 1} / ${questions.length}',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 16),
                  Text(q['q'],
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 24),
                  ...q['opts'].map<Widget>((opt) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => handleAnswer(opt),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF58CC02),
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text(opt,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 受験日入力
class ExamDateInput extends StatefulWidget {
  final Map<String, String> personality;
  final String level;
  const ExamDateInput(
      {super.key, required this.personality, required this.level});
  @override
  State<ExamDateInput> createState() => _ExamDateInputState();
}

class _ExamDateInputState extends State<ExamDateInput> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int selectedDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('TOEIC受験日を選択',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDropdown(
                      value: selectedYear,
                      items: List.generate(3, (i) => DateTime.now().year + i),
                      onChanged: (val) => setState(() => selectedYear = val!),
                      suffix: '年'),
                  const SizedBox(width: 16),
                  _buildDropdown(
                      value: selectedMonth,
                      items: List.generate(12, (i) => i + 1),
                      onChanged: (val) => setState(() => selectedMonth = val!),
                      suffix: '月'),
                  const SizedBox(width: 16),
                  _buildDropdown(
                      value: selectedDay,
                      items: List.generate(31, (i) => i + 1),
                      onChanged: (val) => setState(() => selectedDay = val!),
                      suffix: '日'),
                ],
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  final examDate =
                      DateTime(selectedYear, selectedMonth, selectedDay);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MountainPathScreen(
                              examDate: examDate,
                              personality: widget.personality,
                              level: widget.level)));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16)),
                child: const Text('冒険を開始！', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      {required int value,
      required List<int> items,
      required ValueChanged<int?> onChanged,
      required String suffix}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButton<int>(
          value: value,
          underline: const SizedBox(),
          items: items
              .map((int value) => DropdownMenuItem<int>(
                  value: value, child: Text('$value$suffix')))
              .toList(),
          onChanged: onChanged),
    );
  }
}

// 山道画面（メイン）
class MountainPathScreen extends StatefulWidget {
  final DateTime examDate;
  final Map<String, String> personality;
  final String level;
  const MountainPathScreen(
      {super.key,
      required this.examDate,
      required this.personality,
      required this.level});
  @override
  State<MountainPathScreen> createState() => _MountainPathScreenState();
}

List<int> shownBadgeIds = [];
int? popBadgeId;

class _MountainPathScreenState extends State<MountainPathScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = 'default_user';
  List<Map<String, dynamic>> tasks = [];
  List<bool> tasksCompleted = [];
  List<bool> tasksExpanded = [];
  int currentStreak = 0;
  DateTime? lastCompletedDate;
  int completedCount = 0;
  Map<String, Map<String, int>> quizStats = {
    'vocabulary': {'correct': 0, 'total': 0},
    'grammar': {'correct': 0, 'total': 0},
    'reading': {'correct': 0, 'total': 0},
  };
  int todayCompleted = 0;
  int weekCompleted = 0;
  int monthCompleted = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () async {
      await _loadData();
      if (tasks.isEmpty) {
        await _generateAISchedule();
      }
    });
  }

  Future<void> _generateAISchedule() async {
    try {
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      print('API Key loaded: ${apiKey.substring(0, 10)}');
      final diffDays = widget.examDate.difference(DateTime.now()).inDays;
      final level = widget.level;

      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'user',
              'content': '''
TOEICの学習スケジュールを作成してください。
レベル: $level
残り日数: $diffDays日
タスク数: ${diffDays > 30 ? 30 : diffDays}個

以下のJSON形式で返してください:
{"tasks": [{"task": "タスク名", "reason": "理由"}]}

タスク名は「単語学習」「文法練習」「リーディング演習」などを含めてください。
JSONのみ返してください。
'''
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'] as String;
        final cleanText =
            text.replaceAll('```json', '').replaceAll('```', '').trim();
        final parsed = jsonDecode(cleanText);
        final taskList = parsed['tasks'] as List;
        setState(() {
          tasks = taskList
              .map((t) => {
                    'task': t['task'] as String,
                    'reason': t['reason'] as String,
                  })
              .toList();
          tasksCompleted = List<bool>.filled(tasks.length, false);
          tasksExpanded = List<bool>.filled(tasks.length, false);
        });
        await _saveData();
      } else {
        print('AI schedule error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('AI schedule error: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'hasData': true,
        'examDate': widget.examDate.toIso8601String(),
        'personality': widget.personality,
        'level': widget.level,
        'completedCount': completedCount,
        'tasksCompleted': tasksCompleted,
        'shownBadgeIds': shownBadgeIds,
        'currentStreak': currentStreak,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
        'quizStats': quizStats,
      });

      // 週間ランキング用
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekKey =
          '${weekStart.year}-W${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';

      await _firestore.collection('leaderboard').doc(userId).set({
        'weekKey': weekKey,
        'completedCount': completedCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Save error: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        if (data != null && data['tasksCompleted'] != null) {
          setState(() {
            final completed = List<bool>.from(data['tasksCompleted']);
            for (int i = 0; i < tasks.length && i < completed.length; i++) {
              tasksCompleted[i] = completed[i];
            }
            completedCount = tasksCompleted.where((t) => t).length;
            shownBadgeIds = List<int>.from(data['shownBadgeIds'] ?? []);
            currentStreak = data['currentStreak'] ?? 0;
            lastCompletedDate = data['lastCompletedDate'] != null
                ? DateTime.parse(data['lastCompletedDate'])
                : null;
            if (data['quizStats'] != null) {
              final stats = Map<String, dynamic>.from(data['quizStats']);
              quizStats = {
                'vocabulary': Map<String, int>.from(
                    stats['vocabulary'] ?? {'correct': 0, 'total': 0}),
                'grammar': Map<String, int>.from(
                    stats['grammar'] ?? {'correct': 0, 'total': 0}),
                'reading': Map<String, int>.from(
                    stats['reading'] ?? {'correct': 0, 'total': 0}),
              };
            }
          });
          _calculateProgress();
        }
      }
    } catch (e) {
      print('Load error: $e');
    }
  }

  void checkNewBadges() {
    final progress =
        tasks.isEmpty ? 0 : (completedCount / tasks.length * 100).round();

    for (var badge in BADGES) {
      final need = badge['need'] as int;
      final badgeId = badge['id'] as int;

      bool earned = false;
      if (need == -1) {
        earned = progress >= 50;
      } else if (need == -2)
        earned = progress == 100;
      else
        earned = completedCount >= need;

      if (earned && !shownBadgeIds.contains(badgeId)) {
        setState(() {
          shownBadgeIds.add(badgeId);
        });
        _saveData();
        // 直接showDialogを呼ぶ
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => BadgePopup(
                name: badge['name'] as String,
                icon: badge['icon'] as String,
              ),
            );
          }
        });
        break;
      }
    }
  }

  void toggleComplete(int i) {
    if (tasksCompleted[i]) return;

    final task = tasks[i]['task'].toString().toLowerCase();
    String category = 'vocabulary';
    if (task.contains('文法') || task.contains('grammar')) {
      category = 'grammar';
    } else if (task.contains('読解') ||
        task.contains('リーディング') ||
        task.contains('reading')) {
      category = 'reading';
    }

    showDialog(
      context: context,
      builder: (context) => QuizModal(
        category: category,
        onComplete: (success, cat) {
          if (success) {
            // 正解率を記録
            quizStats[cat]!['total'] = (quizStats[cat]!['total'] ?? 0) + 1;
            quizStats[cat]!['correct'] = (quizStats[cat]!['correct'] ?? 0) + 1;

            setState(() {
              tasksCompleted[i] = true;
              completedCount = tasksCompleted.where((t) => t).length;
              _updateStreak();
              _calculateProgress();
            });
            print('completedCount: $completedCount');
            print('shownBadgeIds: $shownBadgeIds');
            _saveData();
            checkNewBadges();
          } else {
            // 不正解も記録
            quizStats[cat]!['total'] = (quizStats[cat]!['total'] ?? 0) + 1;
            _saveData();
          }
        },
      ),
    );
  }

  void _updateStreak() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (lastCompletedDate == null) {
      // 初回
      currentStreak = 1;
      lastCompletedDate = todayDate;
    } else {
      final lastDate = DateTime(
        lastCompletedDate!.year,
        lastCompletedDate!.month,
        lastCompletedDate!.day,
      );
      final diff = todayDate.difference(lastDate).inDays;

      if (diff == 0) {
        // 今日既に完了済み（何もしない）
      } else if (diff == 1) {
        // 連続
        currentStreak++;
        lastCompletedDate = todayDate;
      } else {
        // 途切れた
        currentStreak = 1;
        lastCompletedDate = todayDate;
      }
    }
  }

  void _calculateProgress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    todayCompleted = 0;
    weekCompleted = 0;
    monthCompleted = 0;

    // 今日・今週・今月のタスク完了数をカウント
    // 注: 今は全タスクを見てるが、後で日付別に分けるべき
    for (int i = 0; i < tasks.length && i < tasksCompleted.length; i++) {
      if (tasksCompleted[i]) {
        todayCompleted++;
        weekCompleted++;
        monthCompleted++;
      }
    }
  }

  Widget _buildCategoryButton(String label, String category, int count) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // カテゴリ選択を閉じる
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizSessionScreen(
              category: category,
              questionCount: count,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              '$count問',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        tasks.isEmpty ? 0 : (completedCount / tasks.length * 100).round();

    // バッジポップアップ
    if (popBadgeId != null) {
      final badge = BADGES.firstWhere((b) => b['id'] == popBadgeId);
      Future.microtask(() {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => BadgePopup(
            name: badge['name'] as String,
            icon: badge['icon'] as String,
          ),
        );
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFF5DADE2),
            Color(0xFF85C1E9),
            Color(0xFFAED6F1),
            Color(0xFFD5F5E3),
            Color(0xFF7DCEA0)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text('Lumo',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        if (currentStreak > 0) ...[
                          const Icon(Icons.local_fire_department,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 4),
                          Text('$currentStreak日連続',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                        ],
                        Text('$completedCount タスク完了',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.leaderboard,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LeaderboardScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh,
                              color: Colors.white, size: 20),
                          onPressed: () async {
                            await _firestore
                                .collection('users')
                                .doc(userId)
                                .delete();
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SplashScreen()));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('進捗',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        Text('$progress%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress / 100,
                        child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFF58CC02),
                                borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
// 達成率表示
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('今日',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('$todayCompleted/${tasks.length}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333))),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('今週',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('$weekCompleted/${tasks.length}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333))),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('今月',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('$monthCompleted/${tasks.length} ',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 今すぐ1問ボタン
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'カテゴリを選択',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333)),
                            ),
                            const SizedBox(height: 20),
                            _buildCategoryButton('単語', 'vocabulary', 5),
                            const SizedBox(height: 12),
                            _buildCategoryButton('文法', 'grammar', 2),
                            const SizedBox(height: 12),
                            _buildCategoryButton('読解', 'reading', 2),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.flash_on, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        '今すぐ1問',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Task list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    final task = tasks[i];
                    final done = tasksCompleted[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => toggleComplete(i),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done
                                    ? const Color(0xFF58CC02)
                                    : Colors.white,
                                border: Border.all(
                                    color: done
                                        ? const Color(0xFF58CC02)
                                        : Colors.grey.shade400,
                                    width: 3),
                              ),
                              child: Center(
                                child: done
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 20)
                                    : Text('${i + 1}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    done ? Colors.green.shade50 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2))
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['task'],
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            done ? Colors.grey : Colors.black87,
                                        decoration: done
                                            ? TextDecoration.lineThrough
                                            : null),
                                  ),
                                  if (task['reason'] != null &&
                                      task['reason'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          tasksExpanded[i] = !tasksExpanded[i];
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.lightbulb_outline,
                                              size: 14,
                                              color: Color(0xFFF39C12)),
                                          const SizedBox(width: 4),
                                          Text(
                                            tasksExpanded[i]
                                                ? '理由を隠す'
                                                : '理由を見る',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFFF39C12)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (tasksExpanded[i])
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          task['reason'],
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black54),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// クイズモーダル
class QuizModal extends StatefulWidget {
  final String category;
  final Function(bool success, String category) onComplete;
  const QuizModal(
      {super.key, required this.category, required this.onComplete});
  @override
  State<QuizModal> createState() => _QuizModalState();
}

class _QuizModalState extends State<QuizModal> {
  late Map<String, dynamic> question;
  int? selected;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    final questions =
        QUIZ_QUESTIONS[widget.category] ?? QUIZ_QUESTIONS['vocabulary']!;
    final list = (questions as List);
    question = list[math.Random().nextInt(list.length)];
  }

  void handleAnswer() {
    if (selected == null) return;
    setState(() => showAnswer = true);
    if (selected == question['answer']) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        widget.onComplete(true, widget.category);
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(question['question'],
                style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 16),
            ...List.generate((question['options'] as List).length, (idx) {
              return GestureDetector(
                onTap: showAnswer ? null : () => setState(() => selected = idx),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: selected == idx
                            ? const Color(0xFF58CC02)
                            : Colors.grey.shade300,
                        width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: showAnswer
                        ? (idx == question['answer']
                            ? Colors.green.shade50
                            : selected == idx
                                ? Colors.red.shade50
                                : Colors.white)
                        : selected == idx
                            ? Colors.grey.shade100
                            : Colors.white,
                  ),
                  child: Text((question['options'] as List)[idx],
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87)),
                ),
              );
            }),
            if (showAnswer)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: selected == question['answer']
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Text(selected == question['answer'] ? '正解！' : '不正解',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(question['explanation'],
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (selected == null || showAnswer) ? null : handleAnswer,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: (selected == null || showAnswer)
                            ? Colors.grey
                            : const Color(0xFF58CC02)),
                    child: const Text('回答する',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onComplete(true, widget.category);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600),
                    child: const Text('スキップ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuizSessionScreen extends StatefulWidget {
  final String category;
  final int questionCount;

  const QuizSessionScreen({
    super.key,
    required this.category,
    required this.questionCount,
  });

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  int currentIndex = 0;
  int correctCount = 0;
  List<Map<String, dynamic>> questions = [];
  int? selectedOption;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    final allQuestions = QUIZ_QUESTIONS[widget.category] as List;
    final shuffled = allQuestions.toList();
    shuffled.shuffle();
    questions = shuffled
        .take(widget.questionCount)
        .toList()
        .cast<Map<String, dynamic>>();
  }

  void _nextQuestion(bool isCorrect) {
    if (isCorrect) correctCount++;

    if (currentIndex + 1 >= questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            category: widget.category,
            total: questions.length,
            correct: correctCount,
          ),
        ),
      );
    } else {
      setState(() {
        currentIndex++;
        selectedOption = null;
        showResult = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final question = questions[currentIndex];
    final options = List<String>.from(question['options']);
    final correctAnswer = question['answer'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('${currentIndex + 1} / ${questions.length}'),
        backgroundColor: const Color(0xFF5DADE2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question['question'],
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)),
            ),
            const SizedBox(height: 30),
            ...List.generate(options.length, (i) {
              final isSelected = selectedOption == i;
              final isCorrect = i == correctAnswer;
              Color? bgColor;
              if (showResult) {
                if (isCorrect)
                  bgColor = Colors.green.shade100;
                else if (isSelected) bgColor = Colors.red.shade100;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: showResult
                      ? null
                      : () {
                          setState(() {
                            selectedOption = i;
                          });
                        },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor ??
                          (isSelected ? Colors.blue.shade50 : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF5DADE2)
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      options[i],
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF333333)),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            if (!showResult && selectedOption != null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showResult = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5DADE2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('回答する',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            if (showResult)
              Column(
                children: [
                  Text(
                    selectedOption == correctAnswer ? '正解！' : '不正解...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: selectedOption == correctAnswer
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      _nextQuestion(selectedOption == correctAnswer);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5DADE2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      currentIndex + 1 >= questions.length ? '結果を見る' : '次へ',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// クイズリザルト画面
class QuizResultScreen extends StatelessWidget {
  final String category;
  final int total;
  final int correct;

  const QuizResultScreen({
    super.key,
    required this.category,
    required this.total,
    required this.correct,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (correct / total * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('結果'),
        backgroundColor: const Color(0xFF5DADE2),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$total問中$correct問正解！',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)),
            ),
            const SizedBox(height: 20),
            Text(
              '正解率: $percentage%',
              style: const TextStyle(fontSize: 24, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('やめる', style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizSessionScreen(
                          category: category,
                          questionCount: total,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5DADE2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('もう1セット！',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// バッジポップアップ
class BadgePopup extends StatelessWidget {
  final String name;
  final String icon;
  const BadgePopup({super.key, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (context.mounted) Navigator.pop(context);
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFFF9E6), Color(0xFFFFF3CC)]),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 40)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('BADGE UNLOCKED',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB8860B),
                    letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(icon, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 10),
            Text(name,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekKey =
        '${weekStart.year}-W${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('週間ランキング'),
        backgroundColor: const Color(0xFF5DADE2),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leaderboard')
            .where('weekKey', isEqualTo: weekKey)
            .orderBy('completedCount', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final count = data['completedCount'] ?? 0;
              final rank = i + 1;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rank <= 3 ? Colors.amber : Colors.grey,
                    child: Text('$rank',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text('匿名ユーザー #${docs[i].id.substring(0, 8)}'),
                  trailing: Text('$count タスク',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
