package rec;

import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import kha.FastFloat;
import kha.Image;
import kha.Color;
import kha.Assets;
#if kha_html5
import js.Browser.document;
#end
import rec.Command;

class Recorder {

	public static var isActive(default, null) = false;
	public static var inFrame(default, null) = false;
	static final imageMap:Map<Image, Int> = [];
	static final data:Array<FastFloat> = [];

	public static function enable():Void {
		initImagesMap();
		data.resize(0);
		isActive = true;
	}

	static function initImagesMap():Void {
		for (key in imageMap.keys()) imageMap.remove(key);
		final fields = Reflect.fields(Assets.images);
		for (i in 0...fields.length) {
			final field = fields[i];
			if (~/(Name|Description|names)$/.match(field)) continue;
			final img = Assets.images.get(field);
			imageMap[img] = i;
		}
	}

	public static function frameBegin(g:Graphics):Void {
		if (!isActive) return;
		data.push(FrameBegin);
		inFrame = true;
		transformation(g.transformation);
	}

	public static function frameEnd():Void {
		if (!isActive) return;
		data.push(FrameEnd);
		inFrame = false;
	}

	public static function begin(color:Color):Void {
		if (!isActive || !inFrame) return;
		data.push(Begin);
		if (color == null) color = 0xFF000000;
		data.push(color);
	}

	public static function setColor(color:Color):Void {
		if (!isActive || !inFrame) return;
		data.push(SetColor);
		if (color == null) throw "null color";
		data.push(color);
	}

	static var lastMatrix = FastMatrix3.identity();

	public static function transformation(m:FastMatrix3):Void {
		if (!isActive || !inFrame) return;
		final t = lastMatrix;
		if (t._00 == m._00 && t._10 == m._10 && t._20 == m._20 &&
			t._01 == m._01 && t._11 == m._11 && t._21 == m._21 &&
			t._02 == m._02 && t._12 == m._12 && t._22 == m._22) return;
		t.setFrom(m);
		data.push(Transformation);
		data.push(m._00);
		data.push(m._10);
		data.push(m._20);
		data.push(m._01);
		data.push(m._11);
		data.push(m._21);
		data.push(m._02);
		data.push(m._12);
		data.push(m._22);
	}

	public static function drawRect(x:Float, y:Float, w:Float, h:Float, strength:Float):Void {
		if (!isActive || !inFrame) return;
		data.push(DrawRect);
		data.push(x);
		data.push(y);
		data.push(w);
		data.push(h);
		data.push(strength);
	}

	public static function fillRect(x:Float, y:Float, w:Float, h:Float):Void {
		if (!isActive || !inFrame) return;
		data.push(FillRect);
		data.push(x);
		data.push(y);
		data.push(w);
		data.push(h);
	}

	public static function drawLine(x:Float, y:Float, x2:Float, y2:Float, strength:Float):Void {
		if (!isActive || !inFrame) return;
		data.push(DrawLine);
		data.push(x);
		data.push(y);
		data.push(x2);
		data.push(y2);
		data.push(strength);
	}

	public static function fillTriangle(x:Float, y:Float, x2:Float, y2:Float, x3:Float, y3:Float):Void {
		if (!isActive || !inFrame) return;
		data.push(FillTriangle);
		data.push(x);
		data.push(y);
		data.push(x2);
		data.push(y2);
		data.push(x3);
		data.push(y3);
	}

	public static function drawImage(img:Image, x:FastFloat, y:FastFloat):Void {
		if (!isActive || !inFrame) return;
		data.push(DrawImage);
		data.push(imageMap[img] == null ? -1 : imageMap[img]);
		data.push(x);
		data.push(y);
	}

	public static function drawScaledSubImage(img:Image, sx:FastFloat, sy:FastFloat, sw:FastFloat, sh:FastFloat, dx:FastFloat, dy:FastFloat, dw:FastFloat, dh:FastFloat):Void {
		if (!isActive || !inFrame) return;
		data.push(DrawScaledSubImage);
		data.push(imageMap[img] == null ? -1 : imageMap[img]);
		data.push(sx);
		data.push(sy);
		data.push(sw);
		data.push(sh);
		data.push(dx);
		data.push(dy);
		data.push(dw);
		data.push(dh);
	}

	public static function end():Void {
		if (!isActive || !inFrame) return;
		data.push(End);
	}

	public static function save():Void {
		isActive = false;
		final bin = data.toString();
		#if kha_html5
		final bin = untyped pako.deflate(bin, {to:'string'});
		final blob = new js.html.Blob([bin], {
			type: "application/octet-stream"
		});
		final url = js.html.URL.createObjectURL(blob);
		final a = document.createElement("a");
		untyped a.download = "record.krec";
		untyped a.href = url;
		a.onclick = function(e) {
			e.cancelBubble = true;
			e.stopPropagation();
		}
		document.body.appendChild(a);
		a.click();
		document.body.removeChild(a);
		js.html.URL.revokeObjectURL(url);
		#end
	}

}

