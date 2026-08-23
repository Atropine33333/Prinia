import 'package:flutter/material.dart';

/// 精选图标目录：带中文关键词，供自定义标签挑选。
///
/// 只收录静态引用的图标 —— Flutter 构建时会做图标摇树（tree-shake），
/// 未被引用的字形不会进入安装包，因此体积几乎不受影响。
class AppIcon {
  final IconData data;
  final String keywords; // 中文/英文关键词，空格分隔
  const AppIcon(this.data, this.keywords);
}

/// 猫猫头（Fluent SVG 资产）的特殊码点。
/// 存入数据库的 icon_code == kCatCodePoint 时渲染猫猫 SVG。
const int kCatCodePoint = -1;

const appIconCatalog = <AppIcon>[
  // ── 宠物 ──
  AppIcon(Icons.pets, '宠物 猫 狗 爪子 pet paw'),
  // ── 餐饮 ──
  AppIcon(Icons.restaurant, '吃饭 餐厅 饭 restaurant 餐饮'),
  AppIcon(Icons.local_cafe, '咖啡 奶茶 咖啡馆 cafe coffee'),
  AppIcon(Icons.fastfood, '快餐 汉堡 炸鸡 fastfood'),
  AppIcon(Icons.ramen_dining, '拉面 面条 米线 noodle ramen'),
  AppIcon(Icons.lunch_dining, '午饭 汉堡 burger lunch'),
  AppIcon(Icons.free_breakfast, '早餐 早饭 breakfast'),
  AppIcon(Icons.bakery_dining, '面包 甜品 烘焙 bakery'),
  AppIcon(Icons.icecream, '冰淇淋 冰激凌 icecream'),
  AppIcon(Icons.cake, '蛋糕 生日 cake'),
  AppIcon(Icons.local_pizza, '披萨 pizza'),
  AppIcon(Icons.rice_bowl, '米饭 米饭碗 rice'),
  AppIcon(Icons.egg, '鸡蛋 蛋 egg'),
  AppIcon(Icons.soup_kitchen, '汤 火锅 soup'),
  AppIcon(Icons.emoji_food_beverage, '茶 饮料 tea drink'),
  AppIcon(Icons.wine_bar, '酒 酒吧 wine bar'),
  AppIcon(Icons.sports_bar, '啤酒 beer'),
  AppIcon(Icons.water_drop, '水 水费 water'),
  // ── 购物 ──
  AppIcon(Icons.shopping_bag, '购物 买东西 shopping bag'),
  AppIcon(Icons.shopping_cart, '购物车 cart'),
  AppIcon(Icons.storefront, '商店 门店 store'),
  AppIcon(Icons.local_mall, '商场 mall'),
  AppIcon(Icons.card_giftcard, '礼物 礼品 gift'),
  AppIcon(Icons.redeem, '兑换 礼券 redeem'),
  AppIcon(Icons.shopping_basket, '篮子 basket'),
  // ── 学习 ──
  AppIcon(Icons.school, '学校 上学 学费 school'),
  AppIcon(Icons.menu_book, '书 读书 教材 book'),
  AppIcon(Icons.auto_stories, '阅读 小说 read'),
  AppIcon(Icons.edit_note, '笔记 笔记本 note'),
  AppIcon(Icons.calculate, '计算 数学 考试 calculate math'),
  AppIcon(Icons.science, '科学 实验 science'),
  AppIcon(Icons.language, '英语 外语 language'),
  AppIcon(Icons.translate, '翻译 translate'),
  AppIcon(Icons.history_edu, '历史 语文 作业 history'),
  AppIcon(Icons.palette, '美术 画画 调色 palette art'),
  AppIcon(Icons.music_note, '音乐 唱歌 music'),
  AppIcon(Icons.piano, '钢琴 乐器 piano'),
  AppIcon(Icons.sports_esports, '游戏 电竞 game esports'),
  AppIcon(Icons.extension, '拼图 插件 extension'),
  AppIcon(Icons.print, '打印 打印机 print'),
  // ── 交通 ──
  AppIcon(Icons.directions_bus, '公交 巴士 bus'),
  AppIcon(Icons.directions_car, '汽车 打车 车 car'),
  AppIcon(Icons.directions_subway, '地铁 subway'),
  AppIcon(Icons.train, '火车 高铁 train'),
  AppIcon(Icons.flight, '飞机 旅行 出差 flight'),
  AppIcon(Icons.two_wheeler, '摩托 电动车 motorcycle'),
  AppIcon(Icons.pedal_bike, '自行车 骑车 bike'),
  AppIcon(Icons.local_taxi, '出租车 taxi'),
  AppIcon(Icons.local_gas_station, '加油 油费 gas'),
  AppIcon(Icons.ev_station, '充电桩 充电 ev'),
  AppIcon(Icons.local_parking, '停车 停车费 parking'),
  // ── 娱乐 ──
  AppIcon(Icons.movie, '电影 看片 movie'),
  AppIcon(Icons.theaters, '影院 剧场 theaters'),
  AppIcon(Icons.mic, '唱歌 麦克风 KTV mic'),
  AppIcon(Icons.sports_basketball, '篮球 basketball'),
  AppIcon(Icons.sports_soccer, '足球 soccer'),
  AppIcon(Icons.sports_tennis, '羽毛球 网球 badminton tennis'),
  AppIcon(Icons.fitness_center, '健身 举铁 健身房 gym'),
  AppIcon(Icons.pool, '游泳 swimming pool'),
  AppIcon(Icons.celebration, '庆祝 派对 party'),
  AppIcon(Icons.auto_awesome, '烟花 闪亮 awesome'),
  AppIcon(Icons.casino, '棋牌 麻将 casino'),
  AppIcon(Icons.attractions, '游乐园 摩天轮 park'),
  // ── 医疗健康 ──
  AppIcon(Icons.local_hospital, '医院 看病 hospital'),
  AppIcon(Icons.medication, '吃药 药 medication'),
  AppIcon(Icons.vaccines, '疫苗 打针 vaccine'),
  AppIcon(Icons.monitor_heart, '心率 健康 heart health'),
  AppIcon(Icons.psychology, '心理 咨询 psychology'),
  AppIcon(Icons.masks, '口罩 mask'),
  AppIcon(Icons.healing, '伤口 治疗 healing'),
  AppIcon(Icons.medical_services, '牙医 医疗箱 dentist medical'),
  // ── 生活居家 ──
  AppIcon(Icons.home, '家 房租 家具 home'),
  AppIcon(Icons.bolt, '电 电费 闪电 bolt'),
  AppIcon(Icons.local_fire_department, '燃气 燃气费 火 fire'),
  AppIcon(Icons.wifi, '网 网费 宽带 wifi'),
  AppIcon(Icons.phone_iphone, '手机 话费 通信 phone'),
  AppIcon(Icons.computer, '电脑 数码 computer'),
  AppIcon(Icons.cleaning_services, '保洁 清洁 cleaning'),
  AppIcon(Icons.local_laundry_service, '洗衣 洗衣机 laundry'),
  AppIcon(Icons.plumbing, '水管 维修 plumbing'),
  AppIcon(Icons.construction, '装修 工具 construction'),
  AppIcon(Icons.lightbulb, '电灯 灯泡 lightbulb'),
  AppIcon(Icons.chair, '家具 椅子 chair'),
  AppIcon(Icons.bed, '床 睡觉 bed'),
  AppIcon(Icons.kitchen, '厨房 厨具 kitchen'),
  AppIcon(Icons.key, '钥匙 key'),
  AppIcon(Icons.forest, '植物 绿植 forest'),
  AppIcon(Icons.yard, '花园 花草 yard'),
  AppIcon(Icons.dry_cleaning, '干洗 dry cleaning'),
  AppIcon(Icons.checkroom, '衣服 买衣服 衣柜 clothes'),
  AppIcon(Icons.cut, '理发 剪发 haircut'),
  AppIcon(Icons.face_retouching_natural, '美容 化妆 beauty'),
  // ── 人情社交 ──
  AppIcon(Icons.favorite, '爱心 喜欢 红 包 favorite love'),
  AppIcon(Icons.volunteer_activism, '公益 捐赠 donate'),
  AppIcon(Icons.groups, '聚会 团建 群 groups'),
  AppIcon(Icons.handshake, '社交 合作 handshake'),
  AppIcon(Icons.wc, '厕所 卫生间 wc'),
  AppIcon(Icons.baby_changing_station, '婴儿 母婴 baby'),
  AppIcon(Icons.child_care, '孩子 育儿 child'),
  // ── 收入理财 ──
  AppIcon(Icons.savings, '存款 生活费 储蓄 savings'),
  AppIcon(Icons.work, '工作 上班 简历 work'),
  AppIcon(Icons.badge, '工牌 员工 badge'),
  AppIcon(Icons.account_balance_wallet, '钱包 wallet'),
  AppIcon(Icons.account_balance, '银行 转账 bank'),
  AppIcon(Icons.payments, '现金 收款 payments cash'),
  AppIcon(Icons.currency_yuan, '人民币 元 钱 yuan'),
  AppIcon(Icons.paid, '到账 收入 paid'),
  AppIcon(Icons.trending_up, '理财 涨 基金 trending'),
  AppIcon(Icons.monetization_on, '赚钱 monetization'),
  AppIcon(Icons.receipt_long, '账单 发票 receipt'),
  AppIcon(Icons.credit_card, '信用卡 credit card'),
  AppIcon(Icons.qr_code, '扫码 付款 qr'),
  AppIcon(Icons.currency_exchange, '汇率 换汇 exchange'),
  AppIcon(Icons.request_quote, '报价 报销 quote'),
  // ── 其他 ──
  AppIcon(Icons.label, '标签 label'),
  AppIcon(Icons.star, '星 收藏 star'),
  AppIcon(Icons.category, '分类 category'),
  AppIcon(Icons.inventory_2, '箱子 快递 库存 inventory'),
  AppIcon(Icons.local_shipping, '快递 物流 shipping'),
  AppIcon(Icons.business_center, '公文包 出差 business'),
  AppIcon(Icons.more_horiz, '其他 more'),
  AppIcon(Icons.circle, '圆 点 circle'),
  AppIcon(Icons.help_outline, '问号 帮助 help'),
  AppIcon(Icons.flight_takeoff, '出发 起飞 takeoff'),
  AppIcon(Icons.camera_alt, '拍照 相机 camera'),
  AppIcon(Icons.headphones, '耳机 headphones'),
  AppIcon(Icons.sports, '运动 sports'),
  AppIcon(Icons.emoji_emotions, '开心 笑 emotions happy'),
  AppIcon(Icons.cloud, '云 天气 cloud'),
  AppIcon(Icons.sunny, '晴 太阳 sunny sun'),
  AppIcon(Icons.ac_unit, '空调 制冷 ac'),
];

/// 按关键词搜索图标码点；无匹配返回猫猫头（kCatCodePoint）。
int searchAppIcon(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return kCatCodePoint;
  for (final e in appIconCatalog) {
    if (e.keywords.toLowerCase().contains(q)) return e.data.codePoint;
  }
  // 逐字匹配（如「猫」「饭」单字）
  for (final e in appIconCatalog) {
    for (final kw in e.keywords.split(' ')) {
      if (kw.isNotEmpty && q.contains(kw)) return e.data.codePoint;
    }
  }
  return kCatCodePoint;
}

/// 码点反查（渲染自定义标签时使用）；未知码点返回 null（调用方渲染猫猫）。
IconData? iconDataFromCode(int codePoint) {
  for (final e in appIconCatalog) {
    if (e.data.codePoint == codePoint) return e.data;
  }
  return null;
}
