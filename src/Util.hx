import js.Syntax;
class Util{
	public static inline function toFixed(num:Float, digit:Int):String{
		return Syntax.code("{0}.toFixed({1})",num,digit);
	}

	public static function median(array:Array<Float>):Float{
		if(array.length==0) return 0;
		final data=array.copy();
		data.sort(function(a,b){
			return cast (a-b)*1000;
		});
		final center:Int = Math.floor(data.length/2);
		if(data.length%2==0){
			final a = data[center-1];
			final b = data[center];
			return (a+b)/2;
		}else{
			return data[center];
		}
	}
}