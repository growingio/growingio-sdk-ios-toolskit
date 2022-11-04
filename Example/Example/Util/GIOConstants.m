//
//  Contstants.m
//  GrowingExample
//
//  Created by GrowingIO on 2018/6/1.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GIOConstants.h"

@implementation GIOConstants

//返回超过1000个字符的字符串
+ (NSString *)getMyInput {
    NSString *const OutRangeInput =
        @"学而篇第一 1子曰：“学而时习之，不亦说乎？有朋自远方来，不亦乐乎？人不知而不愠，不亦君子乎？” "
        @"2有子曰：“其为人也孝弟，而好犯上者，鲜矣；不好犯上，而好作乱者，未之有也。君子务本，本立而道生。孝弟也者，其"
        @"为仁之本与！” 3子曰：“巧言令色，鲜矣仁！” "
        @"4曾子曰：“吾日三省吾身：为人谋而不忠乎？与朋友交而不信乎？传不习乎？” "
        @"5子曰：“道千乘之国，敬事而信，节用而爱人，使民以时。” 6 "
        @"子曰：“弟子，入则孝，出则悌，谨而信，泛爱众，而亲仁。行有馀力，则以学文。” 7 "
        @"子夏曰：“贤贤易色；事父母，能竭其力；事君，能致其身；与朋友交，言而有信。虽曰未学，吾必谓之学矣。” 8 "
        @"子曰：“君子不重，则不威；学则不固。主忠信，无友不如已者。过则勿惮改。” 9 曾子曰：“慎终追远，民德归厚矣。” 10 "
        @"子禽问于子贡曰：“夫子至于是邦也，必闻其政，求之与？抑与之与？”子贡曰：“夫子温、良、恭、俭、让以得之。夫子之求"
        @"之也，其诸异乎人之求之与？” 11 子曰：“父在，观其志；父没，观其行；三年无改于父之道，可谓孝矣。” 12 "
        @"有子曰：“礼之用，和为贵。先王之道，斯为美；小大由之。有所不行，知和而和，不以礼节之，亦不可行也。” 13 "
        @"有子曰：“信近於义，言可复也。恭近於礼，远耻辱也。因不失其亲，亦可宗也。” 14 "
        @"子曰：“君子食无求饱，居无求安，敏於事而慎於言，就有道而正焉，可谓好学也已。” 15 "
        @"子贡曰：“贫而无谄，富而无骄，何如？”子曰：“可也。未若贫而乐，富而好礼者也。”子贡曰：“《诗》云：‘如切如磋，如"
        @"琢如磨’，其斯之谓与？”子曰：“赐也，始可与言《诗》已矣，告诸往而知来者。” 16 "
        @"子曰：“不患人之不己知，患不知人也。”为政篇第二 论语目录2．1 子曰：“为政以德，譬如北辰，居其所而众星共之。” "
        @"2．2 子曰：“《诗》三百，一言以蔽之，曰：‘思无邪。’” 2．3 "
        @"子曰：“道之以政，齐之以刑，民免而无耻；道之以德，齐之以礼，有耻且格。” 2．4 "
        @"子曰：“吾十有五而志于学，三十而立，四十而不惑，五十而知天命，六十而耳顺，七十而从心所欲，不逾矩。” 2．5 "
        @"孟懿子问孝。子曰：“无违。”樊迟御，子告之曰：“孟孙问孝于我，我对曰，无违。”樊迟曰：“何谓也？”子曰：“生，事之以"
        @"礼；死，葬之以礼，祭之以礼。” 2．6 孟武伯问孝。子曰：“父母唯其疾之忧。” 2．7 "
        @"子游问孝。子曰：“今之孝者，是谓能养。至于犬马，皆能有养；不敬，何以别乎？” 2．8 "
        @"子夏问孝。子曰：“色难。有事，弟子服其劳；有酒食，先生馔，曾是以为孝乎？” 2．9 "
        @"子曰：“吾与回言终日，不违，如愚。退而省其私，亦足以发，回也不愚。” 2．10 "
        @"子曰：“视其所以，观其所由，察其所安。人焉廋哉？人焉廋哉？” 2．11 子曰：“温故而知新，可以为师矣。” 2．12 "
        @"子曰：“君子不器。” 2．13 子贡问君子。子曰：“先行其言而后从之。";
    return OutRangeInput;
}
//返回超过100键值对的字典
+ (NSDictionary *)getLargeDictionary {
    NSDictionary *const lardic = @{
        @"key1": @"弟子规，圣人训",
        @"key2": @"首孝悌，次谨信",
        @"key3": @"泛爱众，而亲仁",
        @"key4": @"有余力，则学文",
        @"key5": @"父母呼，应勿缓",
        @"key6": @"父母命，行勿懒",
        @"key7": @"父母教，须敬听",
        @"key8": @"父母责，须顺承",
        @"key9": @"冬则温，夏则凊",
        @"key10": @"晨则省，昏则定",
        @"key11": @"出必告，反必面",
        @"key12": @"居有常，业无变",
        @"key13": @"事虽小，勿擅为",
        @"key14": @"苟擅为，子道亏",
        @"key15": @"物虽小，勿私藏",
        @"key16": @"苟私藏，亲心伤",
        @"key17": @"亲所好，力为具",
        @"key18": @"亲所恶，谨为去",
        @"key19": @"身有伤，贻亲忧",
        @"key20": @"德有伤，贻亲羞",
        @"key21": @"亲爱我，孝何难",
        @"key22": @"亲憎我，孝方贤",
        @"key23": @"亲有过，谏使更",
        @"key24": @"怡吾色，柔吾声",
        @"key25": @"谏不入，悦复谏",
        @"key26": @"号泣随，挞无怨",
        @"key27": @"亲有疾，药先尝",
        @"key28": @"昼夜侍，不离床",
        @"key29": @"丧三年，常悲咽",
        @"key30": @"居处变，酒肉绝",
        @"key31": @"丧尽礼，祭尽诚",
        @"key32": @"事死者，如事生",
        @"key33": @"兄道友，弟道恭",
        @"key34": @"兄弟睦，孝在中",
        @"key35": @"财物轻，怨何生",
        @"key36": @"言语忍，忿自泯",
        @"key37": @"或饮食，或坐走",
        @"key38": @"长者先，幼者后",
        @"key39": @"长呼人，即代叫",
        @"key40": @"人不在，已即到",
        @"key41": @"称尊长，勿呼名",
        @"key42": @"对尊长，勿见能",
        @"key43": @"路遇长，疾趋揖",
        @"key44": @"长无言，退恭立",
        @"key45": @"骑下马，乘下车",
        @"key46": @"过犹待，百步余",
        @"key47": @"长者立，幼勿坐",
        @"key48": @"长者坐，命乃坐",
        @"key49": @"尊长前，声要低",
        @"key50": @"低不闻，却非宜",
        @"key51": @"进必趋，退必迟",
        @"key52": @"问起对，视勿移",
        @"key53": @"事诸父，如事父",
        @"key54": @"事诸兄，如事兄",
        @"key55": @"朝起早，夜眠迟",
        @"key56": @"老易至，惜此时",
        @"key57": @"晨必盥，兼漱口",
        @"key58": @"便溺回，辄净手",
        @"key59": @"冠必正，纽必结",
        @"key60": @"袜与履，俱紧切",
        @"key61": @"置冠服，有定位",
        @"key62": @"勿乱顿，致污秽",
        @"key63": @"衣贵洁，不贵华",
        @"key64": @"上循分，下称家",
        @"key65": @"对饮食，勿拣择",
        @"key66": @"食适可，勿过则",
        @"key67": @"年方少，勿饮酒",
        @"key68": @"饮酒醉，最为丑",
        @"key69": @"步从容，立端正",
        @"key70": @"揖深圆，拜恭敬",
        @"key71": @"勿践阈，勿跛倚",
        @"key72": @"勿箕踞，勿摇髀",
        @"key73": @"缓揭帘，勿有声",
        @"key74": @"宽转弯，勿触棱",
        @"key75": @"执虚器，如执盈",
        @"key76": @"入虚室，如有人",
        @"key77": @"事勿忙，忙多错",
        @"key78": @"勿畏难，勿轻略",
        @"key79": @"斗闹场，绝勿近",
        @"key80": @"邪僻事，绝勿问",
        @"key81": @"将入门，问孰存",
        @"key82": @"将上堂，声必扬",
        @"key83": @"人问谁，对以名",
        @"key84": @"吾与我，不分明",
        @"key85": @"用人物，须明求",
        @"key86": @"倘不问，即为偷",
        @"key87": @"借人物，及时还",
        @"key88": @"人借物，有勿悭",
        @"key89": @"凡出言，信为先",
        @"key90": @"诈与妄，奚可焉",
        @"key91": @"话说多，不如少",
        @"key92": @"惟其是，勿佞巧",
        @"key93": @"奸巧语，秽污词",
        @"key94": @"市井气，切戒之",
        @"key95": @"见未真，勿轻言",
        @"key96": @"知未的，勿轻传",
        @"key97": @"事非宜，勿轻诺",
        @"key98": @"苟轻诺，进退错",
        @"key99": @"凡道字，重且舒",
        @"key100": @"勿急疾，勿模糊",
        @"key101": @"彼说长，此说短",
        @"key102": @"不关己，莫闲管",
        @"key103": @"见人善，即思齐",
        @"key104": @"纵去远，以渐跻",
        @"key105": @"见人恶，即内省",
        @"key106": @"有则改，无加警",
        @"key107": @"唯德学，唯才艺",
        @"key108": @"不如人，当自砺",
        @"key109": @"若衣服，若饮食",
        @"key110": @"不如人，勿生戚"
    };
    return lardic;
}

+ (UITableViewHeaderFooterView *)globalSectionHeaderForIdentifier:(NSString *)identifier {
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
    [header.contentView setBackgroundColor:[UIColor orangeColor]];
    header.textLabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:32];
    [header.textLabel setTextColor:[UIColor whiteColor]];

    return header;
}

@end
