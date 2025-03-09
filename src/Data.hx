class Data{
	public static inline function calcScoreRate(score:Int, noteCount:Int):Float
		return Math.ffloor(score/(noteCount*2)*100 * 100)*0.01;

	public static inline function calcDeraforce(scoreRate:Float, diffFact:Float, gradeFact:Float, lampFact:Float):Float
		return Math.ffloor(diffFact * (scoreRate*0.001) * gradeFact * lampFact * 20 * 10)*0.1;

	public static function getDiffFact(level:Int, diff:String):Float{
		if(!diffFact.exists(level)) return 0;
		final fact:Float = diffFact.get(level).get(diff);
		if(fact==null) return getDiffFact(level, "未定");
		return fact;
	}

	public static function getGradeFact(grade:String):Float{
		final fact:Float = gradeFact.get(grade);
		if(fact==null) return 0;
		return fact;
	}

	public static function getLampFact(clearType:String):Float{
		final fact:Float = lampFact.get(clearType);
		if(fact==null) return 0;
		return fact;
	}

	public static function getGrade(scoreRate:Float):String{
		for(grade in rateGrade) if(scoreRate>=grade[0]) return grade[1];
		return "F";
	}

	public static function getDeraforce(deraforce:Float):String{
		for(name in deraforceList) if(deraforce>=name[0]) return name[1];
		return "";
	}

	public static inline function getColumnName(i:Int):String
		return columnName[i];

	public static inline function getInputDifficulties(i:Int):Int
		return inputDifficulties[i];

	private static final diffFact:Map<Int,Map<String,Float>>=[
		12=>[
			"地力S+"=>20,
			"地力S"=>19.8,
			"地力A+"=>19.6,
			"地力A"=>19.4,
			"地力B+"=>19.2,
			"地力B"=>19,
			"地力C"=>18.8,
			"地力D"=>18.6,
			"地力E"=>18.4,
			"地力F"=>18.2,
			"個人差S+"=>20,
			"個人差S"=>19.8,
			"個人差A+"=>19.6,
			"個人差A"=>19.4,
			"個人差B+"=>19.2,
			"個人差B"=>19,
			"個人差C"=>18.8,
			"個人差D"=>18.6,
			"個人差E"=>18.4,
			"未定"=>18.2,
		],
		11=>[
			"超個人差"=>18,
			"地力S+"=>18,
			"地力S"=>17.8,
			"地力A"=>17.6,
			"地力B+"=>17.4,
			"地力B"=>17.2,
			"地力C"=>17,
			"地力D"=>16.8,
			"地力E"=>16.6,
			"地力F"=>16.4,
			"個人差S+"=>18,
			"個人差S"=>17.8,
			"個人差A"=>17.6,
			"個人差B+"=>17.4,
			"個人差B"=>17.2,
			"個人差C"=>17,
			"個人差D"=>16.8,
			"未定"=>16.4,
		]
	];

	
	private static final lampFact:Map<String, Float>=[
		"FULLCOMBO CLEAR"=>1.1,
		"EX HARD CLEAR"=>1.07,
		"HARD CLEAR"=>1.05,
		"CLEAR"=>1.02,
		"EASY CLEAR"=>1,
		"ASSIST CLEAR"=>0.5,
		"FAILED"=>0.5,
		"NO PLAY"=>0.5,
	];

	private static final gradeFact:Map<String,Float>=[
		"MAX"=>1.1,
		"MAX-"=>1.07,
		"AAA+"=>1.05,
		"AAA-"=>1.02,
		"AA+"=>1,
		"AA-"=>0.97,
		"A+"=>0.94,
		"A-"=>0.91,
		"B+"=>0.88,
		"B-"=>0.85,
		"C+"=>0.82,
		"C-"=>0.8,
		"D+"=>0.77,
		"D-"=>0.74,
		"E+"=>0.71,
		"E-"=>0.68,
		"F+"=>0.65,
		"F"=>0,
		""=>0,
	];

	private static final rateGrade:Array<Array<Dynamic>>=[
		[100,"MAX"],
		[100*17/18,"MAX-"],
		[100*16/18,"AAA+"],
		[100*15/18,"AAA-"],
		[100*14/18,"AA+"],
		[100*13/18,"AA-"],
		[100*12/18,"A+"],
		[100*11/18,"A-"],
		[100*10/18,"B+"],
		[100*9/18,"B-"],
		[100*8/18,"C+"],
		[100*7/18,"C-"],
		[100*6/18,"D+"],
		[100*5/18,"D-"],
		[100*4/18,"E+"],
		[100*3/18,"E-"],
		[100*2/18,"F+"],
		[100*1/18,"F"],
		[0,"F"],
	];

	private static final deraforceList:Array<Array<Dynamic>>=[
		[24,"(^^)"],
		[23,"Imperial Ⅳ"],
		[22,"Imperial Ⅲ"],
		[21,"Imperial Ⅱ"],
		[20,"Imperial Ⅰ"],
		[19.75,"Crimson Ⅳ"],
		[19.5,"Crimson Ⅲ"],
		[19.25,"Crimson Ⅱ"],
		[19,"Crimson Ⅰ"],
		[18.75,"Eldora Ⅳ"],
		[18.5,"Eldora Ⅲ"],
		[18.25,"Eldora Ⅱ"],
		[18,"Eldora Ⅰ"],
		[17.75,"Argento Ⅳ"],
		[17.5,"Argento Ⅲ"],
		[17.25,"Argento Ⅱ"],
		[17,"Argento Ⅰ"],
		[16.75,"Coral Ⅳ"],
		[16.5,"Coral Ⅲ"],
		[16.25,"Coral Ⅱ"],
		[16,"Coral Ⅰ"],
		[15.75,"Scarlet Ⅳ"],
		[15.5,"Scarlet Ⅲ"],
		[15.25,"Scarlet Ⅱ"],
		[15,"Scarlet Ⅰ"],
		[14.75,"Cyan Ⅳ"],
		[14.5,"Cyan Ⅲ"],
		[14.25,"Cyan Ⅱ"],
		[14,"Cyan Ⅰ"],
		[13.5,"Dandelion Ⅳ"],
		[13,"Dandelion Ⅲ"],
		[12.5,"Dandelion Ⅱ"],
		[12,"Dandelion Ⅰ"],
		[11.5,"Cobalt Ⅳ"],
		[11,"Cobalt Ⅲ"],
		[10.5,"Cobalt Ⅱ"],
		[10,"Cobalt Ⅰ"],
		[7.5,"Sienna Ⅳ"],
		[5,"Sienna Ⅲ"],
		[2.5,"Sienna Ⅱ"],
		[0,"Sienna Ⅰ"],
	];
	
	private static final columnName:Array<String> = [
		"順位",
		"曲名",
		"DERAFORCE",
		"難易度",
		"レベル",
		"ノーツ数",
		"スコア",
		"スコアレート",
		"グレード",
		"クリアランプ",
		"ハード難易度",
		"難易度係数",
		"グレード係数",
		"ランプ係数"
	];

	private static final inputDifficulties:Array<Int>=[
		0,12,11
	];
}