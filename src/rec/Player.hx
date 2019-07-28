package rec;

import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import kha.FastFloat;
import kha.Image;
import kha.Assets;
#if kha_html5
import js.Browser.document;
import js.html.FileReader;
#end
import rec.Command;

class Player {

	public static var isActive(default, null) = false;
	static var isFileLoaded(default, null) = false;
	static final imageMap:Map<Int, Image> = [];
	static var atlas:Image;
	static var data:Array<FastFloat>;
	static var i = 0;

	public static function enable(?atlas:Image):Void {
		Player.atlas = atlas;
		final isBinary = false;
		#if kha_html5
		final input = document.createElement("input");
		input.style.visibility = "hidden";
		input.setAttribute("type", "file");
		input.id = "browse";
		input.onclick = function(e) {
			e.cancelBubble = true;
			e.stopPropagation();
		}
		input.onchange = function() {
			final file:Dynamic = (input:Dynamic).files[0];
			final reader = new FileReader();
			reader.onload = function(e) {
				final s = untyped pako.inflate(e.target.result, {to: 'string'});
				onFileLoad(s, file.name);
				document.body.removeChild(input);
			}
			if (isBinary) reader.readAsArrayBuffer(file);
			else reader.readAsText(file);
		}
		document.body.appendChild(input);
		input.click();
		#else
		#end
	}

	static function onFileLoad(json:String, name:String):Void {
		data = haxe.Json.parse('[$json]');
		i = 0;
		initImagesMap();
		isFileLoaded = true;
		isActive = true;
	}

	public static function disable():Void {
		isActive = false;
	}

	static function initImagesMap():Void {
		for (key in imageMap.keys()) imageMap.remove(key);
		final fields = Reflect.fields(Assets.images);
		for (i in 0...fields.length) {
			final field = fields[i];
			if (~/(Name|Description|names)$/.match(field)) continue;
			final img = Assets.images.get(field);
			imageMap[i] = img;
		}
	}

	public static function render(g:Graphics):Void {
		if (!isFileLoaded) return;
		inline function get() return data[i++];
		while (true) {
			final type:Command = cast get();
			if (type == null) {
				trace("wrong format");
				break;
			}
			switch (type) {
				case FrameBegin:
				case Begin:
					g.begin(cast get());
				case SetColor:
					g.color = cast get();
				case Transformation:
					final m = new FastMatrix3(
						get(), get(), get(),
						get(), get(), get(),
						get(), get(), get()
					);
					g.transformation.setFrom(m);
				case DrawImage:
					final imgIndex = cast get();
					var img = imageMap[imgIndex];
					if (img == null) img = atlas;
					g.drawImage(img, get(), get());
				case DrawScaledSubImage:
					final imgIndex = cast get();
					var img = imageMap[imgIndex];
					if (img == null) img = atlas;
					g.drawScaledSubImage(
						img, get(), get(), get(), get(),
						get(), get(), get(), get()
					);
				case DrawRect:
					g.drawRect(get(), get(), get(), get(), get());
				case FillRect:
					g.fillRect(get(), get(), get(), get());
				case DrawLine:
					g.drawLine(get(), get(), get(), get(), get());
				case FillTriangle:
					g.fillTriangle(get(), get(), get(), get(), get(), get());
				case End:
					g.end();
				case FrameEnd:
					break;
			}
		}
		if (i >= data.length) {
			i = 0;
		}
	}

}
