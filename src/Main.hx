import js.html.TableRowElement;
import js.html.TableCellElement;
import js.Syntax;
import js.html.Response;
import js.html.FileReader;
import js.html.InputElement;
import haxe.Json;
import js.Browser;
import js.html.Element;

using Util;

class Main{
	static final SAVE_KEY:String = "scoreData";
	static final DIFF_ARRAY:Array<String> = ["SPB","SPN","SPH","SPA","SPL"];
	static final tableElem:Element = Browser.document.getElementById("deraforce");
	static final tableHeader:Element = Browser.document.getElementById("tableHeader");
	static final df_val:Element = Browser.document.getElementById("df_val");
	static final df_name:Element = Browser.document.getElementById("df_name");
	static final df_ave:Element = Browser.document.getElementById("df_ave");
	static final df_med:Element = Browser.document.getElementById("df_med");
	static final deraforce_only:InputElement = cast Browser.document.getElementById("deraforce_only");
	static final diff_select:Array<InputElement> = cast Browser.document.getElementsByName("diff_select");
	static final scoreTable:ScoreTable = {
		update: 0,
		data:[],
	};
	static final dataTable:Array<SongData>=[];
	static var viewColumn:Array<Array<TableData>>=[];
	static final headerColumn:Array<TableCellElement>=[];
	static final dfData:DeraforceData = {
		deraforce: 0,
		median: 0,
		average: 0,
		name: "",
	};
	static final sortOption:SortOption = {
		column: 0,
		ascending: true,
		deraforceOnly: false,
		level: 0,
	}

	static var loading:Bool = true;
	public static function main(){
		setSortButton();
		setInput();
		load();
	}

	static function load(){
		final strage = Browser.getLocalStorage();
		if(strage!=null){
			final txt = strage.getItem(SAVE_KEY);
			if(txt!=null){
				final data:ScoreTable = Json.parse(txt);
				scoreTable.update=data.update;
				scoreTable.data=data.data;
			}
		}
		Browser.window.fetch("songdata.json").then(
			function(data:Response){
				data.json().then(
					function(json:Array<SongData>){
						for(d in json) dataTable.push(d);
						loading=false;
						setupDate();
						setTable();
					},
					function(e){
						Browser.alert("曲データの読み込みに失敗しました");
					}
				);
			},
			function(e){
				Browser.alert("曲データの読み込みに失敗しました");
			}
		);
	}

	static function setInput(){
		deraforce_only.checked=sortOption.deraforceOnly;
		deraforce_only.onchange=function(){
			sortOption.deraforceOnly=deraforce_only.checked;
			setupDate();
			setTable();
		}
		for(i in 0...diff_select.length){
			final input = diff_select[i];
			input.onclick = function(){
				if(sortOption.level!=Data.getInputDifficulties(i)){
					sortOption.level=Data.getInputDifficulties(i);
					setupDate();
					setTable();
				}
			}
		}
	}

	static function setSortButton(){
		final tr:TableRowElement = Browser.document.createTableRowElement();
		tableHeader.appendChild(tr);
		for(i in 0...cast ViewColumn.MAX){
			final td:TableCellElement = Browser.document.createTableCellElement();
			td.onclick = function(){
				if(sortOption.column==i){
					sortOption.ascending=!sortOption.ascending;
				}else{
					sortOption.column=i;
				}
				renameSortButton();
				setTable();
			}
			headerColumn.push(td);
			tr.appendChild(td);
		}
		renameSortButton();
	}

	static function renameSortButton(){
		for(i in 0...headerColumn.length){
			final td = headerColumn[i];
			td.innerText=Data.getColumnName(i);
			if(sortOption.column==i){
				td.innerText+=sortOption.ascending?"▲":"▼";
			}else{
				td.innerText+="　";
			}
		}
	}

	@:expose public static function clearData(){
		scoreTable.update=0;
		scoreTable.data=[];
		setupDate();
		setTable();
		var strage = Browser.getLocalStorage();
		if(strage==null) return;
		strage.removeItem(SAVE_KEY);
	}

	@:expose public static function clipboardImport(){
		if(loading) return;
		try{
			final promise = Browser.navigator.clipboard.readText();
			promise.then(function(text:String){
				updateScoreData(text);
			},function(e:Dynamic){
				Browser.alert("クリップボードからデータを取得できませんでした。\nブラウザの権限を確認してください。");
			});
		}catch(e:Dynamic){
			Browser.alert("クリップボードからデータが取れない環境の為、失敗しました。");
		}
	}

	@:expose public static function csvImport(){
		if(loading) return;
		final input:InputElement = cast Browser.document.createElement("input");
		input.type="file";
		input.accept="text/csv";
		input.onchange=function(){
			final file = input.files.item(0);
			final reader = new FileReader();
			reader.onload = function(){
				final text:String = reader.result;
				updateScoreData(text);
			};
			reader.readAsText(file);
		}
		input.click();
	}

	public static function setTable(){
		if(loading) return;
		while(tableElem.hasChildNodes()){
			tableElem.removeChild(tableElem.firstChild);
		}
		final data:Array<Array<TableData>> = viewColumn.copy();
		if(sortOption.ascending){
			data.sort(function(a,b){
				if(a[sortOption.column].text=="") return 1;
				if(b[sortOption.column].text=="") return -1;
				return Syntax.code("{0}>{1}",
				a[sortOption.column].sortValue,b[sortOption.column].sortValue)?1:-1;
			});
		}else{
			data.sort(function(a,b){
				if(a[sortOption.column].text=="") return 1;
				if(b[sortOption.column].text=="") return -1;
				return Syntax.code("{0}<{1}",
				a[sortOption.column].sortValue,b[sortOption.column].sortValue)?1:-1;
			});
		}
		for(dat in data){
			final tr = Browser.document.createElement("tr");
			tableElem.appendChild(tr);
			for(tDat in dat){
				final td:TableCellElement = cast Browser.document.createElement("td");
				td.innerText = tDat.text;
				if(tDat.style!="") td.style.cssText=tDat.style;
				tr.appendChild(td);
			}
		}
		df_val.innerText=dfData.deraforce.toFixed(3);
		df_ave.innerText=dfData.average.toFixed(3);
		df_med.innerText=dfData.median.toFixed(3);
		df_name.innerText=(dfData.name!="")?'[${dfData.name}]':"";
	}

	public static function updateScoreData(text:String){
		final key:Array<String> = [];
		final tableData:Array<ScoreData> = [];
		final data:Array<String> = text.split("\n");
		{
			final head:Array<String> = data.shift().split(",");
			if(head.length<=3){
				Browser.alert("インポートに失敗しました\ncsvではない可能性があります");
				return;
			}
			for(text in head){
				key.push(text);
			}
		}
		for(d in data){
			final diff:Array<ScoreData> = [];
			for(i in 0...5){
				diff.push({
					version: "",
					title: "",
					genre: "",
					artist: "",
					difficulty: DIFF_ARRAY[i],
					level: 0,
					score: 0,
					clearType: "NO PLAY",
					grade: "---",
				});
			}
			final dat = d.split(",");
			for(j in 0...dat.length){
				switch(key[j]){
					case "バージョン":
						for(e in diff) e.version=dat[j];
					case "タイトル":
						for(e in diff) e.title=dat[j];
					case "ジャンル":
						for(e in diff) e.genre=dat[j];
					case "アーティスト":
						for(e in diff) e.artist=dat[j];
					
					case "BEGINNER 難易度":
						diff[0].level=Std.parseInt(dat[j]);
					case "BEGINNER スコア":
						diff[0].score=Std.parseInt(dat[j]);
					case "BEGINNER クリアタイプ":
						diff[0].clearType=dat[j];
					case "BEGINNER DJ LEVEL":
						diff[0].grade=dat[j];
						
					case "NORMAL 難易度":
						diff[1].level=Std.parseInt(dat[j]);
					case "NORMAL スコア":
						diff[1].score=Std.parseInt(dat[j]);
					case "NORMAL クリアタイプ":
						diff[1].clearType=dat[j];
					case "NORMAL DJ LEVEL":
						diff[1].grade=dat[j];
	
					case "HYPER 難易度":
						diff[2].level=Std.parseInt(dat[j]);
					case "HYPER スコア":
						diff[2].score=Std.parseInt(dat[j]);
					case "HYPER クリアタイプ":
						diff[2].clearType=dat[j];
					case "HYPER DJ LEVEL":
						diff[2].grade=dat[j];
					
					case "ANOTHER 難易度":
						diff[3].level=Std.parseInt(dat[j]);
					case "ANOTHER スコア":
						diff[3].score=Std.parseInt(dat[j]);
					case "ANOTHER クリアタイプ":
						diff[3].clearType=dat[j];
					case "ANOTHER DJ LEVEL":
						diff[3].grade=dat[j];
						
					case "LEGGENDARIA 難易度":
						diff[4].level=Std.parseInt(dat[j]);
					case "LEGGENDARIA スコア":
						diff[4].score=Std.parseInt(dat[j]);
					case "LEGGENDARIA クリアタイプ":
						diff[4].clearType=dat[j];
					case "LEGGENDARIA DJ LEVEL":
						diff[4].grade=dat[j];
				}
			}
			for(e in diff){
				if(e.level>=11) tableData.push(e);
			}
		}
		scoreTable.data = tableData;
		scoreTable.update = Std.int(Date.now().getTime());
		var strage = Browser.getLocalStorage();
		if(strage!=null){
			strage.setItem(SAVE_KEY,Json.stringify(scoreTable));
		}
		setupDate();
		setTable();
	}

	static function setupDate(){
		if(loading) return;
		final viewData:Array<ViewData>=[];
		for(baseData in dataTable){
			if(sortOption.level!=0 && baseData.level!=sortOption.level) continue;
			final dat:ViewData={
				rank: 0,
				title: baseData.title,
				deraforce: 0,
				difficulty: baseData.difficulty,
				level: baseData.level,
				notes: baseData.notes,
				score: 0,
				scoreRate: 0,
				grade: "F",
				clearType: "NO PLAY",
				hardDifficulty: baseData.hardDifficulty,
				diffFact: 0,
				gradeFact: 0,
				lampFact: 0,
			}
			final score = scoreTable.data.filter(function(f){
				return f.title == dat.title && f.difficulty == dat.difficulty;
			})[0];
			if(score!=null){
				dat.score=score.score;
				dat.clearType=score.clearType;
			}
			dat.scoreRate = Data.calcScoreRate(dat.score, dat.notes);
			dat.diffFact = Data.getDiffFact(dat.level, dat.hardDifficulty);
			dat.grade = Data.getGrade(dat.scoreRate);
			dat.gradeFact = Data.getGradeFact(dat.grade);
			dat.lampFact = Data.getLampFact(dat.clearType);
			dat.deraforce = Data.calcDeraforce(dat.scoreRate, dat.diffFact,dat.gradeFact, dat.lampFact);

			viewData.push(dat);
		}

		final cData = viewData.copy();
		cData.sort(function(a,b){
			return a.deraforce<b.deraforce?1:-1;
		});
		var dfSum:Float=0;
		final dfArray:Array<Float>=[];
		for(i in 0...cData.length){
			if(cData[i].deraforce==0) cData[i].rank=0;
			else cData[i].rank=i+1;
			if(i<50){
				dfSum+=cData[i].deraforce;
				dfArray.push(cData[i].deraforce);
			}
			if(sortOption.deraforceOnly && (cData[i].rank>50 || cData[i].rank==0)){
				viewData.remove(cData[i]);
			}
		}
		dfData.average = dfSum/50;
		dfData.deraforce = dfSum/100;
		dfData.median = dfArray.median();
		dfData.name = Data.getDeraforce(dfData.deraforce);
		viewColumn=viewDataToArray(viewData);
	}

	static function viewDataToArray(viewData:Array<ViewData>):Array<Array<TableData>>{
		final ary:Array<Array<TableData>>=[];
		for(data in viewData){
			final dat:Array<TableData>=[];
			for(i in 0...cast ViewColumn.MAX){
				final column:ViewColumn = cast i;
				var tData:TableData={
					text:"",style:"",sortValue:0,
				};
				switch(column){
					case Rank:
						tData.text=data.rank==0?"":Std.string(data.rank);
						tData.sortValue=data.rank;
					case Title:
						tData.text=data.title;
						tData.sortValue=data.title;
						if(data.difficulty=="SPL") tData.style="color: #FF00FF;";
						if(data.difficulty=="SPH") tData.style="color: #CCAD51;";
					case Deraforce:
						tData.text=data.deraforce.toFixed(1);
						tData.sortValue=data.deraforce;
					case Difficulty:
						tData.text=data.difficulty;
						tData.sortValue=data.difficulty;
						if(data.difficulty=="SPL") tData.style="background-color: #FF00FF;";
						if(data.difficulty=="SPH") tData.style="background-color: #FFD966;";
						if(data.difficulty=="SPA") tData.style="background-color: #EA9999;";
					case Level:
						tData.text=Std.string(data.level);
						tData.sortValue=data.level;
					case NoteCount:
						tData.text=Std.string(data.notes);
						tData.sortValue=data.notes;
					case Score:
						tData.text=Std.string(data.score);
						tData.sortValue=data.score;
					case ScoreRate:
						tData.text=data.scoreRate.toFixed(2);
						tData.sortValue=data.scoreRate;
					case Grade:
						tData.text=data.grade;
						tData.sortValue=data.grade;
					case ClearType:
						tData.text=data.clearType;
						tData.sortValue=data.clearType;
					case HardDifficulty:
						tData.text=data.hardDifficulty;
						tData.sortValue=data.hardDifficulty;
					case DiffFact:
						tData.text=data.diffFact.toFixed(1);
						tData.sortValue=data.diffFact;
					case GradeFact:
						tData.text=data.gradeFact.toFixed(2);
						tData.sortValue=data.gradeFact;
					case LampFact:
						tData.text=data.lampFact.toFixed(2);
						tData.sortValue=data.lampFact;
					default:
				}
				dat.push(tData);
			}
			ary.push(dat);
		}
		return ary;
	}
}

typedef TableData = {
	public var text:String;
	public var style:String;
	public var sortValue:Dynamic;
}

typedef ScoreTable = {
	public var update:Int;
	public var data:Array<ScoreData>;
}

typedef ScoreData = {
	public var version:String;
	public var title:String;
	public var genre:String;
	public var artist:String;
	public var difficulty:String;
	public var level:Int;
	public var score:Int;
	public var clearType:String;
	public var grade:String;
}

typedef SongData = {
	public var title:String;
	public var notes:Int;
	public var difficulty:String;
	public var version:Int;
	public var level:Int;
	public var hardDifficulty:String;
}

typedef ViewData = {
	public var rank:Int;
	public var title:String;
	public var deraforce:Float;
	public var difficulty:String;
	public var level:Int;
	public var notes:Int;
	public var score:Int;
	public var scoreRate:Float;
	public var grade:String;
	public var clearType:String;
	public var hardDifficulty:String;
	public var diffFact:Float;
	public var gradeFact:Float;
	public var lampFact:Float;
}

typedef DeraforceData = {
	public var deraforce:Float;
	public var median:Float;
	public var average:Float;
	public var name:String;
}

typedef SortOption = {
	var column:Int;
	var ascending:Bool;//true=昇順、false=降順
	var deraforceOnly:Bool;//true=DERAFORCE対象曲のみ
	var level:Int;//ここに入れたレベルのみ表示(0=すべて)
}

enum abstract ViewColumn(Int) {
	var Rank;
	var Title;
	var Deraforce;
	var Difficulty;
	var Level;
	var NoteCount;
	var Score;
	var ScoreRate;
	var Grade;
	var ClearType;
	var HardDifficulty;
	var DiffFact;
	var GradeFact;
	var LampFact;
	var MAX;
}